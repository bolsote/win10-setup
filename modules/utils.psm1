function Write-Action([string]$Action) {
    Write-Host -ForegroundColor DarkBlue "`n$Action..."
}

function Write-Subaction([string]$Subaction) {
    Write-Host -ForegroundColor Blue "$Subaction..."
}

function Install-List([hashtable]$Packages) {
    foreach ($Category in $Packages.GetEnumerator()) {
        $Name = $Category.Name
        $PackageList = $Category.Value -Join " "

        Write-Subaction "Installing $Name packages"
        choco upgrade -y $PackageList
    }

    RefreshEnv
}

function Install-WithParams([hashtable]$Packages) {
    foreach ($Package in $Packages.GetEnumerator()) {
        $Name = $Package.Name
        $Params = $Package.Value -Join " "

        choco install -y $Name --params `"$Params`"
    }

    RefreshEnv
}

function Copy-DirContents([string]$Source, [string]$Destination) {
    Copy-Item -Recurse -Path "$Source\*" -Destination $Destination
}

function Test-PSCore {
    $Version = $PSVersionTable.PSVersion.Major

    if ($Version -gt 5) {
        return $True
    }
    return $False
}
