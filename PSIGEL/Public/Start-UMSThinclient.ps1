﻿function Start-UMSThinclient
{
  <#
      .Synopsis
      Wakes Up Thinclients (WOL) via API

      .DESCRIPTION
      Wakes Up Thinclients (WOL) via API

      .PARAMETER Computername
      Computername of the UMS Server

      .PARAMETER TCPPort
      TCP Port API (Default: 8443)

      .PARAMETER ApiVersion
      API Version to use (Default: 3)

      .Parameter WebSession
      Websession Cookie

      .PARAMETER TCID
      ThinclientIDs to wake up

      .EXAMPLE
      $Computername = 'UMSSERVER'
      $Params = @{
        Computername = $Computername
        WebSession   = New-UMSAPICookie -Computername $Computername
        TCID         = 48426
      }
      Start-UMSThinclient @Params
      #Wakes up thin client with TCID 48426.

      .EXAMPLE
      48426, 2435 | Start-UMSThinclient -Computername 'UMSSERVER'
      #Wakes up thin clients with TCID 48426 and 2435.

  #>

  [cmdletbinding(SupportsShouldProcess, ConfirmImpact = 'Low')]
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
    $TCIDColl
  )

  Begin
  {
  }
  Process
  {
    if ($null -eq $WebSession)
    {
      $WebSession = New-UMSAPICookie -Computername $Computername
    }

    $UriArray = @($Computername, $TCPPort, $ApiVersion)
    $Uri = 'https://{0}:{1}/umsapi/v{2}/thinclients?command=wakeup' -f $UriArray

    foreach ($TCID in $TCIDColl)
    {
      $Body = ConvertTo-Json @(
        @{
          id   = $TCID
          type = "tc"
        }
      )

      $Params = @{
        WebSession  = $WebSession
        Uri         = $Uri
        Body        = $Body
        Method      = 'Post'
        ContentType = 'application/json'
        Headers     = @{}
      }

      if ($PSCmdlet.ShouldProcess('TCID: {0}' -f $TCID))
      {
        Invoke-UMSRestMethodWebSession @Params
      }
    }
  }
  End
  {
  }
}

