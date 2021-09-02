$ErrorActionPreference = 'Stop';

$packageName= 'filebeat'

$toolsDir   = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"
$url        = 'https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-7.14.1-windows-x86.zip'
$url64      = 'https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-7.14.1-windows-x86_64.zip'

$installationPath = $toolsDir

$folder = if(Get-ProcessorBits 64) { [io.path]::GetFileNameWithoutExtension($url64) } else { [io.path]::GetFileNameWithoutExtension($url) }

$packageArgs = @{
  packageName   = $packageName
  unzipLocation = $installationPath
  url           = $url
  url64bit      = $url64
  checksum      = 'a99ae543be0c26532dd649d3be75ca2aad07aef47b468eb1dada2a30710edaeb6b88a8baa96e98b36e802d247b27a7a3c0280cf3b79e9c1901c48bfee5ebe9dd'
  checksumType  = 'sha512'
  checksum64    = 'ac1f787602db495ae239b8cf5e84292d52e8b58e84e63a90d3b0b4a20757dea366e0e10a22febdad398a8da46839cf23055f3db52f97a55c344c1feb1b738b0d'
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
