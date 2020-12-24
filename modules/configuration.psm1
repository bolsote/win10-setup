$script:ComputerName = "nepomuceno"

$script:AlireVersion = "0.7.1"


$script:WindowsCaps = [ordered]@{
    ssh = "OpenSSH.Client~~~~0.0.1.0";
}

$script:WindowsFeatures = [ordered]@{
    HyperV = "Microsoft-Hyper-V"
    Sandbox = "Containers-DisposableClientVM"
}

$script:Packages = @{
    Development = @(
        "autohotkey"
        "boxstarter"
        "cuda"
        "deno"
        "dotnet"
        "julia"
        "git-credential-manager-for-windows"
        "gnat-gpl"
        "linqpad"
        "nvs"
        "openjdk"
        "python3"
        "winmerge"
    )
    Games = @(
        "goggalaxy"
        "steam"
    )
    Images = @(
        "irfanview"
        "irfanviewplugins"
    )
    LaTeX = @(
        "lyx"
    )
    Media = @(
        "amazon-music"
        "eac"
        "freac"
        "freeencoderpack"
        "k-litecodecpack-standard"
        "lossless-audio-checker"
        "pov-ray"
        "reaper"
        "vlc"
    )
    Net = @(
        "aria2"
        "bitwarden"
        "googlechrome"
        "nmap"
        "putty.install"
        "vivaldi"
        "winscp"
        "wireshark"
    )
    Office = @(
        "adobedigitaleditions"
        "sumatrapdf"
    )
    System = @(
        "drmemory"
        "hwmonitor"
        "intelpowergadget"
        "perfview"
        "processhacker"
        "sysinternals"
        "uiforetw"
    )
    Terminal = @(
        "powershell-core"
        "microsoft-windows-terminal"
        "gsudo"
        "starship"
        "colortool"
        "pswindowsupdate"
        "burnttoast-psmodule"
        "pester"
    )
    Tools = @(
        "7zip.install"
        "7zip.portable"
        "barrier"
        "baregrep"
        "baretail"
        # Unavailable: "click-monitor-ddc"
        "dngrep"
        "hashtab"
        "logparser"
        "logparserstudio"
        "nimbletext"
        "vcxsrv"
        "win32diskimager.install"
        "wiztree"
        "powertoys"
        "rapr"
        "ripgrep"
        "teamviewer"
        "trid"
    )
}

$script:PackagesWithParams = @{
    everything = @(
        "/client-service"
        "/folder-context-menu"
        "/run-on-system-startup"
        "/start-menu-shortcuts"
    )
    foobar2000 = @("/NoShortcut")
    git = @(
        "/WindowsTerminal"
        "/NoShellIntegration"
        "/GitAndUnixToolsOnPath"
    )
    miktex = @("/Set:basic")
    msys2 = @("/NoUpdate")
    totalcommander = @("/ShellExtension")
    vscode = @("/NoDesktopIcon")
}

$script:VSPackages = @{
    Main = @{
        "visualstudio2019community" = @(
            "--no-update"
        )
    }
    Workloads = @{
        "visualstudio2019-workload-nativecrossplat" = @(
            "--no-includeRecommended"
            "--add Component.Linux.CMake"
        )
        "visualstudio2019-workload-nativedesktop" = @(
            "--no-includeRecommended"
            "--add Microsoft.VisualStudio.Component.Debugger.JustInTime"
            "--add Microsoft.VisualStudio.Component.VC.ASAN"
            "--add Microsoft.VisualStudio.Component.VC.CMake.Project"
            "--add Microsoft.VisualStudio.Component.VC.DiagnosticTools"
            "--add Microsoft.VisualStudio.Component.VC.TestAdapterForGoogleTest"
            "--add Microsoft.VisualStudio.Component.VC.Tools.x86.x64"
            "--add Microsoft.VisualStudio.Component.VC.Llvm.Clang"
            "--add Microsoft.VisualStudio.Component.VC.Llvm.ClangToolset"
            "--add Microsoft.VisualStudio.Component.Windows10SDK.18362"
            "--add Microsoft.VisualStudio.ComponentGroup.NativeDesktop.Llvm.Clang"
        )
    }
}


$ConfigurationsDir = "$PSScriptRoot\config"
$TerminalPackageName = (Get-AppxPackage -Name Microsoft.WindowsTerminal).PackageFamilyName

$script:ConfigFiles = @{
    profile = @{
        Contents = "$ConfigurationsDir\profile.ps1"
        Destination = "$profile"
    }
    terminal = @{
        Contents = "$ConfigurationsDir\terminal.json"
        Destination = "$env:LOCALAPPDATA\Packages\$TerminalPackageName\LocalState\settings.json"
    }
    gitconfig = @{
        Contents = "$ConfigurationsDir\gitconfig"
        Destination = "$env:USERPROFILE\.gitconfig"
    }
    gitignore = @{
        Contents = "$ConfigurationsDir\gitignore_global"
        Destination = "$env:USERPROFILE\.gitignore_global"
    }
    alire = @{
        Contents = "$ConfigurationsDir\alire.toml"
        Destination = "$env:USERPROFILE\.config\alire\config.toml"
    }
}


$script:ManualPackagesDir = "$HOME\OneDrive\Configurations\Win\soft"


Export-ModuleMember -Variable *
