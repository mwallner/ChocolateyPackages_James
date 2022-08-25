$ErrorActionPreference = 'Stop'
$toolsDir = Split-Path -Parent $MyInvocation.MyCommand.Definition

$PackageArguments = @{
    PackageName   = $env:ChocolateyPackageName
    Url           = "https://download.sysinternals.com/files/Disk2vhd.zip"
    Checksum      = "{{Checksum}}"
    ChecksumType  = "sha256"
    UnzipLocation = $toolsDir
}

Install-ChocolateyZipPackage @PackageArguments

$RegistryPath = 'HKCU:\Software\Sysinternals\Disk2Vhd'
if (-not (Get-ItemProperty -Path $RegistryPath -Name EulaAccepted -ErrorAction SilentlyContinue).EulaAccepted) {
    Write-Verbose "Accepting Disk2vhd EULA by setting registry value"
    try {
        if (-not (Split-Path $RegistryPath | Test-Path)) {
            $null = New-Item -Path $RegistryPath -ItemType RegistryKey -Force
        }
        Set-ItemProperty -Path $RegistryPath -Name EulaAccepted -Value 1
    } catch {
        Write-Warning "Failed to accept the Disk2vhd EULA. User may be prompted to accept the EULA on first run."
    }
}