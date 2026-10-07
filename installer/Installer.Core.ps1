Set-StrictMode -Version 2.0

function Get-SteamLibraryPaths {
    param([string[]]$SteamRoots)
    $paths = New-Object 'System.Collections.Generic.List[string]'
    foreach ($root in $SteamRoots) {
        if ([string]::IsNullOrWhiteSpace($root)) { continue }
        $paths.Add($root)
        foreach ($relative in @('steamapps/libraryfolders.vdf', 'config/libraryfolders.vdf')) {
            $file = Join-Path $root $relative
            if (!(Test-Path -LiteralPath $file -PathType Leaf)) { continue }
            $content = [IO.File]::ReadAllText($file)
            foreach ($match in [regex]::Matches($content, '"(?:path|[0-9]+)"\s*"((?:\\.|[^"\\])+)"')) {
                try {
                    $value = ConvertFrom-Json ('"' + $match.Groups[1].Value + '"')
                    if ([IO.Path]::IsPathRooted($value)) { $paths.Add($value) }
                } catch { continue }
            }
        }
    }
    return @($paths | Select-Object -Unique)
}

function Find-ValheimInstallations {
    param([string[]]$SteamRoots)
    foreach ($library in @(Get-SteamLibraryPaths -SteamRoots $SteamRoots)) {
        $name = 'Valheim'
        $manifest = Join-Path $library 'steamapps/appmanifest_892970.acf'
        if (Test-Path -LiteralPath $manifest -PathType Leaf) {
            $match = [regex]::Match([IO.File]::ReadAllText($manifest), '"installdir"\s*"([^"/\\]+)"')
            if ($match.Success) { $name = $match.Groups[1].Value }
        }
        $game = Join-Path $library ('steamapps/common/' + $name)
        if (Test-Path -LiteralPath (Join-Path $game 'valheim.exe') -PathType Leaf) {
            [IO.Path]::GetFullPath($game)
        }
    }
}

function Assert-FileHash {
    param([string]$Path, [string]$Expected)
    if (!(Test-Path -LiteralPath $Path -PathType Leaf) -or
        (Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash -ne $Expected) {
        throw 'Die heruntergeladene Datei ist unvollstaendig oder entspricht nicht diesem Paket. Bitte erneut herunterladen.'
    }
}

function Resolve-InstallerChild {
    param([string]$Root, [string]$Relative)
    $base = [IO.Path]::GetFullPath($Root).TrimEnd([IO.Path]::DirectorySeparatorChar)
    $child = [IO.Path]::GetFullPath((Join-Path $base $Relative))
    if (!$child.StartsWith($base + [IO.Path]::DirectorySeparatorChar, [StringComparison]::OrdinalIgnoreCase)) {
        throw 'Ungueltiger Dateipfad in der Installationssicherung.'
    }
    return $child
}

function Undo-ContinueInstallation {
    param([string]$GamePath, [string]$BackupPath, [switch]$Rollback, [switch]$KeepLoader)
    $manifest = Get-Content -LiteralPath (Join-Path $BackupPath 'manifest.json') -Raw | ConvertFrom-Json
    if ([IO.Path]::GetFullPath($GamePath) -ne $manifest.GamePath) { throw 'Diese Sicherung gehoert zu einem anderen Spielordner.' }
    $changed = New-Object 'System.Collections.Generic.List[string]'
    $entries = @($manifest.Files)
    [array]::Reverse($entries)
    foreach ($entry in $entries) {
        if ($KeepLoader -and $entry.Kind -eq 'Loader') { continue }
        $target = Resolve-InstallerChild $GamePath $entry.Relative
        if (!$Rollback -and (Test-Path -LiteralPath $target)) {
            if (!(Test-Path -LiteralPath $target -PathType Leaf) -or
                (Get-FileHash -LiteralPath $target -Algorithm SHA256).Hash -ne $entry.InstalledHash) {
                $changed.Add($entry.Relative)
                continue
            }
        }
        if ($entry.Existed) {
            $saved = Resolve-InstallerChild $BackupPath ('files/' + $entry.Relative)
            Assert-FileHash $saved $entry.OriginalHash
            New-Item -ItemType Directory -Path (Split-Path $target) -Force | Out-Null
            Copy-Item -LiteralPath $saved -Destination $target -Force
        } elseif (Test-Path -LiteralPath $target -PathType Leaf) {
            Remove-Item -LiteralPath $target -Force
        }
    }
    if ($changed.Count -eq 0) {
        $manifest.Status = if ($Rollback) { 'RolledBack' } else { 'Restored' }
        [IO.File]::WriteAllText((Join-Path $BackupPath 'manifest.json'), ($manifest | ConvertTo-Json -Depth 5))
    }
    return @($changed)
}

function Install-ContinueFiles {
    param([string]$GamePath, [string]$PluginPath, [string]$PackPath)
    $GamePath = [IO.Path]::GetFullPath($GamePath)
    if (!(Test-Path -LiteralPath (Join-Path $GamePath 'valheim.exe') -PathType Leaf)) { throw 'Im gewaehlten Ordner fehlt valheim.exe.' }
    if (!(Test-Path -LiteralPath $PluginPath -PathType Leaf)) { throw 'Die Mod-Datei fehlt. Bitte das ganze ZIP entpacken.' }
    $targetRelative = 'BepInEx/plugins/ValheimContinue/ValheimContinue.dll'
    $targetPlugin = [IO.Path]::GetFullPath((Join-Path $GamePath $targetRelative))
    $plugins = Join-Path $GamePath 'BepInEx/plugins'
    if (Test-Path -LiteralPath $plugins) {
        foreach ($existing in @(Get-ChildItem -LiteralPath $plugins -Recurse -Filter ValheimContinue.dll -File)) {
            if ($existing.FullName -ne $targetPlugin) { throw 'Continue liegt bereits in einem anderen Mod-Ordner. Bitte diese alte DLL zuerst entfernen oder die manuelle Anleitung verwenden.' }
        }
    }
    $loaderPresent = Test-Path -LiteralPath (Join-Path $GamePath 'BepInEx/core/BepInEx.dll') -PathType Leaf
    if ($loaderPresent -and (!(Test-Path -LiteralPath (Join-Path $GamePath 'winhttp.dll')) -or
        !(Test-Path -LiteralPath (Join-Path $GamePath 'doorstop_config.ini')))) {
        throw 'Ein vorhandener Mod-Lader wurde erkannt, verwendet aber einen anderen Startweg. Bitte die manuelle Anleitung verwenden.'
    }
    $plan = New-Object 'System.Collections.Generic.List[object]'
    if (!$loaderPresent) {
        $bepDirectory = Join-Path $GamePath 'BepInEx'
        if (Test-Path -LiteralPath $bepDirectory) {
            $other = @(Get-ChildItem -LiteralPath $bepDirectory -Force | Where-Object { $_.Name -ne 'ContinueInstallerBackups' })
            if ($other.Count -gt 0) { throw 'Es liegen bereits Dateien eines Mod-Laders im Spielordner. Bitte die manuelle Anleitung verwenden.' }
        }
        foreach ($relative in @('winhttp.dll', 'doorstop_config.ini', 'version.dll', 'dwmapi.dll')) {
            if (Test-Path -LiteralPath (Join-Path $GamePath $relative)) {
                throw 'Es liegen bereits Dateien eines Mod-Laders im Spielordner. Diese werden nicht ersetzt. Bitte die manuelle Anleitung verwenden.'
            }
        }
        if (!(Test-Path -LiteralPath (Join-Path $PackPath 'BepInEx/core/BepInEx.dll') -PathType Leaf)) { throw 'Das BepInEx-Paket ist unvollstaendig.' }
        foreach ($file in @(Get-ChildItem -LiteralPath (Join-Path $PackPath 'BepInEx') -Recurse -File)) {
            $relative = $file.FullName.Substring([IO.Path]::GetFullPath($PackPath).TrimEnd([IO.Path]::DirectorySeparatorChar).Length + 1)
            $plan.Add(@{ Source = $file.FullName; Relative = $relative; Kind = 'Loader' })
        }
        foreach ($relative in @('winhttp.dll', 'doorstop_config.ini')) {
            $source = Join-Path $PackPath $relative
            if (!(Test-Path -LiteralPath $source -PathType Leaf)) { throw 'Das BepInEx-Paket ist unvollstaendig.' }
            $plan.Add(@{ Source = $source; Relative = $relative; Kind = 'Loader' })
        }
    }
    $plan.Add(@{ Source = $PluginPath; Relative = $targetRelative; Kind = 'Plugin' })
    $pluginHash = (Get-FileHash -LiteralPath $PluginPath -Algorithm SHA256).Hash
    if ($loaderPresent -and (Test-Path -LiteralPath $targetPlugin -PathType Leaf) -and
        (Get-FileHash -LiteralPath $targetPlugin -Algorithm SHA256).Hash -eq $pluginHash) {
        return @{ AlreadyInstalled = $true; BackupPath = $null }
    }
    foreach ($entry in $plan) {
        $target = Resolve-InstallerChild $GamePath $entry.Relative
        if ((Test-Path -LiteralPath $target) -and !(Test-Path -LiteralPath $target -PathType Leaf)) { throw 'Eine Zieldatei ist durch einen Ordner blockiert. Es wurde nichts installiert.' }
    }
    $backup = Join-Path $GamePath ('BepInEx/ContinueInstallerBackups/' + [DateTime]::UtcNow.ToString('yyyyMMdd-HHmmss-ffff') + '-' + [Guid]::NewGuid().ToString('N'))
    $records = New-Object 'System.Collections.Generic.List[object]'
    New-Item -ItemType Directory -Path $backup -Force | Out-Null
    foreach ($entry in $plan) {
        $target = Resolve-InstallerChild $GamePath $entry.Relative
        $existed = Test-Path -LiteralPath $target -PathType Leaf
        $originalHash = $null
        if ($existed) {
            $originalHash = (Get-FileHash -LiteralPath $target -Algorithm SHA256).Hash
            $saved = Resolve-InstallerChild $backup ('files/' + $entry.Relative)
            New-Item -ItemType Directory -Path (Split-Path $saved) -Force | Out-Null
            Copy-Item -LiteralPath $target -Destination $saved
        }
        $records.Add(@{ Relative = $entry.Relative; Kind = $entry.Kind; Existed = $existed;
            OriginalHash = $originalHash; InstalledHash = (Get-FileHash -LiteralPath $entry.Source -Algorithm SHA256).Hash })
    }
    $manifest = @{ GamePath = $GamePath; Status = 'Installing'; Files = @($records.ToArray()) }
    $manifestPath = Join-Path $backup 'manifest.json'
    [IO.File]::WriteAllText($manifestPath, ($manifest | ConvertTo-Json -Depth 5))
    try {
        foreach ($entry in $plan) {
            $target = Resolve-InstallerChild $GamePath $entry.Relative
            New-Item -ItemType Directory -Path (Split-Path $target) -Force | Out-Null
            Copy-Item -LiteralPath $entry.Source -Destination $target -Force
            Assert-FileHash $target (Get-FileHash -LiteralPath $entry.Source -Algorithm SHA256).Hash
        }
        $manifest.Status = 'Installed'
        [IO.File]::WriteAllText($manifestPath, ($manifest | ConvertTo-Json -Depth 5))
    } catch {
        $failure = $_
        try {
            Undo-ContinueInstallation -GamePath $GamePath -BackupPath $backup -Rollback | Out-Null
            # Remove only empty directories created for this failed installation.
            foreach ($folder in @(Get-ChildItem -LiteralPath (Join-Path $GamePath 'BepInEx') -Recurse -Directory | Sort-Object FullName -Descending)) {
                if (@(Get-ChildItem -LiteralPath $folder.FullName -Force).Count -eq 0) {
                    Remove-Item -LiteralPath $folder.FullName
                }
            }
        }
        catch { throw ('Installation abgebrochen; automatische Wiederherstellung nicht vollstaendig. Sicherung: ' + $backup) }
        throw $failure
    }
    return @{ AlreadyInstalled = $false; BackupPath = $backup }
}
