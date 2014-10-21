$cred = New-Object System.Management.Automation.PSCredential("$($env:email)", $(ConvertTo-SecureString "$($env:emailApi)" -AsPlainText -Force))
$version = .\NewVersionAvailable.ps1 -AlertRecipient $($env:email) -Credentials $cred

if ($version)
{
git config --global push.default simple
git config --global core.safecrlf false
git config --global user.email "$($env:email)"
git config --global user.name "$($env:fullName)"

$guid = [Guid]::NewGuid().ToString()
git branch $guid
git checkout $guid >$null 2>&1
git branch -f develop $guid >$null 2>&1
git checkout develop >$null 2>&1

git add **/chocolateyInstall.ps1
git add VBoxGuestAdditions.nuspec
git commit -m "Automatic Build/Commit of Version $version"
git remote add github https://$($env:publicToken)@github.com/JMonsorno/Chocolatey-VBoxGuestAdditions.git
iex "git push github develop" >$null 2>&1
}