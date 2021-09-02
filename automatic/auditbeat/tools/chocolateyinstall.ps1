$ErrorActionPreference = 'Stop';

$packageName= 'auditbeat'

$toolsDir   = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"
$url        = 'https://artifacts.elastic.co/downloads/beats/auditbeat/auditbeat-7.14.1-windows-x86.zip'
$url64      = 'https://artifacts.elastic.co/downloads/beats/auditbeat/auditbeat-7.14.1-windows-x86_64.zip'

$installationPath = $toolsDir

$folder = if(Get-ProcessorBits 64) { [io.path]::GetFileNameWithoutExtension($url64) } else { [io.path]::GetFileNameWithoutExtension($url) }

$packageArgs = @{
  packageName   = $packageName
  unzipLocation = $installationPath
  url           = $url
  url64bit      = $url64
  checksum      = 'cef18da013808f3749dafabf40a1fd40393a9d601aeeecfba98572d7f0390ea65e86a843ef9207b43e6997daa662f12bf8a8c157f9af0f6c1f76cc3a314d4d2d'
  checksumType  = 'sha512'
  checksum64    = 'ed5d9ee685a6eb5076029e8c0212aa491c6c64d7dd86c88fce6e1a996e2220d55e07d8ff9a7278787aa3387b86e6399c85313146794b53e1f455cc0bf5981baa'
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
