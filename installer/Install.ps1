#Requires -Version 5.1
param([ValidateSet('Install', 'Restore')][string]$Mode = 'Install')
$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'Installer.Core.ps1')
$temporary = $null
$success = $false
try {
    Write-Host ''
    Write-Host 'Valheim Continue - einfache Installation' -ForegroundColor Cyan
    Write-Host ''
    if ([Environment]::OSVersion.Platform -ne [PlatformID]::Win32NT) { throw 'Dieses Installationspaket ist fuer Windows gedacht.' }
    if (Get-Process -Name valheim -ErrorAction SilentlyContinue) { throw 'Bitte Valheim zuerst vollstaendig beenden und Installieren danach erneut starten.' }
    $roots = New-Object 'System.Collections.Generic.List[string]'
    foreach ($key in @('HKCU:\Software\Valve\Steam', 'HKLM:\SOFTWARE\WOW6432Node\Valve\Steam')) {
        $steam = Get-ItemProperty -LiteralPath $key -ErrorAction SilentlyContinue
        if ($null -ne $steam) {
            foreach ($name in @('SteamPath', 'InstallPath')) {
                $property = $steam.PSObject.Properties[$name]
                if ($null -ne $property -and $property.Value) { $roots.Add([string]$property.Value) }
            }
        }
    }
    foreach ($base in @(${env:ProgramFiles(x86)}, $env:ProgramFiles)) {
        if ($base) { $roots.Add((Join-Path $base 'Steam')) }
    }
    $candidates = @(Find-ValheimInstallations -SteamRoots $roots.ToArray() | Select-Object -Unique)
    if ($candidates.Count -eq 1) {
        $game = $candidates[0]
        Write-Host ('Valheim gefunden: ' + $game)
    } else {
        Add-Type -AssemblyName System.Windows.Forms
        Write-Host 'Bitte im jetzt geoeffneten Fenster die Datei valheim.exe auswaehlen.'
        Write-Host 'Du findest den Ordner in Steam: Valheim -> Eigenschaften -> Installierte Dateien -> Durchsuchen.'
        $dialog = New-Object System.Windows.Forms.OpenFileDialog
        $dialog.Title = 'Valheim auswaehlen (valheim.exe)'
        $dialog.Filter = 'Valheim (valheim.exe)|valheim.exe'
        $dialog.CheckFileExists = $true
        if ($dialog.ShowDialog() -ne [System.Windows.Forms.DialogResult]::OK) { throw 'Auswahl abgebrochen. Es wurde nichts installiert.' }
        $game = Split-Path $dialog.FileName
        $dialog.Dispose()
    }
    if ($Mode -eq 'Restore') {
        $history = Join-Path $game 'BepInEx/ContinueInstallerBackups'
        $backup = $null
        if (Test-Path -LiteralPath $history) {
            foreach ($folder in @(Get-ChildItem -LiteralPath $history -Directory | Sort-Object Name -Descending)) {
                $file = Join-Path $folder.FullName 'manifest.json'
                if (Test-Path -LiteralPath $file) {
                    $state = Get-Content -LiteralPath $file -Raw | ConvertFrom-Json
                    if ($state.Status -eq 'Installed') { $backup = $folder.FullName; break }
                }
            }
        }
        if (!$backup) { throw 'Keine passende Installation dieses Pakets gefunden. Die manuelle Anleitung erklaert das Entfernen.' }
        $changed = @(Undo-ContinueInstallation -GamePath $game -BackupPath $backup -KeepLoader)
        if ($changed.Count -gt 0) { throw 'Die Mod-Datei wurde seit der Installation veraendert. Sie wurde deshalb nicht automatisch ersetzt oder geloescht.' }
        Write-Host 'Die letzte Continue-Installation ist rueckgaengig gemacht.' -ForegroundColor Green
        Write-Host 'BepInEx, andere Mods und deine Einstellungen bleiben erhalten.'
    } else {
        $plugin = Join-Path $PSScriptRoot 'ValheimContinue.dll'
        Assert-FileHash $plugin '7b67d75206cf8273e8011c56bc580ed17364384f5dcac4247814e398bb17b324'
        $pack = $null
        if (!(Test-Path -LiteralPath (Join-Path $game 'BepInEx/core/BepInEx.dll') -PathType Leaf)) {
            Write-Host 'BepInEx wird automatisch vom Valheim-BepInEx-Paket auf Thunderstore heruntergeladen ...'
            $temporary = Join-Path ([IO.Path]::GetTempPath()) ('ValheimContinue-' + [Guid]::NewGuid().ToString('N'))
            New-Item -ItemType Directory -Path $temporary | Out-Null
            $zip = Join-Path $temporary 'BepInEx.zip'
            [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
            Invoke-WebRequest -Uri 'https://thunderstore.io/package/download/denikson/BepInExPack_Valheim/5.4.2351/' -OutFile $zip -UseBasicParsing -TimeoutSec 90
            Assert-FileHash $zip 'bce631497976a93977ceb08e166712e6c31d15244956f89f17df092a9b62e29f'
            Expand-Archive -LiteralPath $zip -DestinationPath (Join-Path $temporary 'pack')
            $pack = Join-Path $temporary 'pack/BepInExPack_Valheim'
        }
        Write-Host 'Die Mod wird installiert. Vorhandene Mod-Dateien werden vorher gesichert ...'
        $result = Install-ContinueFiles -GamePath $game -PluginPath $plugin -PackPath $pack
        Write-Host ''
        Write-Host 'Fertig! Starte Valheim jetzt wie gewohnt ueber Steam.' -ForegroundColor Green
        Write-Host 'Im Hauptmenue: ... anklicken, Figur und Server eintragen, Speichern, continue.'
        if ($result.AlreadyInstalled) { Write-Host 'Diese Version war bereits installiert; nichts wurde ersetzt.' }
    }
    $success = $true
} catch {
    Write-Host ''
    Write-Host ('Abgebrochen: ' + $_.Exception.Message) -ForegroundColor Red
    if ($_.Exception -is [UnauthorizedAccessException] -or $_.CategoryInfo.Category -eq 'PermissionDenied') {
        Write-Host 'Windows verweigert den Zugriff auf den Spielordner. Falls noetig: Rechtsklick auf die CMD-Datei -> Als Administrator ausfuehren.'
    }
    Write-Host 'Falls du Hilfe brauchst, gib diese Meldung weiter. Dein Serverpasswort wird hier nicht benoetigt.'
} finally {
    if ($temporary -and (Test-Path -LiteralPath $temporary)) { Remove-Item -LiteralPath $temporary -Recurse -Force -ErrorAction SilentlyContinue }
}
Write-Host ''
Read-Host 'Zum Schliessen die Eingabetaste druecken' | Out-Null
if (!$success) { exit 1 }
