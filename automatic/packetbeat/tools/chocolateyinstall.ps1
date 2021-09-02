$ErrorActionPreference = 'Stop';

$packageName= 'packetbeat'

$toolsDir   = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"
$url        = 'https://artifacts.elastic.co/downloads/beats/packetbeat/packetbeat-7.14.1-windows-x86.zip'
$url64      = 'https://artifacts.elastic.co/downloads/beats/packetbeat/packetbeat-7.14.1-windows-x86_64.zip'

$installationPath = $toolsDir

$folder = if(Get-ProcessorBits 64) { [io.path]::GetFileNameWithoutExtension($url64) } else { [io.path]::GetFileNameWithoutExtension($url) }

$packageArgs = @{
  packageName   = $packageName
  unzipLocation = $installationPath
  url           = $url
  url64bit      = $url64
  checksum      = '5878180dfd039749f162d608f005ac063bc005b98773af20d99051e42eb3cc1dbb6499398d5cb29eb5264c3cb341cb837fea1b3b2c511ee4bf2830b0c3941839'
  checksumType  = 'sha512'
  checksum64    = '2207e91fef54eb035bd5ea63ce6bb49593b0fd0dbda76b9f533c58f77ad85228acc0b83c394e09e39abbfe4d2c69039ad3717a13512f90099676c3f12369e3f2'
  checksumType64= 'sha512'
  specificFolder = $folder
}

Install-ChocolateyZipPackage @packageArgs

# Move everything from the subfolder to the main tools directory
$subFolder = Join-Path $installationPath (Get-ChildItem $installationPath $folder | ?{ $_.PSIsContainer })
Get-ChildItem $subFolder -Recurse | ?{$_.PSIsContainer } | Move-Item -Destination $installationPath
Get-ChildItem $subFolder | ?{$_.PSIsContainer -eq $false } | Move-Item -Destination $installationPath
Remove-Item "$subFolder"

Invoke-Expression $(Join-Path $installationPath "install-service-$($packageName).ps1")
