Import-Module $PSScriptRoot\toolchains -Force
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

    Invoke-Reboot
}

function Install-Packages([hashtable]$Packages) {
    Write-Action "Installing packages"

    Install-WithParams $Packages.Parametrized
    Install-List $Packages.Categories
    Install-List $Packages.WSL
}

function Install-Toolchains([hashtable]$Config) {
    Write-Action "Setting up toolchains"

    Install-Ada $Config.Ada
    Install-Rust $Config.Rust
    Install-VS $Config.VisualStudio
    Install-WSL $Config.WSL
}

function Copy-Configs([hashtable]$Configs) {
    Write-Action "Copying configuration files"

    foreach ($ConfigFiles in $Configs.Values) {
        foreach ($ConfigFile in $ConfigFiles) {
            $Contents = $ConfigFile.Contents
            $Destination = $ConfigFile.Destination

            Copy-Item $Contents -Destination $Destination
        }
    }
}

function Copy-ManualPackages([string]$Source) {
    Write-Action "Copying packages for manual installation"

    Copy-DirContents $Source "$HOME\Desktop"
}

function Set-Registry([hashtable]$RegFiles) {
    Write-Action "Modifying registry"

    foreach ($RegFile in $RegFiles.Values) {
        reg import $RegFile
    }
}
