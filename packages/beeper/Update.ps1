param(
    # URL offering download of the installer
    $DownloadUrl = "https://download.beeper.com/windows/nsis/x64",

    # Repository to check for packages and push to
    $Repository = "https://community.chocolatey.org/api/v2/"
)

$LatestInstaller = Invoke-WebRequest -Uri $DownloadUrl
$FileName = $LatestInstaller.BaseResponse.Content.Headers.ContentDisposition.FileName
$LatestVersion = if ($FileName -match "Beeper Setup (?<Version>\d+\.\d+\.\d+)-x64.exe") {
    $Matches.Version
} else {
    Write-Error "Latest Version could not be determined via HEAD request" -ErrorAction Stop
}
Write-Verbose "Latest Installer Version: $LatestVersion"

$LatestPackage = (Invoke-RestMethod -Uri "$($Repository -replace '/$')/package-versions/beeper")[-1]
if ([version]$LatestPackage -lt $LatestVersion) {
    Write-Verbose "Updating Beeper Package (Latest Package Version: $($LatestPackage))"
    $LatestInstaller | Out-File -FilePath "$PSScriptRoot\$FileName"

    # Update stuff
    

    # Pack it!
    choco pack $PSScriptRoot\beeper.nuspec --no-progress -r

    # Ship it!
    if ($env:RepositoryApiKey) {
        choco push beeper --source $Repository --api-key $env:RepositoryApiKey
    }
}