$ErrorActionPreference = 'Stop';

$packageName= 'winlogbeat'

$toolsDir   = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"
$url        = 'https://artifacts.elastic.co/downloads/beats/winlogbeat/winlogbeat-7.14.1-windows-x86.zip'
$url64      = 'https://artifacts.elastic.co/downloads/beats/winlogbeat/winlogbeat-7.14.1-windows-x86_64.zip'

$installationPath = $toolsDir

$folder = if(Get-ProcessorBits 64) { [io.path]::GetFileNameWithoutExtension($url64) } else { [io.path]::GetFileNameWithoutExtension($url) }

$packageArgs = @{
  packageName   = $packageName
  unzipLocation = $installationPath
  url           = $url
  url64bit      = $url64
  checksum      = '4552a333411bbb552526b2136d3509707f2cccaf0d654962377bd9c954188ad266979d3ad509e377b476f5077144bef6912e69b4be7acaef6db07d39cdc5ebb7'
  checksumType  = 'sha512'
  checksum64    = '6872e62a33f69340c5bdd62e72e4d486cd57ba62d7d9aee63f231526ed0a0ab68befa3264b053907c8d98198da71742700c062cef5cc2b8cdd160118b378afc3'
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
