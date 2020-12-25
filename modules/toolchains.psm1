Import-Module $PSScriptRoot\utils -Force


function Install-Ada([hashtable]$Config) {
    Write-Subaction "Setting up Alire for Ada development"

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
    Write-Subaction "Setting up Rust toolchain"

    $Arch = $Config.Arch
    $RustupURI = "https://win.rustup.rs/$Arch"

    Invoke-WebRequest $RustupURI -OutFile rustup-init.exe
    &.\rustup-init.exe -y `
        --profile $Config.Profile `
        --default-host $Config.Host `
        --default-toolchain $Config.Toolchain
    Remove-Item -Force rustup-init.exe
}

function Install-VS([hashtable]$Config) {
    Write-Subaction "Installing Visual Studio"

    Install-WithParams $Config.Packages.Main
    Invoke-Reboot
    Install-WithParams $Config.Packages.Workloads
}

function Install-WSL([hashtable]$Config) {
    Write-Subaction "Installing WSL"

    choco upgrade -y $($Config.Packages.Main)
    Invoke-Reboot
    choco upgrade -y $($Config.Packages.Distro)
}
