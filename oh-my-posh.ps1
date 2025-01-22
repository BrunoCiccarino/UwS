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

    $themesPath = "$env:LOCALAPPDATA\Programs\oh-my-posh\themes"
    New-Item -ItemType Directory -Path $themesPath -Force

    $themeUrls = @{
        "nekonight"       = "https://raw.githubusercontent.com/neko-night/oh-my-posh/refs/heads/main/nekonight.omp.json"
        "nekonight_moon"  = "https://raw.githubusercontent.com/neko-night/oh-my-posh/refs/heads/main/nekonight_moon.omp.json"
        "dracula"         = "https://raw.githubusercontent.com/dracula/oh-my-posh/refs/heads/master/dracula.omp.json"
    }

    foreach ($themeName in $themeUrls.Keys) {
        $themeUrl = $themeUrls[$themeName]
        $themeFilePath = Join-Path -Path $themesPath -ChildPath "$themeName.omp.json"
        Invoke-WebRequest -Uri $themeUrl -OutFile $themeFilePath
    }
    Show-Progress -Activity "Downloaded OhMyPosh themes" -PercentComplete 50

    Write-Host "Which OhMyPosh theme do you want to use? (nekonight/nekonight_moon/dracula): " -NoNewline
    $themeChoice = Read-Host

    if ($themeUrls.ContainsKey($themeChoice)) {
        Configure-OhMyPoshTheme -ThemeName $themeChoice
    } else {
        Write-Host "Invalid choice. Defaulting to nekonight."
        Configure-OhMyPoshTheme -ThemeName "nekonight"
    }
}
