[CmdletBinding()]
param(
    [string]$PackageId = (Split-Path $PSScriptRoot -Leaf)
)

$LatestRelease = Invoke-RestMethod "https://api.github.com/repos/cloudflare/cloudflared/releases/latest"
$LatestVersion = $LatestRelease.tag_name.TrimStart('v')

$AvailablePackages = Invoke-RestMethod "https://community.chocolatey.org/api/v2/package-versions/$PackageId"

if ($LatestVersion -in $AvailablePackages) {
    Write-Host "No update required for '$($PackageId)'"
    return
}

# Update the install script
$InstallPs1 = Get-Content $PSScriptRoot\tools\chocolateyInstall.ps1
@{
    "url"        = $LatestRelease.assets.Where{$_.name -eq 'cloudflared-windows-386.exe'}.browser_download_url
    "checksum"   = ($LatestRelease.body.Split("`n") -match 'cloudflared-windows-386.exe: (?<CheckSum>\w+)').Split(': ')[-1]
    "url64bit"   = $LatestRelease.assets.Where{$_.name -eq 'cloudflared-windows-amd64.exe'}.browser_download_url
    "checksum64" = ($LatestRelease.body.Split("`n") -match 'cloudflared-windows-amd64.exe: (?<CheckSum>\w+)').Split(': ')[-1]
}.GetEnumerator().ForEach{
    if ($InstallPs1 -match "^(\s*[`$`"']?$($_.Key)[`"']?\s*=\s*)[`"'].*[`"']") {
        $InstallPs1 = $InstallPs1 -replace "(\s*[`$`"']?$($_.Key)[`"']?\s*=\s*)[`"'].*[`"']", "`$1'$($_.Value)'"
    } else {
        Write-Error -Message "$PackageId`: Could not find replacement for '$($_.Key)' in chocolateyInstall.ps1" -ErrorAction Stop
    }
}
$InstallPs1 | Set-Content $PSScriptRoot\tools\chocolateyInstall.ps1

# Package the updated files
choco pack "$($PSScriptRoot)\$($PackageId).nuspec" --version $LatestVersion