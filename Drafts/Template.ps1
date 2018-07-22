<function Verb-UMSNoun
{
  <#
      .Synopsis
      ... via API

      .DESCRIPTION
      ... via API

      .PARAMETER Computername
      Computername of the UMS Server

      .PARAMETER TCPPort
      TCP Port API (Default: 8443)

      .PARAMETER ApiVersion
      API Version to use (Default: 3)

      .Parameter WebSession
      Websession Cookie

      .PARAMETER TCID
      ThinclientIDs to shut down

      .EXAMPLE
      $WebSession = New-UMSAPICookie -Computername 'UMSSERVER'
      Verb-UMSNoun -Computername 'UMSSERVER' -WebSession $WebSession -TCID 48426
      #...

      .EXAMPLE
      ..., ... | Verb-UMSNoun -Computername 'UMSSERVER'
      #...

  #>

  [cmdletbinding(SupportsShouldProcess, ConfirmImpact = 'Medium')]
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

    $WebSession,

    [Parameter(Mandatory, ValueFromPipeline)]
    [int]
    $ID
  )

  Begin
  {
  }
  Process
  {
    Switch ($WebSession)
    {
      $null
      {
        $WebSession = New-UMSAPICookie -Computername $Computername
      }
    }
    foreach ($XYZID in $XYZIDColl)
    {
      $Body = @{
        id   = $XYZID
        xyz = "xyz"
      } | ConvertTo-Json
      $SessionURL = 'https://{0}:{1}/umsapi/v{2}/xyz?abc' -f $Computername, $TCPPort, $ApiVersion
      if ($PSCmdlet.ShouldProcess('TCID: {0}' -f $XYZID))
      {
        Invoke-UMSRestMethodWebSession -WebSession $WebSession -SessionURL $SessionURL -Method 'Post'
        Invoke-UMSRestMethodWebSession -WebSession $WebSession -SessionURL $SessionURL -BodyWavy $Body -Method 'Post'
        Invoke-UMSRestMethodWebSession -WebSession $WebSession -SessionURL $SessionURL -BodySquareWavy $Body -Method 'Post'
      }
    }
  }
  End
  {
  }
}