function Display-AsciiArt {
    $asciiArt = @'
/$$   /$$                /$$$$$$ 
| $$  | $$               /$$__  $$
| $$  | $$ /$$  /$$  /$$| $$  \__/
| $$  | $$| $$ | $$ | $$|  $$$$$$ 
| $$  | $$| $$ | $$ | $$ \____  $$
| $$  | $$| $$ | $$ | $$ /$$  \ $$
|  $$$$$$/|  $$$$$/$$$$/|  $$$$$$/
 \______/  \_____/\___/  \______/
'@
    Write-Host ""
    Write-Host "$asciiArt" -ForegroundColor Cyan
    Write-Host "Welcome to the Ultimate Windows Setup (UwS)!" -ForegroundColor Green
    Write-Host ""
}


function Show-Progress {
    param (
        [string]$Activity,
        [int]$PercentComplete
    )
    Write-Progress -Activity $Activity -PercentComplete $PercentComplete
    Start-Sleep -Milliseconds 100
}

function Install-Win11Debloat {
    Write-Host "❔ Do you want to perform a Windows debloat? (yes/no): " -NoNewline
    $response = Read-Host
    if ($response.ToLower() -eq "yes") {
        try {
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
                Write-Host "❌ Error: Win11Debloat.ps1 not found. Please check the download path."
            }
        } catch {
            Write-Host "❌ An error occurred during the debloat process: $_"
        }
    }
}

function Install-Terminal {
    Write-Host "❔ Which terminal do you want to install? (windows-terminal/alacritty/wezterm): " -NoNewline
    $terminalChoice = Read-Host

    try {
        switch ($terminalChoice.ToLower()) {
            "windows-terminal" {
                Show-Progress -Activity "Installing Windows Terminal" -PercentComplete 30
                winget install --id Microsoft.WindowsTerminal -e
                if (Test-Path "configs\windows-terminal\settings.json") {
                    Copy-Item -Path "configs\windows-terminal\settings.json" -Destination "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json" -Force
                    Show-Progress -Activity "Configured Windows Terminal" -PercentComplete 100
                } else {
                    Write-Host "❌ Config file for Windows Terminal not found."
                }
            }
            "alacritty" {
                Show-Progress -Activity "Installing Alacritty" -PercentComplete 30
                winget install --id Alacritty.Alacritty -e
                if (Test-Path "configs\alacritty\alacritty.yml") {
                    Copy-Item -Path "configs\alacritty\alacritty.yml" -Destination "$env:APPDATA\alacritty\alacritty.yml" -Force
                    Show-Progress -Activity "Configured Alacritty" -PercentComplete 100
                } else {
                    Write-Host "❌ Config file for Alacritty not found."
                }
            }
            "wezterm" {
                Show-Progress -Activity "Installing WezTerm" -PercentComplete 30
                winget install --id WezWezTerm -e
                if (Test-Path "configs\wezterm\wezterm.lua") {
                    Copy-Item -Path "configs\wezterm\wezterm.lua" -Destination "$env:USERPROFILE\.wezterm.lua" -Force
                    Show-Progress -Activity "Configured WezTerm" -PercentComplete 100
                } else {
                    Write-Host "❌ Config file for WezTerm not found."
                }
            }
            default {
                Write-Host "❌ Invalid terminal choice. Exiting."
            }
        }
    } catch {
        Write-Host "❌ An error occurred while installing the terminal: $_"
    }
}

function Install-Neovim {
    Write-Host "❔ Do you want to install Neovim? (yes/no): " -NoNewline
    $terminalChoice = Read-Host
    switch ($terminalChoice.ToLower()) {
        "yes" {
            Show-Progress -Activity "Installing Neovim" -PercentComplete 30
            try {
                winget install Neovim.Neovim -e
            } catch {
                Write-Host "❌ An error occurred while installing Neovim: $_"
            }
        }
        "no" {
            try {
                if (Test-Path ".\oh-my-posh.ps1") {
                    . .\oh-my-posh.ps1
                    Install-OhMyPoshThemes
                } else {
                    Write-Host "❌ oh-my-posh.ps1 script not found."
                }
            } catch {
                Write-Host "❌ An error occurred while configuring Oh My Posh: $_"
            }
        }
        default {
            Write-Host "❌ Invalid choice. Please enter 'yes' or 'no'."
        }
    }
}

try {
    . .\oh-my-posh.ps1
    Display-AsciiArt
    Install-Win11Debloat
    Install-Terminal
    Install-OhMyPoshThemes
    Write-Host "✅ Setup complete! Enjoy your optimized Windows experience."
} catch {
    Write-Host "❌ An error occurred during setup: $_"
}
