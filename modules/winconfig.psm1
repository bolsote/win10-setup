function Install-Boxstarter {
    Set-ExecutionPolicy Unrestricted -Force

    $BootstrapScript = "https://boxstarter.org/bootstrapper.ps1"

    . { Invoke-WebRequest -UseBasicParsing $BootstrapScript } | Invoke-Expression
    Get-Boxstarter -Force

    Copy-Item .\setup.profile.ps1 -Destination $profile
    . $profile
}

function Pre {
    Disable-MicrosoftUpdate
    Disable-UAC
}

function Post {
    Enable-UAC
    Enable-MicrosoftUpdate

    Install-WindowsUpdate -acceptEula
}

function Enable-DevMode {
    $Path = "HKLM:\Software\Microsoft\Windows\CurrentVersion\AppModelUnlock"
    $Key = "AllowDevelopmentWithoutDevLicense"

    Set-ItemProperty -Path $Path -Name $Key -Value 1
}

function Set-WindowsSettings {
    Pre

    Set-WindowsExplorerOptions `
        -EnableShowFileExtensions `
        -EnableShowHiddenFilesFoldersDrives `
        -DisableShowProtectedOSFiles `
        -EnableShowFullPathInTitleBar `
        -EnableOpenFileExplorerToQuickAccess `
        -EnableShowRecentFilesInQuickAccess `
        -EnableShowFrequentFoldersInQuickAccess `
        -EnableExpandToOpenFolder

    Set-BoxstarterTaskbarOptions `
        -Combine Always `
        -AlwaysShowIconsOff `
        -MultiMonitorOn `
        -MultiMonitorMode All `
        -MultiMonitorCombine Always

    Enable-DevMode

    Post
}

Export-ModuleMember -Function Install-Boxstarter, Set-WindowsSettings
