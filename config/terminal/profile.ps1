#region Utilities
function Add-Path([string[]]$Paths = '.') {
	# Add directories to the Path environment variable.

	foreach ($Path in $Paths) {
		$PathArray = ${Env:Path}.Trim(';') -Split ';'
		$PathArray += $Path
		${Env:Path} = $PathArray -Join ';'
	}
}

function Get-CmdEnv([string]$Cmd, [string[]]$CmdArgs) {
	# Given a batch file, return the environment it sets in a hash map.

	$OldEnv = &cmd /c set
	$NewEnv = &cmd /c "call `"$Cmd`" $($CmdArgs -Join ' ') > nul && set"

	$EnvVars = @{}
	foreach ($Var in $NewEnv) {
		if ($OldEnv -NotContains $Var) {
			$Name, $Value = $Var -Split '='
			$EnvVars.Add($Name, $Value)
		}
	}

	return $EnvVars
}

function Copy-CmdEnv([string]$Cmd, [string[]]$CmdArgs) {
	# Given a batch file, set the PS environment based on it.

	$CmdEnv = Get-CmdEnv $Cmd $CmdArgs

	foreach ($EnvVar in $CmdEnv.GetEnumerator()) {
		Set-Item "Env:$($EnvVar.Name)" "$($EnvVar.Value)"
	}
}
#endregion Utilities

#region Python
function Set-VEnv([string]$VEnv = 've') {
	# Activate a Python virtual environment in the current directory.
	# Virtual environment name defaults to 've'.

	$VEA = Join-Path $VEnv 'Scripts\activate.ps1'
	&"$VEA"
}
#endregion Python

#region VS
function FindVS([string]$Property = "installationPath") {
	$VSWhere = "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\VSWhere.exe"

	return &$VSWhere -latest -property $Property
}

function VSShell {
	$InstanceId = FindVS instanceId
	$Path = FindVS installationPath

	Import-Module "$Path\Common7\Tools\Microsoft.VisualStudio.DevShell.dll"
	Enter-VSDevShell $InstanceId
}

function VCShell {
	param (
		[Parameter(Mandatory = $True)]
		[ValidateSet(
			"x64", "x64_x86", "x64_arm", "x64_arm64",
			"x86", "x86_x64", "x86_arm", "x86_arm64", "x86_amd64",
			"amd64", "amd64_x86", "amd64_arm", "amd64_arm64"
		)]
		[string]
		$Arch,

		[switch]$UWP,
		[switch]$Spectre,

		[string]$WinSDK,
		[string]$VCpp

	)

	$Path = FindVS installationPath

	$VCVarsAll = "$Path\VC\Auxiliary\Build\vcvarsall.bat"
	$VCVarsArgs = [System.Collections.ArrayList]@($Arch)

	if ($UWP) { [void]$VCVarsArgs.Add("uwp") }
	if ($WinSDK) { [void]$VCVarsArgs.Add($WinSDK) }
	if ($VCpp) { [void]$VCVarsArgs.Add("-vcvars_ver=$VCpp") }
	if ($Spectre) { [void]$VCVarsArgs.Add("-vcvars_spectre_libs=spectre") }

	Copy-CmdEnv $VCVarsAll $VCVarsArgs
}
#endregion VS

#region VM management
function Get-VMIPs {
	# Get the IP addresses of all VMs.

	Get-VM |
	Where-Object { $_.ReplicationMode -ne 'Replica' } |
	Select-Object -ExpandProperty NetworkAdapters |
	Select-Object VMName, IPAddresses, Status
}

function Get-VMIP {
	# Get the IP address of the given VM.

	[CmdletBinding()]
	Param(
		[parameter(Mandatory = $True)]
		[alias("VM")]
		[string]$Name
	)
	Process {
		(Get-VM $Name | Get-VMNetworkAdapter).IPAddress
	}
}

function Set-VMCP {
	# Create a checkpoint for the given VM.

	[CmdletBinding()]
	Param(
		[parameter(Mandatory = $True)]
		[alias("VM")]
		[string]$Name,

		[parameter(Mandatory = $False)]
		[alias("CP")]
		[string]$CPName = $("{0}-{1}" -f $Env:OS, (Get-Date).toString('yyyyMMddHHmm'))
	)
	Process {
		Get-VM $Name | Checkpoint-VM -SnapshotName $CPName
	}
}
#endregion VM management

#region PSReadLine
Import-Module PSReadLine

Set-PSReadLineOption -EditMode Emacs

# Search based on current input when navegating command history.
Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
Set-PSReadLineOption -HistorySearchCursorMovesToEnd

# Token-based word movement.
Set-PSReadLineKeyHandler -Key Alt+b -Function ShellBackwardWord
Set-PSReadLineKeyHandler -Key Alt+f -Function ShellForwardWord
Set-PSReadLineKeyHandler -Key Alt+B -Function SelectShellBackwardWord
Set-PSReadLineKeyHandler -Key Alt+F -Function SelectShellForwardWord
Set-PSReadLineKeyHandler -Key Alt+d -Function ShellKillWord
Set-PSReadLineKeyHandler -Key Alt+Backspace -Function ShellBackwardKillWord
#endregion PSReadLine

#region Chocolatey
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
	Import-Module "$ChocolateyProfile"
}
#endregion Chocolatey

#region Additional configuration
New-Alias vea Set-VEnv -Force

Add-Path "$HOME\bin"

Invoke-Expression (&starship init powershell)
#endregion Additional configuration
