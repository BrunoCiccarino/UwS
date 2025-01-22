function Configure-OhMyPoshTheme {
    param (
        [string]$ThemeName
    )
    $themesPath = "$env:LOCALAPPDATA\Programs\oh-my-posh\themes"
    $themeFile = Join-Path -Path $themesPath -ChildPath "$ThemeName.omp.json"
    if (-Not (Test-Path $themeFile)) {
        Write-Host "Error: Theme $ThemeName not found in $themesPath. Please ensure the theme is available."
        return
    }

    Show-Progress -Activity "Activating OhMyPosh Theme: $ThemeName" -PercentComplete 80
    $profilePath = "$env:USERPROFILE\Documents\PowerShell\Microsoft.PowerShell_profile.ps1"
    if (-Not (Test-Path $profilePath)) {
        New-Item -ItemType File -Path $profilePath -Force
    }
    "oh-my-posh init pwsh --config $themeFile | Invoke-Expression" | Out-File -FilePath $profilePath -Append -Force
    Show-Progress -Activity "OhMyPosh theme $ThemeName configuration completed" -PercentComplete 100
}

function Install-OhMyPoshThemes {
    Show-Progress -Activity "Installing OhMyPosh" -PercentComplete 20
    winget install --id JanDeDobbeleer.OhMyPosh -e
    New-Item -ItemType Directory -Path "$env:LOCALAPPDATA\Programs\oh-my-posh\themes" -Force
    Invoke-WebRequest -Uri "https://raw.githubusercontent.com/neko-night/oh-my-posh/main/themes.zip" -OutFile "$env:TEMP\themes.zip"
    Expand-Archive "$env:TEMP\themes.zip" -DestinationPath "$env:LOCALAPPDATA\Programs\oh-my-posh\themes"
    Show-Progress -Activity "Cloned OhMyPosh themes" -PercentComplete 50

    Write-Host "Which OhMyPosh theme do you want to use? (nekonight/nekonight_moon): " -NoNewline
    $themeChoice = Read-Host

    if ($themeChoice -eq "nekonight") {
        Configure-OhMyPoshTheme -ThemeName "nekonight"
    } elseif ($themeChoice -eq "nekonight_moon") {
        Configure-OhMyPoshTheme -ThemeName "nekonight_moon"
    } else {
        Write-Host "Invalid choice. Defaulting to nekonight."
        Configure-OhMyPoshTheme -ThemeName "nekonight"
    }
}
