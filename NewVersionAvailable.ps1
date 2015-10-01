Param(
    [string]$AlertRecipient,
    [PSCredential]$Credentials
)

Push-Location
Set-Location $(Split-Path -Parent $MyInvocation.MyCommand.Definition)

$ErrorActionPreference = "Stop"

#Max Version Online
$versions = (New-Object System.Net.WebClient).DownloadString("http://download.virtualbox.org/virtualbox/") -split "`n" |
    ? {$_ -match "href=`"(\d+\.\d+\.\d+)/`""} |
    % {[version]$Matches[1]} 

$maxVersion = $($versions | Measure-Object -Maximum).Maximum



$powershell = Get-Content .\tools\chocolateyInstall.ps1
$powershell[1] -match "\d+\.\d+\.\d+" | Out-Null
[version]$currentVersion = $Matches[0]

if ($currentVersion -lt $maxVersion)
{
    $version = $($versions |? {$_ -gt $currentVersion}  | Measure-Object -Minimum).Minimum.ToString()
    Send-MailMessage -To $AlertRecipient -Subject "Chocolatey-VBoxGuestAdditions" -Body "Version $version is available" -From $Credentials.UserName -SmtpServer smtp.mandrillapp.com -Port 587 -Credential $Credentials
    $powershell[1] = "`$url = 'http://download.virtualbox.org/virtualbox/$version/VBoxGuestAdditions_$version.iso'"
    Set-Content -Path .\tools\chocolateyInstall.ps1 -Value $powershell
    [xml]$nuspec = Get-Content -Raw .\VBoxGuestAdditions.nuspec
    $nuspec.package.metadata.version = $version.ToString()
    $nuspecPath = ".\VBoxGuestAdditions.nuspec"
    New-Item $nuspecPath -Force -ItemType File | Out-Null
    $nuspecPath = Resolve-Path $nuspecPath
    $nuspec.Save($nuspecPath)
    iex "choco pack"
    Write-Output $version
}
Pop-Location