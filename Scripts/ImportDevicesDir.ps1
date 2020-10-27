$PSDefaultParameterValues = @{
  '*-UMS*:Computername' = 'import-igelrmserver'
  '*-UMS*:Confirm'      = $False
}
$PSDefaultParameterValues.Add('New-UMSAPICookie:Credential', (Import-Clixml -Path 'C:\Path\To\import-igelrmserver.cred'))

$WebSession = New-UMSAPICookie
$PSDefaultParameterValues.Add('*-UMS*:WebSession', $WebSession)

$ImportStartDirName = 'Import-StartDirName'
$ExportStartDirName = 'Export-StartDirName'

$ImportDevicesDirColl = Get-Content -Path .\ExportDeviceDir.json | ConvertFrom-Json

$ImportStartDir = New-UMSDeviceDirectory -Name $ImportStartDirName

if ($ImportStartDir.Id)
{
  $ExportOrgParent = ($ImportDevicesDirColl).where{ $_.Name -eq $ExportStartDirName }
  $ExportOrgDirColl = ($ImportDevicesDirColl).where{ $_.ParentId -eq $ExportOrgParent.Id }
  $Result = foreach ($ExportOrgDir in $ExportOrgDirColl)
  {
    $ImportOrgDir = New-UMSDeviceDirectory -Name $ExportOrgDir.Name | Move-UMSDeviceDirectory -DestId $ImportStartDir.Id
    $ImportOrgDir
    $ExportCampusParent = ($ImportDevicesDirColl).where{ $_.Name -eq $ExportOrgDir.Name }
    $ExportCampusDirColl = ($ImportDevicesDirColl).where{ $_.ParentId -eq $ExportCampusParent.Id }

    if ($ImportOrgDir.Id)
    {
      foreach ($ExportCampusDir in $ExportCampusDirColl)
      {
        $ImportCampusDir = New-UMSDeviceDirectory -Name $ExportCampusDir.Name | Move-UMSDeviceDirectory -DestId $ImportOrgDir.Id
        $ImportCampusDir
        $ExportRoomParent = ($ImportDevicesDirColl).where{ $_.Name -eq $ExportCampusDir.Name }
        $ExportRoomDirColl = ($ImportDevicesDirColl).where{ $_.ParentId -eq $ExportRoomParent.Id }

        if ($ImportCampusDir.Id)
        {
          foreach ($ExportRoomDir in $ExportRoomDirColl)
          {
            $ImportRoomDir = New-UMSDeviceDirectory -Name $ExportRoomDir.Name | Move-UMSDeviceDirectory -DestId $ImportCampusDir.Id
            $ImportRoomDir
          }
        }
      }
    }
  }
  $Result
}

$Null = Remove-UMSAPICookie -WebSession $WebSession