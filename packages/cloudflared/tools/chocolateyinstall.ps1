$ErrorActionPreference = 'Stop'
$toolsDir   = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"

$packageArgs = @{
  packageName   = $env:ChocolateyPackageName
  FileFullPath  = Join-Path $toolsDir "cloudflared.exe"

  url           = 'https://github.com/cloudflare/cloudflared/releases/download/2021.9.0/cloudflared-windows-386.exe'
  url64bit      = 'https://github.com/cloudflare/cloudflared/releases/download/2021.9.0/cloudflared-windows-amd64.exe'

  checksum      = '64a53ad21481838bbbafaac9751c7848130160306ec9e7cd349a355d1cb28705'
  checksumType  = 'sha256'
  checksum64    = '41d394c0504074f12203892cec24ba2fbddfaff87448edd86f440f7c20505106'
  checksumType64= 'sha256'
}

Get-ChocolateyWebFile @packageArgs