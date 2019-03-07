$Script:ProjectRoot = Resolve-Path ('{0}\..' -f $PSScriptRoot)
$Script:ModuleRoot = Split-Path (Resolve-Path ('{0}\*\*.psm1' -f $Script:ProjectRoot))
$Script:ModuleName = Split-Path $Script:ModuleRoot -Leaf
$Script:ModuleManifest = Resolve-Path ('{0}/{1}.psd1' -f $Script:ModuleRoot, $Script:ModuleName)
$Script:FunctionName = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")
Import-Module ( '{0}/{1}.psm1' -f $Script:ModuleRoot, $Script:ModuleName)

Describe "$Script:FunctionName Unit Tests" -Tag 'UnitTests' {

  BeforeAll {
    if ($null -ne $Result)
    {
      Clear-Variable -Name $Result
    }
  }

  Context "Basics" {

    It "Is valid Powershell (Has no script errors)" {
      $Content = Get-Content -Path ( '{0}\Public\{1}.ps1' -f $Script:ModuleRoot, $Script:FunctionName) -ErrorAction Stop
      $ErrorColl = $Null
      $Null = [System.Management.Automation.PSParser]::Tokenize($Content, [ref]$ErrorColl)
      $ErrorColl | Should -HaveCount 0
    }

    [object[]]$params = (Get-ChildItem function:\$Script:FunctionName).Parameters.Keys
    $KnownParameters = 'Computername', 'TCPPort', 'ApiVersion', 'SecurityProtocol', 'WebSession', 'Id', 'Directory'

    It "Should contain our specific parameters" {
      (@(Compare-Object -ReferenceObject $KnownParameters -DifferenceObject $params -IncludeEqual |
            Where-Object SideIndicator -eq "==").Count) | Should Be $KnownParameters.Count
    }
  }

  InModuleScope $Script:ModuleName {

    $PSDefaultParameterValues = @{
      '*:WebSession'                = New-MockObject -Type 'System.Management.Automation.PSCustomObject'
      '*:Computername'              = 'igelrmserver.acme.org'
      'Get-UMSProfileAssignment:Id' = 2
    }

    Context "General Execution" {

      Mock 'Invoke-UMSRestMethodWebSession' {}

      It 'Get-UMSProfileAssignment Should not throw' {
        { Get-UMSProfileAssignment } | Should -Not -Throw
      }

      It 'Get-UMSProfileAssignment -ApiVersion 10 Stop Should throw' {
        { Get-UMSProfileAssignment -ApiVersion 10 -ErrorAction Stop } | Should -Throw
      }

    }

    Context "ParameterSetName Endpoint" {

      Mock 'Invoke-UMSRestMethodWebSession' {
        (
          [pscustomobject]@{
            SyncRoot = @{
              assignee           = @{
                id   = '2'
                type = 'profile'
              }
              receiver           = @{
                id   = '2'
                type = 'tc'
              }
              assignmentPosition = 0
            }
          }
        )
      }

      $Result = Get-UMSProfileAssignment -Id 2

      It 'Assert Invoke-UMSRestMethodWebSession is called exactly 1 time' {
        $AMCParams = @{
          CommandName = 'Invoke-UMSRestMethodWebSession'
          Times       = 1
          Exactly     = $true
        }
        Assert-MockCalled @AMCParams
      }

      It 'Result should have type pscustomobject' {
        $Result | Should -HaveType ([pscustomobject])
      }

      It 'Result should have 1 element' {
        @($Result).Count | Should BeExactly 1
      }

      It 'Result[0].Id should be exactly 2' {
        $Result[0].Id | Should BeExactly 2
      }

      It 'Result[0].Id should have type [Int]' {
        $Result[0].Id | Should -HaveType [Int]
      }
    }

    Context "ParameterSetName Directory" {

      Mock 'Invoke-UMSRestMethodWebSession' {
        (
          [pscustomobject]@{
            SyncRoot = @{
              assignee           = @{
                id   = '2'
                type = 'profile'
              }
              receiver           = @{
                id   = '2'
                type = 'tcdirectory'
              }
              assignmentPosition = 0
            }
          }
        )
      }

      $Result = Get-UMSProfileAssignment -Id 2 -Directory

      It 'Assert Invoke-UMSRestMethodWebSession is called exactly 1 time' {
        $AMCParams = @{
          CommandName = 'Invoke-UMSRestMethodWebSession'
          Times       = 1
          Exactly     = $true
        }
        Assert-MockCalled @AMCParams
      }

      It 'Result should have type pscustomobject' {
        $Result | Should -HaveType ([pscustomobject])
      }

      It 'Result should have 1 element' {
        @($Result).Count | Should BeExactly 1
      }

      It 'Result[0].Id should be exactly 2' {
        $Result[0].Id | Should BeExactly 2
      }

      It 'Result[0].Id should have type [Int]' {
        $Result[0].Id | Should -HaveType [Int]
      }
    }

    Context "Error Handling" {
      Mock 'Invoke-UMSRestMethodWebSession' {throw 'Error'}

      it 'should throw Error' {
        { Get-UMSProfileAssignment } | should throw 'Error'
      }

      It 'Result should be null or empty' {
        $Result | Should BeNullOrEmpty
      }
    }
  }
}

Describe "$Script:FunctionName Integration Tests" -Tag "IntegrationTests" {
  BeforeAll {
    if ($null -ne $Result)
    {
      Clear-Variable -Name $Result
    }
  }

  $UMS = Get-Content -Raw -Path ('{0}\Tests\UMS.json' -f $Script:ProjectRoot) |
    ConvertFrom-Json
  $CredPath = $UMS.CredPath
  $Password = Get-Content $CredPath | ConvertTo-SecureString
  $Credential = New-Object System.Management.Automation.PSCredential($UMS.User, $Password)
  $Id = $UMS.UMSProfileAssignment[0].id
  $ReceiverID = $UMS.UMSProfileAssignment[0].ReceiverID

  $PSDefaultParameterValues = @{
    '*-UMS*:Credential'                  = $Credential
    '*-UMS*:Computername'                = $UMS.Computername
    '*-UMS*:SecurityProtocol'            = $UMS.SecurityProtocol
    '*-UMS*:Id'                          = $Id
    'Get-UMSProfileAssignment:Directory' = $true
  }

  $WebSession = New-UMSAPICookie -Credential $Credential
  $PSDefaultParameterValues += @{
    '*-UMS*:WebSession' = $WebSession
  }

  Context "ParameterSetName All" {

    It "doesn't throw" {
      { $Script:Result = Get-UMSProfileAssignment } | Should Not Throw
    }

    It 'Result should not be null or empty' {
      $Result | Should not BeNullOrEmpty
    }

    It 'Result.Id should have type [Int]' {
      $Result.Id | Should -HaveType [Int]
    }

    It "Result.Id should be exactly $Id)" {
      $Result.Id | Should -BeExactly $Id
    }

    It 'Result.ReceiverID should have type [Int]' {
      $Result.ReceiverID | Should -HaveType [Int]
    }

    It "Result.ReceiverID should be exactly $ReceiverID" {
      $Result.ReceiverID | Should -BeExactly $ReceiverID
    }
  }
}