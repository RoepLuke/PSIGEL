Import-Module C:\GitHub\PSIGEL\PSIGEL\PSIGEL.psd1 -Force
$UMSCredPath = 'C:\Credentials\UmsRmdb.cred'

$PSDefaultParameterValues = @{
  'New-UMSAPICookie:Credential' = Import-Clixml -Path $UMSCredPath
  '*-UMS*:Computername'         = 'igelrmserver'
  '*-UMS*:TCPPort'              = 9443
  '*-UMS*:Confirm'              = $False
  #'*-UMS*:SecurityProtocol'     = 'Tls'
}
$PSDefaultParameterValues += @{
  '*-UMS*:WebSession' = New-UMSAPICookie
}

$Result = Get-UMSDeviceAssignment -Id 505
$Result

<#

$StringPropertyColl = @{
  'Int'      = @(
    'batteryLevel',
    'cpuSpeed',
    'firmwareID',
    'flashSize',
    'id',
    'memorySize',
    'monitor1WeekOfManufacture',
    'monitor1YearOfManufacture',
    'monitor2WeekOfManufacture',
    'monitor2YearOfManufacture',
    'monitorSize1',
    'monitorSize2',
    'networkSpeed',
    'parentID'
  )
  'Int64'    = @(
    'totalUptime',
    'totalUsagetime'
  )
  'Datetime' = @(
    'biosDate',
    'lastBoottime'
  )
  'Bool'     = @(
    'movedToBin',
    'online'
  )
}
$APIObjectColl = Get-UMSDevice -Filter details
$APIObjectColl.GetType()
$APIObjectColl[0].GetType()

$Result = foreach ($APIObject in $APIObjectColl)
{
  $CastedPropertyColl = @{ }
  foreach ($StringProperty In $APIObject | Get-Member -MemberType NoteProperty)
  {
    switch ($StringProperty.Name)
    {
      ( { $_ -in $StringPropertyColl.Int })
      {
        $CastedPropertyColl.Add($StringProperty.Name, [Int]$APIObject.($StringProperty.Name))
      }
      ( { $_ -in $StringPropertyColl.Int64 })
      {
        $CastedPropertyColl.Add($StringProperty.Name, [System.ComponentModel.Int64Converter]$APIObject.($StringProperty.Name))
      }
      ( { $_ -in $StringPropertyColl.Datetime })
      {
        $CastedPropertyColl.Add($StringProperty.Name, [System.Convert]::ToDateTime($APIObject.($StringProperty.Name)))
      }
      ( { $_ -in $StringPropertyColl.Bool })
      {
        $CastedPropertyColl.Add($StringProperty.Name, [System.Convert]::ToBoolean($APIObject.($StringProperty.Name)))
      }
      ( { $_ -in $StringPropertyColl.Xml })
      {
        $CastedPropertyColl.Add($StringProperty.Name, [xml]$APIObject.($StringProperty.Name))
      }
      ( { $_ -in $StringPropertyColl.Pscustomobject })
      {
        $CastedPropertyColl.Add($StringProperty.Name, [pscustomobject]$APIObject.($StringProperty.Name))
      }
      Default
      {
        $CastedPropertyColl.Add($StringProperty.Name, [String]$APIObject.($StringProperty.Name))
      }
    }
  }
  New-Object psobject -Property $CastedPropertyColl
}
$Result
#>

<#

$NewParams = @{
  Mac        = '0A00000000AA'
  Name       = 'NewDevice01'
  FirmwareId = 1
  ParentId   = -1
}
$MoveParams = @{
  DestId = 502 # PSIGEL
}
$UpdateParams = @{
  Name = 'UpdatedDevice01'
}

$Result = @(
  $null = [pscustomobject]$NewParams |
  New-UMSDevice | Tee-Object -Variable 'NewUMSDevice' |
  Move-UMSDevice @MoveParams | Tee-Object -Variable 'MoveUMSDevice' |
  Update-UMSDevice @UpdateParams | Tee-Object -Variable 'UpdateUMSDevice' |
  Get-UMSDevice | Tee-Object -Variable 'GetUMSDevice' |
  Start-UMSDevice | Tee-Object -Variable 'StartUMSDevice' |
  Send-UMSDeviceSetting | Tee-Object -Variable 'SendUMSDeviceSettings' |
  Remove-UMSDevice | Tee-Object -Variable 'RemoveUMSDevice'

  $NewUMSDevice
  $MoveUMSDevice
  $UpdateUMSDevice
  $GetUMSDevice
  $StartUMSDevice
  $SendUMSDeviceSettings
  $RemoveUMSDevice
)
$Result
#>


#Get-UMSDevice -WebSession $Result

<#

  $Result = @(
    $null = ((($NewParams.Mac |
    New-UMSDevice -FirmwareId $NewParams.FirmwareId | Tee-Object -Variable 'NewUMSDevice').Id |
    Move-UMSDevice @MoveParams | Tee-Object -Variable 'MoveUMSDevice').Id |
    Update-UMSDevice @UpdateParams | Tee-Object -Variable 'UpdateUMSDevice').Id |
    Remove-UMSDevice @RemoveParams | Tee-Object -Variable 'RemoveUMSDevice'

    $NewUMSDevice
    $MoveUMSDevice
    $UpdateUMSDevice
    $RemoveUMSDevice
    )
    $Result
    #>





<#
$Result = ''
$Result
#>