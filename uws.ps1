Write-Host "Welcome to the Ultimate Windows Setup (UwS)!"

function Show-Progress {
    param (
        [string]$Activity,
        [int]$PercentComplete
    )
    Write-Progress -Activity $Activity -PercentComplete $PercentComplete
    Start-Sleep -Milliseconds 100
}

function Install-Win11Debloat {
    Write-Host "Do you want to perform a Windows debloat? (yes/no): " -NoNewline
    $response = Read-Host
    if ($response -eq "yes") {
        Show-Progress -Activity "Downloading Win11Debloat" -PercentComplete 10

        $tempPath = [System.IO.Path]::GetTempPath()
        $zipPath = Join-Path -Path $tempPath -ChildPath "win11debloat-temp.zip"
        $extractPath = Join-Path -Path $tempPath -ChildPath "Win11Debloat"

        Invoke-WebRequest -Uri "http://github.com/raphire/win11debloat/archive/master.zip" -OutFile $zipPath
        Expand-Archive -Path $zipPath -DestinationPath $extractPath -Force

        $debloatScriptPath = Join-Path -Path $extractPath -ChildPath "win11debloat-master\Win11Debloat.ps1"

        if (Test-Path $debloatScriptPath) {
            Show-Progress -Activity "Launching Win11Debloat interface as Administrator" -PercentComplete 50
            Start-Process -FilePath "powershell.exe" `
                          -ArgumentList "-ExecutionPolicy Bypass -File `"$debloatScriptPath`"" `
                          -Verb RunAs
            Show-Progress -Activity "Completed Windows debloat" -PercentComplete 100
        } else {
            Write-Host "Error: Win11Debloat.ps1 not found. Please check the download path."
        }
    }
}

function Install-Terminal {
    Write-Host "Which terminal do you want to install? (windows-terminal/alacritty/wezterm): " -NoNewline
    $terminalChoice = Read-Host

    if ($terminalChoice -eq "windows-terminal") {
        Show-Progress -Activity "Installing Windows Terminal" -PercentComplete 30
        winget install --id Microsoft.WindowsTerminal -e
        Copy-Item -Path "configs\windows-terminal\settings.json" -Destination "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json" -Force
        Show-Progress -Activity "Configured Windows Terminal" -PercentComplete 100
    } elseif ($terminalChoice -eq "alacritty") {
        Show-Progress -Activity "Installing Alacritty" -PercentComplete 30
        winget install --id Alacritty.Alacritty -e
        Copy-Item -Path "configs\alacritty\alacritty.yml" -Destination "$env:APPDATA\alacritty\alacritty.yml" -Force
        Show-Progress -Activity "Configured Alacritty" -PercentComplete 100
    } elseif ($terminalChoice -eq "wezterm") {
        Show-Progress -Activity "Installing WezTerm" -PercentComplete 30
        winget install --id WezWezTerm -e
        Copy-Item -Path "configs\wezterm\wezterm.lua" -Destination "$env:USERPROFILE\.wezterm.lua" -Force
        Show-Progress -Activity "Configured WezTerm" -PercentComplete 100
    } else {
        Write-Host "Invalid choice. Exiting."
        exit
    }
}

. .\oh-my-posh.ps1

Install-Win11Debloat
Install-Terminal
Install-OhMyPoshThemes

Write-Host "Setup complete! Enjoy your optimized Windows experience."
