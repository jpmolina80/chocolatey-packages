$ErrorActionPreference = 'Stop';

$packageName= 'metricbeat'

$toolsDir   = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"
$url        = 'https://artifacts.elastic.co/downloads/beats/metricbeat/metricbeat-7.14.1-windows-x86.zip'
$url64      = 'https://artifacts.elastic.co/downloads/beats/metricbeat/metricbeat-7.14.1-windows-x86_64.zip'

$installationPath = $toolsDir

$folder = if(Get-ProcessorBits 64) { [io.path]::GetFileNameWithoutExtension($url64) } else { [io.path]::GetFileNameWithoutExtension($url) }

$packageArgs = @{
  packageName   = $packageName
  unzipLocation = $installationPath
  url           = $url
  url64bit      = $url64
  checksum      = '6f209b19d3514bf0ec7447f4fea2a8d9f6a3f1f553e59d8fd237be43c99f571066087589c5ad12275d9e0142af60fe85a560102fd40b172d36491b5d2ce7b615'
  checksumType  = 'sha512'
  checksum64    = 'cdcf8590ee081c37a2990e7911e68ed52b738105912a83a1a47aca23db1d59e8606e1631e3ec25580633bc2f82d6215fd427c1a830378bff523b7599b50fb4a0'
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
