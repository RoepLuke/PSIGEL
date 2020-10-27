$PSDefaultParameterValues = @{
  '*-UMS*:Computername' = 'export-igelrmserver'
  '*-UMS*:Confirm'      = $False
}
$PSDefaultParameterValues.Add('New-UMSAPICookie:Credential', (Import-Clixml -Path 'C:\Path\To\export-igelrmserver.cred'))

$WebSession = New-UMSAPICookie
$PSDefaultParameterValues.Add('*-UMS*:WebSession', $WebSession)

$StartDirName = 'Export-StartDirName'

$DeviceDirectoryColl = Get-UMSDeviceDirectory
$StartDirId = ((($DeviceDirectoryColl).where{ $_.Name -eq $StartDirName })[0]).Id
Get-UMSDirectoryRecursive -DirectoryColl $DeviceDirectoryColl -Id  $StartDirId |
  ConvertTo-Json -Depth 10 | Out-File .\ExportDeviceDir.json

$Null = Remove-UMSAPICookie -WebSession $WebSession