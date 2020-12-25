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
Copy-ManualPackages $Dirs.ManualPackages
Copy-Scripts $Dirs.Scripts
Set-Registry $RegFiles
