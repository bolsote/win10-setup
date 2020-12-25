$VsWhere = "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\VsWhere.exe"

$InstanceId = &$VsWhere -latest -property instanceId
$Path = &$VsWhere -latest -property installationPath

Import-Module "$Path\Common7\Tools\Microsoft.VisualStudio.DevShell.dll"
Enter-VsDevShell $InstanceId
