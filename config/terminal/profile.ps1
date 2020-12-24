# Utility functions.
function Add-Path([string]$Item='.') {
	# Add a new directory to the Path environment variable.

	$PathArray = ${Env:Path}.Trim(';') -Split ';'
	$PathArray += $Item
	${Env:Path} = $PathArray -Join ';'
}

function Copy-Env([string]$Cmd, [string[]]$CmdArgs) {
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


# Python-related utility functions.
function Set-VEnv([string]$VEnv='ve') {
	# Activate a Python virtual environment in the current directory.
	# Virtual environment name defaults to 've'.

	$VEA = Join-Path $VEnv 'Scripts\activate.ps1'
	&"$VEA"
}


# VM management cmdlets.
function Get-VMIPs {
	# Get the IP addresses of all VMs.

	Get-VM |
		Where-Object {$_.ReplicationMode -ne 'Replica'} |
		Select-Object -ExpandProperty NetworkAdapters |
		Select-Object VMName, IPAddresses, Status
}

function Get-VMIP {
	# Get the IP address of the given VM.

	[CmdletBinding()]
	Param(
		[parameter(
			Mandatory=$true,
			ValueFromPipeline=$true,
			ValueFromPipelineByPropertyName=$true
		)]
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
		[parameter(
			Mandatory=$true,
			ValueFromPipeline=$true,
			ValueFromPipelineByPropertyName=$true
		)]
		[alias("VM")]
		[string]$Name,

		[parameter(
			Mandatory=$false,
			ValueFromPipeline=$true,
			ValueFromPipelineByPropertyName=$true
		)]
		[alias("CP")]
		[string]$CPName = $("{0}-{1}" -f $Env:OS,(Get-Date).toString('yyyyMMddHHmm'))
	)
	Process {
		Get-VM $Name | Checkpoint-VM -SnapshotName $CPName
	}
}


# Aliases.
New-Alias vea Set-VEnv -Force

# Setup path.
Add-Path "$HOME/bin"
Add-Path "$HOME/.cargo/bin"

# Chocolatey profile.
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
	Import-Module "$ChocolateyProfile"
}

# Prompt.
Invoke-Expression (&starship init powershell)
