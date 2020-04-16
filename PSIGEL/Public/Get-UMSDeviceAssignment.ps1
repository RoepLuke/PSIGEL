function Get-UMSDeviceAssignment
{
  [CmdletBinding()]
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

    [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName, Mandatory)]
    [Int]
    $Id
  )

  Begin
  {
    $UriArray = @($Computername, $TCPPort, $ApiVersion)
    $BaseURL = ('https://{0}:{1}/umsapi/v{2}/thinclients' -f $UriArray)
    $Params = @{
      WebSession       = $WebSession
      Uri              = '{0}/{1}/assignments/profiles' -f $BaseURL, $Id
      Method           = 'Get'
      ContentType      = 'application/json'
      Headers          = @{ }
      SecurityProtocol = ($SecurityProtocol -join ',')
    }
    $PropertyColl = @{
      'Int' = @(
        'Id',
        'Receiver.Id',
        'Assignee.Id',
        'AssignmentPosition'
      )
    }
  }
  Process
  {
    $APIObjectColl = Invoke-UMSRestMethodWebSession @Params
    $Result = Get-UMSPropertyCast -APIObjectColl $APIObjectColl -PropertyColl $PropertyColl
    $Result
  }
  End
  {
  }
}

