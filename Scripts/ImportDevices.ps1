$UMSCredPath = 'C:\Credentials\UmsRmdb.cred'

$PSDefaultParameterValues = @{
  'New-UMSAPICookie:Credential' = Import-Clixml -Path $UMSCredPath
  '*-UMS*:Computername'         = 'igelrmserver'
  #'*-UMS*:SecurityProtocol'     = 'Tls'
}
$PSDefaultParameterValues += @{
  '*-UMS*:WebSession' = (New-UMSAPICookie)
}

$Path = 'E:\GitHub\PSIGEL\Drafts\'
#$Path = 'C:\Temp\'

$IGELImportFile = '{0}2260123456-000010.csv' -f $Path
$AssetExportFile = '{0}Assets.csv' -f $Path

$IGELImportColl = Import-Csv -Delimiter ';' -Path $IGELImportFile -Header '0', 'SerialNumber', 'MacAddress', '3', '4'
$AssetExportColl = Import-Csv -Delimiter ';' -Path $AssetExportFile

$DevicePrefix = 'DEV'
$MajorVersion = 10

$FirmwareId = (((Get-UMSFirmware).where{ $_.Version.Major -eq $MajorVersion } |
      Sort-Object -Property Version -Descending)[0]).Id

$NewDeviceCollParams = @{
  Left              = $IGELImportColl
  LeftJoinProperty  = 'SerialNumber'
  LeftProperties    = 'SerialNumber', 'MacAddress'
  Right             = $AssetExportColl
  RightJoinProperty = 'SerialNumber'
  RightProperties   = 'InventoryNumber'
  Type              = 'AllInLeft'
}
$NewDeviceColl = Join-Object @NewDeviceCollParams | Sort-Object -Property SerialNumber

foreach ($NewDevice in $NewDeviceColl)
{
  $NewDeviceParams = @{
    Mac          = $NewDevice.MacAddress
    FirmwareId   = $FirmwareId
    Name         = '{0}-{1}' -f $DevicePrefix, $NewDevice.InventoryNumber
    SerialNumber = $NewDevice.SerialNumber
    AssetId      = $NewDevice.InventoryNumber
  }
  New-UMSDevice @NewDeviceParams
}
