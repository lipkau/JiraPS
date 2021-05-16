#requires -modules @{ ModuleName = "Pester"; ModuleVersion = "5.0" }

Describe "Find-JiraUser" -Tag 'Unit' {

    BeforeAll {
        Import-Module "$PSScriptRoot/../../Tools/TestTools.psm1" -Force
        Invoke-InitTest $PSScriptRoot

        Import-Module "$PSScriptRoot/../../JiraPS" -Force
    }
    AfterAll {
        Invoke-TestCleanup
    }

    #Sample response from the server
    <# [
        {
            "self":"http://jiraserver.example.com/rest/api/2/user?accountId=000000:00000000-0000-0000-0000-0000000000",
            "accountId":"000000:00000000-0000-0000-0000-0000000000",
            "EmailAddress": "user@example.com",
            "accountType":"atlassian",
            "avatarUrls":{
                "48x48":"https://avatar-management--avatars.us-west-2.prod.public.atl-paas.net/.../128?size=48&s=48",
                "24x24":"https://avatar-management--avatars.us-west-2.prod.public.atl-paas.net/.../128?size=24&s=24",
                "16x16":"https://avatar-management--avatars.us-west-2.prod.public.atl-paas.net/.../128?size=16&s=16",
                "32x32":"https://avatar-management--avatars.us-west-2.prod.public.atl-paas.net/.../128?size=32&s=32"
            },
            "displayName":"Jon Doe",
            "active":true,
            "timeZone":"Europe/Berlin",
            "locale":"en_US",
            "groups":{
                "size":1,
                "items":[
                    {
                        "name":"administrators",
                        "self":"http://jiraserver.example.com/rest/api/2/group?groupname=administrators"
                    }
                ]
            }
        }
    ] #>

    #region Mocking
    Mock Get-JiraConfigServer -ModuleName JiraPS {
        'http://jiraserver.example.com'
    }

    # Responds for ?query=
    # -- This is how Jira Cloud works
    Mock Invoke-JiraMethod -ModuleName JiraPS -ParameterFilter { $Uri -like "*/rest/api/*/user/search?query=*" } {
        Write-MockInfo 'Invoke-JiraMethod' @{ Method = $Method; Uri = $Uri }
        ConvertFrom-Json -InputObject "[{`"accountId`":`"000000:00000000-0000-0000-0000-0000000000`", `"EmailAddress`": `"user@example.com`", `"displayName`":`"Jon Doe`"}]"
    }

    # Responds to ?username=
    # -- This is how Jira Server works
    Mock Invoke-JiraMethod -ModuleName JiraPS -ParameterFilter { $Uri -like "*/rest/api/*/user/search?username=*" } {
        Write-MockInfo 'Invoke-JiraMethod' @{ Method = $Method; Uri = $Uri }
        ConvertFrom-Json -InputObject "[{`"key`":`"jon.doe`", `"EmailAddress`": `"user@example.com`", `"displayName`":`"Jon Doe`"}]"
    }

    # Generic catch-all. This will throw an exception if we forgot to mock something.
    Mock Invoke-JiraMethod -ModuleName JiraPS {
        Write-MockInfo 'Invoke-JiraMethod' @{ Method = $Method; Uri = $Uri }
        throw "Unidentified call to Invoke-JiraMethod"
    }
    #endregion Mocking

    Describe "Sanity checking" {
        $command = Get-Command -Name Find-JiraUser

        It "has a parameter 'IncludeInactive' of type [Switch]" {
            $command | Should -HaveParameter "IncludeInactive" -Type [Switch]
        }

        It "has a parameter 'Credential' of type [PSCredential]" {
            $command | Should -HaveParameter "Credential" -Type [PSCredential]
        }

        It "has a parameter 'Skip' of type [UInt64]" {
            $command | Should -HaveParameter "Skip" -Type [UInt64]
        }

        It "has a parameter 'PageSize' of type [UInt32]" {
            $command | Should -HaveParameter "PageSize" -Type [UInt32]
        }

        <# It "has a parameter 'Credential' with a default value" {
            $command | Should -HaveParameter "Credential" -DefaultValue "[System.Management.Automation.PSCredential]::Empty"
        } #>

        It "defines the OutputType" {
            $command.OutputType.Name | Should -not -BeNullOrEmpty
        }

        Describe "ParameterSet: ByEmailAddress" {
            $parameterSetName = "ByEmailAddress"
            $parameterSet = $command.ParameterSets | Where-Object { $_.Name -eq $parameterSetName }

            It "has has a mandatory parameter 'EmailAddress'" {
                $parameter = $parameterSet.parameters | Where-Object { $_.Name -eq "EmailAddress" }

                $parameter | Should -not -BeNullOrEmpty
                $parameter.IsMandatory | Should -Be $true
            }
        }

        Describe "ParameterSet: ByUserName" {
            $parameterSetName = "ByUserName"
            $parameterSet = $command.ParameterSets | Where-Object { $_.Name -eq $parameterSetName }

            It "has has a mandatory parameter 'UserName'" {
                $parameter = $parameterSet.parameters | Where-Object { $_.Name -eq "UserName" }

                $parameter | Should -not -BeNullOrEmpty
                $parameter.IsMandatory | Should -Be $true
            }
        }
    }

    Describe "Behavior checking" {
        It "finds a user by it's email address" {
            $getResult = Find-JiraUser -EmailAddress "jon.doe@example.com"

            $getResult | Should -not -BeNullOrEmpty

            $assertMockCalledSplat = @{
                CommandName     = "Invoke-JiraMethod"
                ModuleName      = JiraPS
                ParameterFilter = {
                    $Uri -like "*/rest/api/*/user/search?query=*" -and
                    $OutputType -eq "JiraUser"
                }
                Exactly         = $true
                Times           = 1
                Scope           = 'It'
            }
            Assert-MockCalled @assertMockCalledSplat
        }

        It "finds a user by it's username" {
            $getResult = Find-JiraUser -UserName "jon.doe"

            $getResult | Should -not -BeNullOrEmpty

            $assertMockCalledSplat = @{
                CommandName     = "Invoke-JiraMethod"
                ModuleName      = JiraPS
                ParameterFilter = {
                    $Uri -like "*/rest/api/*/user/search?username=*" -and
                    $OutputType -eq "JiraUser"
                }
                Exactly         = $true
                Times           = 1
                Scope           = 'It'
            }
            Assert-MockCalled @assertMockCalledSplat
        }

        It "allows for EmailAddress to be empty" {
            $getResult = Find-JiraUser -EmailAddress ""

            $getResult | Should -not -BeNullOrEmpty
        }

        It "allows for UserName to be empty" {
            $getResult = Find-JiraUser -UserName ""

            $getResult | Should -not -BeNullOrEmpty
        }
    }
}
