function Get-UMSPropertyCast
{
  <#
  .EXAMPLE
  Get-UMSPropertyCast -APIObjectColl $APIObjectColl -CastedPropertyColl $CastedPropertyColl

  #>

  [CmdletBinding()]
  param (
    [Parameter(Mandatory)]
    $APIObjectColl,

    [Parameter(Mandatory)]
    $PropertyColl
  )

  begin
  {
  }
  process
  {
    $Result = foreach ($APIObject in $APIObjectColl)
    {
      $CastedPropertyColl = [ordered]@{ }
      foreach ($StringProperty in ($APIObject | Get-Member -MemberType NoteProperty | Sort-Object -Property Name))
      {
        $StringPropertyName = ($StringProperty.Name).Replace(($StringProperty.Name)[0], ([String]($StringProperty.Name)[0]).ToUpper())
        if ([String]$APIObject.($StringPropertyName))
        {
          switch ($StringPropertyName)
          {
            ( { $_ -in $PropertyColl.Int })
            {
              $CastedPropertyColl.Add($StringPropertyName, [Int]$APIObject.($StringPropertyName))
            }
            ( { $_ -in $PropertyColl.Int64 })
            {
              $CastedPropertyColl.Add($StringPropertyName, [Int64]$APIObject.($StringPropertyName))
            }
            ( { $_ -in $PropertyColl.Datetime })
            {
              $CastedPropertyColl.Add($StringPropertyName, [System.Convert]::ToDateTime($APIObject.($StringPropertyName)))
            }
            ( { $_ -in $PropertyColl.Bool })
            {
              $CastedPropertyColl.Add($StringPropertyName, [System.Convert]::ToBoolean($APIObject.($StringPropertyName)))
            }
            ( { $_ -in $PropertyColl.Xml })
            {
              $CastedPropertyColl.Add($StringPropertyName, [xml]$APIObject.($StringPropertyName))
            }
            ( { $_ -in $PropertyColl.Pscustomobject })
            {
              $CastedPropertyColl.Add($StringPropertyName, [pscustomobject]$APIObject.($StringPropertyName))
            }
            Default
            {
              $CastedPropertyColl.Add($StringPropertyName, [String]$APIObject.($StringPropertyName))
            }
          }
        }
        else
        {
          $CastedPropertyColl.Add($StringPropertyName, $null)
        }
      }
      New-Object psobject -Property $CastedPropertyColl
    }
    $Result
  }
  end
  {
  }
}