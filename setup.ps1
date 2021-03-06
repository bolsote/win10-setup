Import-Module $PSScriptRoot\modules\configuration -Force
Import-Module $PSScriptRoot\modules\actions -Force
Import-Module $PSScriptRoot\modules\winconfig -Force


Install-Boxstarter

Set-WindowsSettings
Rename-Box $ComputerName
Enable-WindowsFeatures $Windows

Install-Packages $Packages
Install-Toolchains $Toolchains

Copy-Configs $ConfigFiles
Copy-ManualPackages $Dirs.ManualPackages
Set-Registry $RegFiles
