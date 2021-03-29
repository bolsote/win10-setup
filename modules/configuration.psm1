Import-Module $PSScriptRoot\utils -Force

if (Test-PSCore) {
    Import-Module Appx -UseWindowsPowerShell
}


$ComputerName = "nepomuceno"

$Windows = @{
    Caps     = [ordered]@{
        ssh = "OpenSSH.Client~~~~0.0.1.0";
    }
    Features = [ordered]@{
        HyperV  = "Microsoft-Hyper-V"
        Sandbox = "Containers-DisposableClientVM"
    }
}

$Packages = @{
    Categories   = @{
        Development = @(
            "autohotkey"
            "boxstarter"
            "cuda"
            "deno"
            "dotnet"
            "imhex"
            "julia"
            "git-credential-manager-for-windows"
            "gnat-gpl"
            "linqpad"
            "nvs"
            "openjdk"
            "python3"
            "sourcetrail"
            "velocity"
            "winmerge"
        )
        Games       = @(
            "goggalaxy"
            "steam-client"
        )
        Images      = @(
            "irfanview"
            "irfanviewplugins"
        )
        LaTeX       = @(
            "lyx"
        )
        Media       = @(
            "amazon-music"
            "eac"
            "freac"
            "freeencoderpack"
            "k-litecodecpack-standard"
            "lossless-audio-checker"
            "pov-ray"
            "reaper"
            "vlc"
            "voicemeeter-banana.install"
        )
        Net         = @(
            "aria2"
            "bitwarden"
            "googlechrome"
            "nmap"
            "putty.install"
            "tailscale"
            "ultravnc"
            "vivaldi"
            "wakemeonlan"
            "wifiinfoview"
            "winscp"
            "wireshark"
        )
        Office      = @(
            "adobedigitaleditions"
            "sumatrapdf"
        )
        System      = @(
            "drmemory"
            "hwmonitor"
            "intelpowergadget"
            "perfview"
            "processhacker"
            "sysinternals"
            "uiforetw"
        )
        Terminal    = @(
            "powershell-core"
            "microsoft-windows-terminal"
            "gsudo"
            "starship"
            "colortool"
            "pswindowsupdate"
            "burnttoast-psmodule"
            "pester"
        )
        Tools       = @(
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
    Parametrized = @{
        everything     = @(
            "/client-service"
            "/folder-context-menu"
            "/run-on-system-startup"
            "/start-menu-shortcuts"
        )
        foobar2000     = @("/NoShortcut")
        git            = @(
            "/WindowsTerminal"
            "/NoShellIntegration"
            "/GitAndUnixToolsOnPath"
        )
        miktex         = @("/Set:basic")
        msys2          = @("/NoUpdate")
        totalcommander = @("/ShellExtension")
        vscode         = @("/NoDesktopIcon")
    }
}

$Toolchains = @{
    Ada          = @{
        AlireVersion = "1.0.0"
    }
    Rust         = @{
        Arch      = "x86_64"
        Host      = "x86_64-pc-windows-msvc"
        Profile   = "default"
        Toolchain = "stable"
    }
    VisualStudio = @{
        Packages = @{
            Main      = @{
                "visualstudio2019community" = @(
                    "--no-update"
                )
            }
            Workloads = @{
                "visualstudio2019-workload-nativecrossplat" = @(
                    "--no-includeRecommended"
                    "--add Component.Linux.CMake"
                )
                "visualstudio2019-workload-nativedesktop"   = @(
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
    }
    WSL          = @{
        Packages = @{
            Main   = "wsl"
            Distro = "wsl-ubuntu-2004"
        }
    }
}


$SetupRoot = Split-Path $PSScriptRoot -Parent

$Dirs = @{
    Configurations = Join-Path $SetupRoot "config"
    Registry       = Join-Path $SetupRoot "registry"
    Licenses       = "$env:OneDrive\Configurations\win\keys"
    ManualPackages = "$env:OneDrive\Configurations\Win\soft"
}

$TerminalPackageName = (Get-AppxPackage -Name Microsoft.WindowsTerminal).PackageFamilyName

$ConfigFiles = @{
    terminal = @(
        @{
            Contents    = "$($Dirs.Configurations)\terminal\profile.ps1"
            Destination = "$profile"
        }
        @{
            Contents    = "$($Dirs.Configurations)\terminal\terminal.json"
            Destination = "$env:LOCALAPPDATA\Packages\$TerminalPackageName\LocalState\settings.json"
        }
    )
    git      = @(
        @{
            Contents    = "$($Dirs.Configurations)\git\gitconfig"
            Destination = "$env:USERPROFILE\.gitconfig"
        }
        @{
            Contents    = "$($Dirs.Configurations)\git\gitignore_global"
            Destination = "$env:USERPROFILE\.gitignore_global"
        }
    )
    alire    = @(
        @{
            Contents    = "$($Dirs.Configurations)\alire.toml"
            Destination = "$env:USERPROFILE\.config\alire\config.toml"
        }
    )
    totalcmd = @(
        @{
            Contents    = "$($Dirs.Licenses)\totalcmd.key"
            Destination = "$env:ProgramFiles\totalcmd\WINCMD.KEY"
        }
        @{
            Contents    = "$($Dirs.Configurations)\totalcmd\totalcmd.ini"
            Destination = "$env:APPDATA\GHISLER\wincmd.ini"
        }
        @{
            Contents    = "$($Dirs.Configurations)\totalcmd\default.bar"
            Destination = "$env:APPDATA\GHISLER\default.bar"
        }
        @{
            Contents    = "$($Dirs.Configurations)\totalcmd\vertical.bar"
            Destination = "$env:APPDATA\GHISLER\vertical.bar"
        }
    )
    reaper   = @(
        @{
            Contents    = "$($Dirs.Licenses)\reaper.key"
            Destination = "$env:APPDATA\REAPER\reaper-license.rk"
        }
    )
}

$RegFiles = @{
    putty = "$($Dirs.Registry)\putty.reg"
}


Export-ModuleMember -Variable *
