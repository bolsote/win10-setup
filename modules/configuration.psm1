Import-Module $PSScriptRoot\utils -Force

if (Test-PSCore) {
    Import-Module Appx -UseWindowsPowerShell
}


$ComputerName = "nepomuceno"

$AlireVersion = "0.7.1"


$WindowsCaps = [ordered]@{
    ssh = "OpenSSH.Client~~~~0.0.1.0";
}

$WindowsFeatures = [ordered]@{
    HyperV = "Microsoft-Hyper-V"
    Sandbox = "Containers-DisposableClientVM"
}

$Packages = @{
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

$PackagesWithParams = @{
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

$VSPackages = @{
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


$ConfigurationsDir = Join-Path (Split-Path $PSScriptRoot -Parent) "config"
$LicensesDir = "$env:OneDrive\Configurations\win\keys"

$TerminalPackageName = (Get-AppxPackage -Name Microsoft.WindowsTerminal).PackageFamilyName

$ConfigFiles = @{
    terminal  = @(
        @{
            Contents    = "$ConfigurationsDir\terminal\profile.ps1"
            Destination = "$profile"
        }
        @{
            Contents = "$ConfigurationsDir\terminal\terminal.json"
            Destination = "$env:LOCALAPPDATA\Packages\$TerminalPackageName\LocalState\settings.json"
        }
    )
    git = @(
        @{
            Contents = "$ConfigurationsDir\git\gitconfig"
            Destination = "$env:USERPROFILE\.gitconfig"
        }
        @{
            Contents = "$ConfigurationsDir\git\gitignore_global"
            Destination = "$env:USERPROFILE\.gitignore_global"
        }
    )
    alire = @(
        @{
            Contents = "$ConfigurationsDir\alire.toml"
            Destination = "$env:USERPROFILE\.config\alire\config.toml"
        }
    )
    totalcmd = @(
        @{
            Contents = "$LicensesDir\totalcmd.key"
            Destination = "$env:ProgramFiles\totalcmd\WINCMD.KEY"
        }
        @{
            Contents = "$ConfigurationsDir\totalcmd\totalcmd.ini"
            Destination = "$env:APPDATA\GHISLER\wincmd.ini"
        }
        @{
            Contents    = "$ConfigurationsDir\totalcmd\default.bar"
            Destination = "$env:APPDATA\GHISLER\default.bar"
        }
        @{
            Contents    = "$ConfigurationsDir\totalcmd\vertical.bar"
            Destination = "$env:APPDATA\GHISLER\vertical.bar"
        }
    )
    reaper = @(
        @{
            Contents    = "$LicensesDir\reaper.key"
            Destination = "$env:APPDATA\REAPER\reaper-license.rk"
        }
    )
}


$ManualPackagesDir = "$env:USERPROFILE\OneDrive\Configurations\Win\soft"


Export-ModuleMember -Variable *
