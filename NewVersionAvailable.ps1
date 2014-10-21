Param(
    [string]$AlertRecipient,
    [PSCredential]$Credentials
)

Push-Location
Set-Location $(Split-Path -Parent $MyInvocation.MyCommand.Definition)

$ErrorActionPreference = "Stop"

#Max Version Online
$maxVersion = $(
    (New-Object System.Net.WebClient).DownloadString("http://download.virtualbox.org/virtualbox/") -split "`n" |
    ? {$_ -match "NAME=`"(\d+\.\d+\.\d+)/`""} |
    % {[version]$Matches[1]} | Measure-Object -Maximum
).Maximum

$powershell = Get-Content .\tools\chocolateyInstall.ps1
$powershell[1] -match "\d+\.\d+\.\d+" | Out-Null
[version]$currentVersion = $Matches[0]

if ($currentVersion -lt $maxVersion)
{
    Send-MailMessage -To $AlertRecipient -Subject "Chocolatey-VBoxGuestAdditions" -Body "An Updated Version is available" -From $Credentials.UserName -SmtpServer smtp.mandrillapp.com -Port 587 -Credential $Credentials
}
Pop-Location