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

function Open-TotalCmd([string]$Path = '.', [switch]$Target = $false) {
	# Open Total Commander, with the source panel set at $Path (defaults to the
	# current directory).
	# If $Target is true, then the destination panel is set at $Path.

	$TotalCmdExe = "${env:COMMANDER_PATH}\TOTALCMD64.EXE"
	$FullPath = Resolve-Path $Path

	if ($Target) {
		$PathArg = "/r=`"$FullPath`""
	} else {
		$PathArg = "/l=`"$FullPath`""
	}

	&$TotalCmdExe /o /s $PathArg
}

function Find-GitRepos([string]$Path = '.') {
	# Find all Git repositories under $Path.

	return &es -path $Path -ad -path-column -i regex:\.git$
}
#endregion Utilities

#region Fuzzy helpers
function Open-Repo() {
	# Get all Git repositories under the current working directory, and go to
	# the fuzzy-matched one.

	Find-GitRepos | fzf | Set-Location
}

function Edit-Repos() {
	# Get all Git repositories under the current working directory, and open
	# all the fuzzy-matched ones with Code.

	Find-GitRepos | fzf -m | ForEach-Object { code $_ }
}
#endregion Fuzzy helpers

#region Python
function Set-VEnv([string]$VEnv = 've') {
	# Activate a Python virtual environment in the current directory.
	# Virtual environment name defaults to 've'.

	$VEA = Join-Path $VEnv 'Scripts\activate.ps1'
	&"$VEA"
}

function New-VEnv([string]$VEnv = 've', [string]$Requirements = 'requirements.txt') {
	# Create and activate a new virtual environment in $VEnv, and install the
	# requirements from the $Requirements file.

	&python -m venv $VEnv
	Set-Venv -VEnv $VEnv
	&pip install -r $Requirements
}
#endregion Python

#region VS
function Find-VS([string]$Property = "installationPath") {
	# Find out information about a Visual Studio installation.

	$VSWhere = "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\VSWhere.exe"

	return &$VSWhere -latest -property $Property
}

function Get-VSShell {
	# Get a Visual Studio Developer Command Prompt.

	$InstanceId = Find-VS instanceId
	$Path = Find-VS installationPath

	Import-Module "$Path\Common7\Tools\Microsoft.VisualStudio.DevShell.dll"
	Enter-VSDevShell $InstanceId
}

function Get-VCShell {
	# Get a Visual Studio C++ Developer Command Prompt for the specified
	# architecture, with the specified (optional) configuration.

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

	$Path = Find-VS installationPath

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
Set-PSReadLineOption -BellStyle None

Set-PSReadLineOption -Colors @{
	Command            = 'Yellow'
	Comment            = 'DarkGreen'
	ContinuationPrompt = 'DarkYellow'
	Default            = 'DarkYellow'
	Emphasis           = 'Cyan'
	Error              = 'Red'
	Keyword            = 'Green'
	Member             = 'DarkGreen'
	Number             = 'DarkGreen'
	Operator           = 'DarkCyan'
	Parameter          = 'DarkCyan'
	String             = 'Blue'
	Type               = 'DarkBlue'
	Variable           = 'Green'
}

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

# Sometimes you enter a command but realize you forgot to do something else
# first. This binding will let you save that command in the history so you can
# recall it, but it doesn't actually execute. It also clears the line with
# RevertLine so the undo stack is reset - though redo will still reconstruct
# the command line.
Set-PSReadLineKeyHandler `
	-Key Alt+w `
	-BriefDescription SaveInHistory `
	-LongDescription "Save current line in history but do not execute" `
	-ScriptBlock {
	param($key, $arg)

	$line = $null
	$cursor = $null

	[Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)
	[Microsoft.PowerShell.PSConsoleReadLine]::AddToHistory($line)
	[Microsoft.PowerShell.PSConsoleReadLine]::RevertLine()
}
#endregion PSReadLine

#region Chocolatey
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
	Import-Module "$ChocolateyProfile"
}
#endregion Chocolatey

#region Additional configuration
New-Alias cdgit Open-Repo
New-Alias edit Edit-Repos
New-Alias totalcmd Open-TotalCmd
New-Alias vea Set-VEnv -Force

Add-Path "$HOME\bin"

Invoke-Expression (&starship init powershell)
#endregion Additional configuration
