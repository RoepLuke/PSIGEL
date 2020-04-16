function Get-UMSDevice
{
  [CmdletBinding(DefaultParameterSetName = 'All')]
  param
  (
    [Parameter(Mandatory)]
    [String]
    $Computername,

    [ValidateRange(0, 65535)]
    [Int]
    $TCPPort = 8443,

    [ValidateSet(3)]
    [Int]
    $ApiVersion = 3,

    [ValidateSet('Tls12', 'Tls11', 'Tls', 'Ssl3')]
    [String[]]
    $SecurityProtocol = 'Tls12',

    [Parameter(Mandatory)]
    $WebSession,

    [ValidateSet('short', 'details', 'online', 'shadow')]
    [String]
    $Filter = 'short',

    [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'Id')]
    [Int]
    $Id
  )
  Begin
  {
    $UriArray = @($Computername, $TCPPort, $ApiVersion)
    $BaseURL = ('https://{0}:{1}/umsapi/v{2}/thinclients' -f $UriArray)
    $FilterString = New-UMSFilterString -Filter $Filter
    $Params = @{
      WebSession       = $WebSession
      Method           = 'Get'
      ContentType      = 'application/json'
      Headers          = @{ }
      SecurityProtocol = ($SecurityProtocol -join ',')
    }
    $PropertyColl = @{
      'Int'            = @(
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
      'Int64'          = @(
        'totalUptime',
        'totalUsagetime'
      )
      'Datetime'       = @(
        'biosDate',
        'lastBoottime'
      )
      'Bool'           = @(
        'movedToBin',
        'online'
      )
      'Pscustomobject' = @(
        'shadowSecret'
      )
    }
  }
  Process
  {
    Switch ($PsCmdlet.ParameterSetName)
    {
      'All'
      {
        $Params.Add('Uri', ('{0}{1}' -f $BaseURL, $FilterString))
        $APIObjectColl = (Invoke-UMSRestMethodWebSession @Params).SyncRoot
      }
      'Id'
      {
        $Params.Add('Uri', ('{0}/{1}{2}' -f $BaseURL, $Id, $FilterString))
        $APIObjectColl = Invoke-UMSRestMethodWebSession @Params
      }
    }
    $Result = Get-UMSPropertyCast -APIObjectColl $APIObjectColl -PropertyColl $PropertyColl
    $Result
  }
  End
  {
  }
}