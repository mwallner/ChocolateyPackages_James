$ErrorActionPreference = 'Stop'

$toolsDir     = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"

$packageArgs = @{
    packageName   = $env:ChocolateyPackageName
    softwareName  = 'Beeper*'
    file          = Join-Path $toolsDir 'Beeper Setup 3.9.14-x64.exe'
    fileType      = 'exe'
    silentArgs    = "/S"
    validExitCodes= @(0)
    checksum      = '56B887A2A0A3CF7A39A69089B3BE1604D40C505BA3D7DEC9F7E587C3EE91882D'
    checksumType  = 'sha256'
    destination   = $toolsDir
}

Install-ChocolateyInstallPackage @packageArgs
