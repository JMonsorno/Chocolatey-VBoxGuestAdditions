$packageName = 'VBoxGuestAdditions.install'
$url = 'http://download.virtualbox.org/virtualbox/5.1.12/VBoxGuestAdditions_5.1.12.iso'

$unzip = Join-Path $env:TEMP VBoxGuestAdditions
$certPath = Join-Path $unzip "cert"
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

Write-Output "Installing certs..."
Get-ChildItem $certPath -Filter *.cer |
Foreach-Object {
    $file = ".\" + $_.Name
    .\VBoxCertUtil.exe add-trusted-publisher $file >$null 2>&1
}

Pop-Location
$filename = $(Get-ChildItem .\VBoxWindowsAdditions.exe).FullName
Install-ChocolateyInstallPackage -packageName $packageName -silentArgs '/S' -file $filename
