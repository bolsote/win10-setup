Import-Module $PSScriptRoot\modules\configuration -Force
Import-Module $PSScriptRoot\modules\actions -Force


Rename-Box $ComputerName
Enable-WindowsFeatures $WindowsCaps $WindowsFeatures

Install-Packages $Packages $PackagesWithParams
Install-VS $VSPackages
Install-WSL

Install-Alire $AlireVersion
Install-Rust

Copy-Configs $ConfigFiles
Copy-ManualPackages
Set-Registry $RegFiles
