$packageName = 'VBoxGuestAdditions.install' 
$url = 'http://download.virtualbox.org/virtualbox/4.3.22/VBoxGuestAdditions_4.3.22.iso'

$unzip = Join-Path $env:TEMP VBoxGuestAdditions
New-Item -Path $unzip -ItemType Directory -Force | Out-Null

$tempDir = Join-Path $env:TEMP "chocolatey\$packageName"
New-Item -Path $tempDir -ItemType Directory -Force | Out-Null
$fileFullPath = Join-Path $tempDir "$packageName.iso"
Get-ChocolateyWebFile `
    -packageName $packageName `
    -url $url -url64bit $url `
    -fileFullPath $fileFullPath

$7zip = "$($env:ProgramFiles)\7-Zip\7z.exe" 
$process = Start-Process $7zip -ArgumentList "x -o`"$unzip`" -y `"$fileFullPath`"" -Wait -WindowStyle Hidden -PassThru
try { if (!($process.HasExited)) { Wait-Process $process } } catch { }

Set-Location $unzip
Push-Location
Set-Location .\cert
.\VBoxCertUtil.exe add-trusted-publisher .\oracle-vbox.cer >$null 2>&1
Pop-Location
$filename = $(Get-ChildItem .\VBoxWindowsAdditions.exe).FullName
Install-ChocolateyInstallPackage -packageName $packageName -silentArgs '/S' -file $filename
