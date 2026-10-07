$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'Installer.Core.ps1')
function Assert-True($Condition, $Message) { if (!$Condition) { throw $Message } }
function Write-Fixture($Path, $Text) {
    New-Item -ItemType Directory -Path (Split-Path $Path) -Force | Out-Null
    [IO.File]::WriteAllText($Path, $Text)
}
function New-Game($Name) {
    $game = Join-Path $root $Name
    Write-Fixture (Join-Path $game 'valheim.exe') 'original game'
    return $game
}
function New-Loader($Game) {
    Write-Fixture (Join-Path $Game 'BepInEx/core/BepInEx.dll') 'existing loader'
    Write-Fixture (Join-Path $Game 'winhttp.dll') 'existing doorstop'
    Write-Fixture (Join-Path $Game 'doorstop_config.ini') 'existing startup'
}
$root = Join-Path ([IO.Path]::GetTempPath()) ('Continue tests [special] ' + [Guid]::NewGuid().ToString('N'))
$plugin = Join-Path $root 'input/ValheimContinue.dll'
$pack = Join-Path $root 'pack'
$passed = 0
try {
    # Parse every distributed PowerShell file before exercising its functions.
    foreach ($file in @(Get-ChildItem -LiteralPath $PSScriptRoot -Filter '*.ps1')) {
        $tokens = $null; $errors = $null
        [Management.Automation.Language.Parser]::ParseFile($file.FullName, [ref]$tokens, [ref]$errors) | Out-Null
        Assert-True ($errors.Count -eq 0) ('Parse failed: ' + $file.Name)
    }
    $passed++
    Write-Fixture $plugin 'new plugin'
    New-Loader $pack
    Write-Fixture (Join-Path $pack 'BepInEx/config/BepInEx.cfg') 'default loader config'

    $steam = Join-Path $root 'Steam root'
    $library = Join-Path $root 'Other library'
    Write-Fixture (Join-Path $steam 'steamapps/libraryfolders.vdf') ('"libraryfolders" { "0" { "path" "' + $steam.Replace('\','\\') + '" } "1" { "path" "' + $library.Replace('\','\\') + '" } }')
    Write-Fixture (Join-Path $library 'steamapps/appmanifest_892970.acf') '"AppState" { "installdir" "Valheim" }'
    Write-Fixture (Join-Path $library 'steamapps/common/Valheim/valheim.exe') 'game'
    $found = @(Find-ValheimInstallations -SteamRoots @($steam))
    Assert-True ($found.Count -eq 1 -and $found[0] -eq (Join-Path $library 'steamapps/common/Valheim')) 'Secondary Steam library not detected'
    $passed++

    $game = New-Game 'clean install'
    $result = Install-ContinueFiles $game $plugin $pack
    Assert-True ((Get-Content -LiteralPath (Join-Path $game 'valheim.exe') -Raw) -eq 'original game') 'Game executable changed'
    Assert-True ((Get-Content -LiteralPath (Join-Path $game 'BepInEx/plugins/ValheimContinue/ValheimContinue.dll') -Raw) -eq 'new plugin') 'Plugin not installed'
    Assert-True ((Get-Content -LiteralPath (Join-Path $result.BackupPath 'manifest.json') -Raw | ConvertFrom-Json).Status -eq 'Installed') 'Install journal not complete'
    $second = Install-ContinueFiles $game $plugin $pack
    Assert-True $second.AlreadyInstalled 'Repeated installation was not idempotent'
    $passed++

    $skipped = @(Undo-ContinueInstallation $game $result.BackupPath -KeepLoader)
    Assert-True ($skipped.Count -eq 0) 'Uninstall skipped an unchanged file'
    Assert-True (!(Test-Path -LiteralPath (Join-Path $game 'BepInEx/plugins/ValheimContinue/ValheimContinue.dll'))) 'Plugin remains after uninstall'
    Assert-True (Test-Path -LiteralPath (Join-Path $game 'BepInEx/core/BepInEx.dll')) 'Uninstall removed shared loader'
    $passed++

    $game = New-Game 'existing mods'
    New-Loader $game
    $target = Join-Path $game 'BepInEx/plugins/ValheimContinue/ValheimContinue.dll'
    Write-Fixture $target 'old plugin'
    Write-Fixture (Join-Path $game 'BepInEx/config/hellcat.valheim.continue.cfg') 'private settings sentinel'
    Write-Fixture (Join-Path $game 'BepInEx/plugins/OtherMod.dll') 'other mod'
    $result = Install-ContinueFiles $game $plugin ''
    Assert-True ((Get-Content -LiteralPath (Join-Path $game 'BepInEx/core/BepInEx.dll') -Raw) -eq 'existing loader') 'Existing loader overwritten'
    Assert-True ((Get-Content -LiteralPath (Join-Path $game 'BepInEx/config/hellcat.valheim.continue.cfg') -Raw) -eq 'private settings sentinel') 'Private configuration changed'
    Undo-ContinueInstallation $game $result.BackupPath -KeepLoader | Out-Null
    Assert-True ((Get-Content -LiteralPath $target -Raw) -eq 'old plugin') 'Old plugin not restored'
    Assert-True ((Get-Content -LiteralPath (Join-Path $game 'BepInEx/plugins/OtherMod.dll') -Raw) -eq 'other mod') 'Other mod changed'
    $passed++

    $result = Install-ContinueFiles $game $plugin ''
    Write-Fixture $target 'changed after install'
    $skipped = @(Undo-ContinueInstallation $game $result.BackupPath -KeepLoader)
    Assert-True ($skipped.Count -eq 1 -and (Get-Content -LiteralPath $target -Raw) -eq 'changed after install') 'Restoration overwrote later changes'
    $passed++

    $conflict = New-Game 'conflicting loader'
    Write-Fixture (Join-Path $conflict 'winhttp.dll') 'unrelated loader'
    $rejected = $false
    try { Install-ContinueFiles $conflict $plugin $pack | Out-Null } catch { $rejected = $true }
    Assert-True ($rejected -and (Get-Content -LiteralPath (Join-Path $conflict 'winhttp.dll') -Raw) -eq 'unrelated loader') 'Conflicting loader not preserved'
    $passed++

    $conflict = New-Game 'duplicate plugin'
    New-Loader $conflict
    Write-Fixture (Join-Path $conflict 'BepInEx/plugins/ValheimContinue.dll') 'old flat plugin'
    $rejected = $false
    try { Install-ContinueFiles $conflict $plugin '' | Out-Null } catch { $rejected = $true }
    Assert-True ($rejected -and !(Test-Path -LiteralPath (Join-Path $conflict 'BepInEx/plugins/ValheimContinue/ValheimContinue.dll'))) 'Duplicate plugin installation allowed'
    $passed++

    $game = New-Game 'copy failure'
    New-Loader $game
    $target = Join-Path $game 'BepInEx/plugins/ValheimContinue/ValheimContinue.dll'
    Write-Fixture $target 'restore on failure'
    $script:failNext = $true
    function Copy-Item {
        param($LiteralPath, $Destination, [switch]$Force)
        if ($LiteralPath -eq $plugin -and $script:failNext) {
            $script:failNext = $false
            [IO.File]::WriteAllText($Destination, 'partial write')
            throw 'Simulated write failure'
        }
        Microsoft.PowerShell.Management\Copy-Item -LiteralPath $LiteralPath -Destination $Destination -Force:$Force
    }
    $rejected = $false
    try { Install-ContinueFiles $game $plugin '' | Out-Null } catch { $rejected = $true }
    Remove-Item Function:\Copy-Item
    Assert-True ($rejected -and (Get-Content -LiteralPath $target -Raw) -eq 'restore on failure') 'Copy failure did not roll back'
    $passed++

    $game = New-Game 'clean failure then retry'
    $target = Join-Path $game 'BepInEx/plugins/ValheimContinue/ValheimContinue.dll'
    $script:failNext = $true
    function Copy-Item {
        param($LiteralPath, $Destination, [switch]$Force)
        if ($LiteralPath -eq $plugin -and $script:failNext) {
            $script:failNext = $false
            throw 'Simulated clean installation failure'
        }
        Microsoft.PowerShell.Management\Copy-Item -LiteralPath $LiteralPath -Destination $Destination -Force:$Force
    }
    $rejected = $false
    try { Install-ContinueFiles $game $plugin $pack | Out-Null } catch { $rejected = $true }
    Remove-Item Function:\Copy-Item
    Assert-True ($rejected -and !(Test-Path -LiteralPath (Join-Path $game 'winhttp.dll'))) 'Failed clean install left loader files'
    $result = Install-ContinueFiles $game $plugin $pack
    Assert-True (Test-Path -LiteralPath $target) 'Retry after rollback failed'
    $passed++

    $rejected = $false
    try { Assert-FileHash $plugin ('0' * 64) } catch { $rejected = $true }
    Assert-True $rejected 'Wrong download checksum accepted'
    $rejected = $false
    try { Resolve-InstallerChild $root '../outside.txt' | Out-Null } catch { $rejected = $true }
    Assert-True $rejected 'Path outside game directory accepted'
    $passed++
    Write-Host ('PASS: ' + $passed + ' installer scenarios; no real game files used.')
} finally {
    if (Test-Path -LiteralPath $root) { Remove-Item -LiteralPath $root -Recurse -Force }
}
