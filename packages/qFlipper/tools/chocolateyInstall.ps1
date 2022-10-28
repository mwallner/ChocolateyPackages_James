$ErrorActionPreference = 'Stop'

$packageArgs = @{
    packageName    = $env:ChocolateyPackageName
    fileType       = 'exe'
    url64bit       = "https://update.flipperzero.one/builds/qFlipper/$($env:ChocolateyPackageVersion)/qFlipperSetup-64bit-$($env:ChocolateyPackageVersion).exe"
    checksum64     = '{{ checksum }}'
    checksumType64 = 'sha256'
    silentArgs     = '/S'
}

Install-ChocolateyPackage @packageArgs

# Add a shim to qflipper-cli.exe, if it exists in the expected location
if (Test-Path $env:ProgramFiles\qFlipper\qFlipper-cli.exe) {
    Install-BinFile -Name qFlipper-cli.exe -Path $env:ProgramFiles\qFlipper\qFlipper-cli.exe
}