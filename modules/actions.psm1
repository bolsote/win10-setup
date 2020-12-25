Import-Module $PSScriptRoot\utils -Force


function Rename-Box([string]$Name) {
    Write-Action "Renaming computer"
    Rename-Computer -NewName $Name
}

function Enable-WindowsFeatures([hashtable]$Features) {
    Write-Action "Enabling Windows capabilities and features"

    foreach ($Capability in $Features.Caps.Values) {
        Add-WindowsCapability -Online -Name $Capability
    }

    foreach ($Feature in $Features.Features.Values) {
        Enable-WindowsOptionalFeature -Online -FeatureName $Feature -All
    }

    # Invoke-Reboot
}

function Install-Packages([hashtable]$Packages) {
    Write-Action "Installing packages"

    Install-WithParams $Packages.Parametrized
    Install-List $Packages.Categories
    Install-List $Packages.WSL
}

function Install-Ada([hashtable]$Config) {
    Write-Action "Setting up Alire for Ada development"

    $Version = $Config.AlireVersion
    $AlireRepo = "https://github.com/alire-project/alire"
    $AlireURI = "$AlireRepo/releases/download/v$Version/alr-$Version-bin-windows.zip"

    Invoke-WebRequest $AlireURI -OutFile alr.zip
    7z e .\alr.zip bin\alr.exe
    Remove-Item -Force alr.zip

    New-Item -ItemType Directory -Force -Path "$HOME\bin"
    Move-Item .\alr.exe "$HOME\bin\alr.exe"
}

function Install-Rust([hashtable]$Config) {
    Write-Action "Setting up Rust toolchain"

    $Arch = $Config.Arch
    $RustupURI = "https://win.rustup.rs/$Arch"

    Invoke-WebRequest $RustupURI -OutFile rustup-init.exe
    &.\rustup-init.exe -y
    Remove-Item -Force rustup-init.exe
}

function Install-VS([hashtable]$Config) {
    Write-Action "Installing Visual Studio"

    Install-WithParams $Config.Packages.Main
    # Invoke-Reboot
    Install-WithParams $Config.Packages.Workloads
}

function Install-WSL([hashtable]$Config) {
    Write-Action "Installing WSL"

    choco upgrade -y $($Config.Packages.Main)
    # Invoke-Reboot
    choco upgrade -y $($Config.Packages.Distro)
}

function Install-Toolchains([hashtable]$Config) {
    Install-Ada $Config.Ada
    Install-Rust $Config.Rust
    Install-VS $Config.VisualStudio
    Install-WSL $Config.WSL
}

function Copy-Configs([hashtable]$Configs) {
    foreach ($ConfigFiles in $Configs.Values) {
        foreach ($ConfigFile in $ConfigFiles) {
            $Contents = $ConfigFile.Contents
            $Destination = $ConfigFile.Destination

            Copy-Item $Contents -Destination $Destination
        }
    }
}

function Copy-ManualPackages([string]$Source) {
    Copy-DirContents $Source "$HOME\Desktop"
}

function Set-Registry([hashtable]$RegFiles) {
    foreach ($RegFile in $RegFiles.Values) {
        reg import $RegFile
    }
}
