Import-Module $PSScriptRoot\utils -Force


function Rename-Box([string]$Name) {
    Write-Action "Renaming computer"
    Rename-Computer -NewName $Name
}

function Enable-WindowsFeatures(
    [System.Collections.Specialized.OrderedDictionary]$Capabilities,
    [System.Collections.Specialized.OrderedDictionary]$Features
) {
    Write-Action "Enabling Windows capabilities and features"

    foreach ($Capability in $Capabilities.Values) {
        Add-WindowsCapability -Online -Name $Capability
    }

    foreach ($Feature in $Features.Values) {
        Enable-WindowsOptionalFeature -Online -FeatureName $Feature -All
    }

    # Should restart after this.
}

function Install-Packages(
    [hashtable]$PackageList,
    [hashtable]$ParametrisedPackages
) {
    Write-Action "Installing packages"

    Install-WithParams $ParametrisedPackages
    Install-List $PackageList
}

function Install-VS([hashtable]$Packages) {
    Write-Action "Installing Visual Studio"

    Install-WithParams $Packages.Main
    # Should restart after this.
    Install-WithParams $Packages.Workloads
}

function Install-WSL([string]$Distro="wsl-ubuntu-2004") {
    Write-Action "Installing WSL"

    choco upgrade -y wsl
    # Should restart after this.
    choco upgrade -y $Distro
}

function Install-Alire([string]$Version) {
    Write-Action "Setting up Alire for Ada development"

    $AlireRepo = "https://github.com/alire-project/alire"
    $AlireURI = "$AlireRepo/releases/download/v$Version/alr-$Version-bin-windows.zip"

    Invoke-WebRequest $AlireURI -OutFile alr.zip
    7z e .\alr.zip bin\alr.exe
    Remove-Item -Force alr.zip

    New-Item -ItemType Directory -Force -Path $HOME\bin
    Move-Item .\alr.exe "$HOME\bin\alr.exe"
}

function Install-Rust {
    Write-Action "Setting up Rust toolchain"

    $RustupURI = "https://win.rustup.rs/x86_64"

    Invoke-WebRequest $RustupURI -OutFile rustup-init.exe
    &.\rustup-init.exe -y
    Remove-Item -Force rustup-init.exe
}

function Copy-Configs([hashtable]$Configs) {
    foreach ($ConfigFiles in $Configs.Values) {
        foreach ($ConfigFile in $ConfigFiles) {
            $Contents = $ConfigFile.Contents
            $Destination = $ConfigFile.Destination

        Copy-Item $Contents -Destination $Destination -WhatIf
    }
}
}

function Copy-ManualPackages([string]$Source) {
    Copy-Item -Recurse -Path $Source -Destination "$HOME\Desktop"
}

function Set-Registry([hashtable]$RegFiles) {
    foreach ($RegFile in $RegFiles.Values) {
        Write-Host "reg import $RegFile"
    }
}
