﻿function Get-UMSJob
{
  [cmdletbinding()]
  param
  (
    [Parameter(Mandatory)]
    [String]
    $ServerInstance,

    [Parameter(Mandatory)]
    [String]
    $Database,

    [Parameter(Mandatory)]
    [String]
    $Schema,

    [PSCredential]
    $Credential,

    [Parameter(ValueFromPipeline)]
    [int]
    $JobID
  )

  Begin
  {
  }
  Process
  {
    $InvokeSqlcmd2Params = @{
      ServerInstance = $ServerInstance
      Database       = $Database
    }

    if ($null -ne $Credential)
    {
      $InvokeSqlcmd2Params.Credential = $Credential
    }

    $BaseQuery = (@'
SELECT [{0}].[{1}].[JOB].[ID] AS ID
      ,[{0}].[{1}].[JOB].[NAME] AS NAME
      ,[{0}].[{1}].[JOB].[COMMAND] AS COMMAND
      ,[{0}].[{1}].[JOB].[STARTDATE] AS STARTDATE
      ,[{0}].[{1}].[JOB].[EXPIRED] AS EXPIRED
      ,[{0}].[{1}].[JOB].[TRUSTEEUSER] AS TRUSTEEUSER
      ,[{0}].[{1}].[JOB].[MOVEDTOBIN] AS MOVEDTOBIN
      ,[{0}].[{1}].[JOB_JOBDIR].[DIRID] AS DIRID
  FROM [{0}].[{1}].[JOB]
  LEFT JOIN [{0}].[{1}].[JOB_JOBDIR]
  ON [{0}].[{1}].[JOB].[ID] = [{0}].[{1}].[JOB_JOBDIR].[JOBID]
'@ -f $Database, $Schema)
    if (!$JobID)
    {
      $Query = $BaseQuery
      Invoke-Sqlcmd2 @InvokeSqlcmd2Params -Query $Query
    }
    else
    {
      $Query = ((@"
  WHERE [{0}].[{1}].[JOB].[ID] = '{2}'
"@ -f $Database, $Schema, $JobID))
      $Query = ($BaseQuery, $Query -join "`n")
      Invoke-Sqlcmd2 @InvokeSqlcmd2Params -Query $Query
    }
  }
  End
  {
  }
}

