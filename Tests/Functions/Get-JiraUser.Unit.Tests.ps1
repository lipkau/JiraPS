#requires -modules BuildHelpers
#requires -modules @{ ModuleName = "Pester"; ModuleVersion = "4.4.0" }

Describe "Get-JiraUser" -Tag 'Unit' {

    BeforeAll {
        Import-Module "$PSScriptRoot/../../Tools/TestTools.psm1" -force
        Invoke-InitTest $PSScriptRoot

        Import-Module $env:BHManifestToTest -force
    }
    AfterAll {
        Invoke-TestCleanup
    }

    #Sample response from the server
    <# {
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
    } #>

    #region Mocking
    Mock Get-JiraConfigServer -ModuleName $env:BHProjectName {
        'http://jiraserver.example.com'
    }

    # Return the basic information of the current user
    Mock Invoke-JiraMethod -ModuleName $env:BHProjectName -ParameterFilter { $Method -eq 'Get' -and $Uri -like "*/rest/api/*/myself" } {
        ShowMockInfo 'Invoke-JiraMethod' @{Method = $Method; Uri = $Uri }
        ConvertFrom-Json -InputObject "{`"restUrl`":`"http://jiraserver.example.com/rest/api/2/user?accountId=000000`"}"
    }

    # Return user details based on accountId
    # -- This is how Jira Cloud works
    Mock Invoke-JiraMethod -ModuleName $env:BHProjectName -ParameterFilter { $Uri -like "*/rest/api/*/user?accountId=*" } {
        ShowMockInfo 'Invoke-JiraMethod' @{Method = $Method; Uri = $Uri }
        ConvertFrom-Json -InputObject "{`"accountId`":`"000000:00000000-0000-0000-0000-0000000000`", `"EmailAddress`": `"user@example.com`", `"displayName`":`"Jon Doe`"}"
    }

    # Return user details based on username
    # -- This is how Jira Server works
    Mock Invoke-JiraMethod -ModuleName $env:BHProjectName -ParameterFilter { $Uri -like "*/rest/api/*/user?username=*" } {
        ShowMockInfo 'Invoke-JiraMethod' @{Method = $Method; Uri = $Uri }
        ConvertFrom-Json -InputObject "{`"key`":`"jon.doe`", `"EmailAddress`": `"user@example.com`", `"displayName`":`"Jon Doe`"}"
    }

    # Generic catch-all. This will throw an exception if we forgot to mock something.
    Mock Invoke-JiraMethod -ModuleName $env:BHProjectName {
        ShowMockInfo 'Invoke-JiraMethod' @{Method = $Method; Uri = $Uri }
        throw "Unidentified call to Invoke-JiraMethod"
    }
    #endregion Mocking

    Context "Sanity checking" {
        $command = Get-Command -Name Get-JiraUser

        It "has a parameter 'Credential' of type [PSCredential]" {
            $command | Should -HaveParameter "Credential" -Type [PSCredential]
        }

        <# It "has a parameter 'Credential' with a default value" {
            $command | Should -HaveParameter "Credential" -DefaultValue "[System.Management.Automation.PSCredential]::Empty"
        } #>

        It "defines the OutputType" {
            $command.OutputType.Name | Should -not -BeNullOrEmpty
        }

        Context "ParameterSet: Self" {
            $parameterSetName = "Self"
            $parameterSet = $command.ParameterSets | Where-Object { $_.name -eq $parameterSetName }

            It "is the dafault ParameterSet" {
                $command.DefaultParameterSet | Should -Be $parameterSetName

                $parameterSet.IsDefault | Should -Be $true
            }

            It "has not mandatory parameters" {
                $parameterSet.Parameters.IsMandatory | Should -not -Contain $true
            }
        }

        Context "ParameterSet: ByUserName" {
            It "has a mandatory parameter 'UserName'" {
                $command | Should -HaveParameter "UserName" -Mandatory
            }

            It "has a parameter 'UserName' of type [AtlassianPS.JiraPS.User[]]" {
                $command | Should -HaveParameter "UserName" -Type [AtlassianPS.JiraPS.User[]]
            }
        }
    }

    Context "Behavior checking" {
        It "gets the intormation about the logged in user" {
            $getResult = Get-JiraUser

            $getResult | Should -not -BeNullOrEmpty

            $assertMockCalledSplat = @{
                CommandName     = "Invoke-JiraMethod"
                ModuleName      = $env:BHProjectName
                ParameterFilter = {
                    $OutputType -eq "JiraUser"
                }
                Exactly         = $true
                Times           = 2
                Scope           = 'It'
            }
            Assert-MockCalled @assertMockCalledSplat
            Assert-MockCalled -CommandName Invoke-JiraMethod -ModuleName $env:BHProjectName -Exactly -Times 1 -Scope It -ParameterFilter { $URI -like "*/rest/api/*/myself" }
            Assert-MockCalled -CommandName Invoke-JiraMethod -ModuleName $env:BHProjectName -Exactly -Times 1 -Scope It -ParameterFilter { $URI -like "*/rest/api/*/user?accountId=*&expand=groups" }
        }

        It "gets user information based on accountId" {
            $getResult = Get-JiraUser -UserName "000000:00000000-0000-0000-0000-0000000000"

            $getResult | Should -not -BeNullOrEmpty

            $assertMockCalledSplat = @{
                CommandName     = "Invoke-JiraMethod"
                ModuleName      = $env:BHProjectName
                ParameterFilter = {
                    $OutputType -eq "JiraUser" -and
                    $URI -like "*/rest/api/*/user?accountId=*&expand=groups"
                }
                Exactly         = $true
                Times           = 1
                Scope           = 'It'
            }
            Assert-MockCalled @assertMockCalledSplat
        }

        It "gets user information based on userkey" {
            $getResult = Get-JiraUser -UserName "jon.doe"

            $getResult | Should -not -BeNullOrEmpty

            $assertMockCalledSplat = @{
                CommandName     = "Invoke-JiraMethod"
                ModuleName      = $env:BHProjectName
                ParameterFilter = {
                    $OutputType -eq "JiraUser" -and
                    $URI -like "*/rest/api/*/user?username=*&expand=groups"
                }
                Exactly         = $true
                Times           = 1
                Scope           = 'It'
            }
            Assert-MockCalled @assertMockCalledSplat
        }
    }


    <# It "Gets information about a provided Jira user" {
        $getResult = Get-JiraUser -UserName $testUsername

        $getResult | Should Not BeNullOrEmpty

        Assert-MockCalled -CommandName Invoke-JiraMethod -Exactly 1 -Scope It -ParameterFilter { $URI -like "http://jiraserver.example.com/rest/api/*/user/search?*username=$testUsername*" }
        Assert-MockCalled -CommandName Invoke-JiraMethod -Exactly 1 -Scope It -ParameterFilter { $URI -like "http://jiraserver.example.com/rest/api/*/user?username=$testUsername&expand=groups" }
    }

    It "Gets information about a provided Jira exact user" {
        $getResult = Get-JiraUser -UserName $testUsername -Exact

        $getResult | Should Not BeNullOrEmpty

        Assert-MockCalled -CommandName Invoke-JiraMethod -Exactly 1 -Scope It -ParameterFilter { $Method -eq 'Get' -and $URI -like "http://jiraserver.example.com/rest/api/*/user?username=$testUsername" }
        Assert-MockCalled -CommandName Invoke-JiraMethod -Exactly 1 -Scope It -ParameterFilter { $URI -like "http://jiraserver.example.com/rest/api/*/user?username=$testUsername&expand=groups" }
    }

    It "Returns all available properties about the returned user object" {
        $getResult = Get-JiraUser -UserName $testUsername

        $restObj = ConvertFrom-Json -InputObject $restResult

        $getResult.self | Should Be $restObj.self
        $getResult.Name | Should Be $restObj.name
        $getResult.DisplayName | Should Be $restObj.displayName
        $getResult.Active | Should Be $restObj.active

        Assert-MockCalled -CommandName Invoke-JiraMethod -Exactly 1 -Scope It -ParameterFilter { $URI -like "http://jiraserver.example.com/rest/api/*/user?username=$testUsername&expand=groups" }
    }

    It "Gets information for a provided Jira user if a JiraPS.User object is provided to the InputObject parameter" {
        $getResult = Get-JiraUser -UserName $testUsername
        $result2 = Get-JiraUser -InputObject $getResult

        $result2 | Should Not BeNullOrEmpty
        $result2.Name | Should Be $testUsername

        Assert-MockCalled -CommandName Invoke-JiraMethod -Exactly 2 -Scope It -ParameterFilter { $URI -like "http://jiraserver.example.com/rest/api/*/user?username=$testUsername&expand=groups" }
    }

    It "Allow it search for multiple users" {
        Get-JiraUser -UserName "%"

        Assert-MockCalled -CommandName Invoke-JiraMethod -Exactly 1 -Scope It -ParameterFilter {
            $URI -like "http://jiraserver.example.com/rest/api/*/user/search?*username=%25*"
        }
    }

    It "Allows to change the max number of users to be returned" {
        Get-JiraUser -UserName "%" -MaxResults 100

        Assert-MockCalled -CommandName Invoke-JiraMethod -Exactly 1 -Scope It -ParameterFilter {
            $URI -like "http://jiraserver.example.com/rest/api/*/user/search?*maxResults=100*"
        }
    }

    It "Can skip a certain amount of results" {
        Get-JiraUser -UserName "%" -Skip 10

        Assert-MockCalled -CommandName Invoke-JiraMethod -Exactly 1 -Scope It -ParameterFilter {
            $URI -like "http://jiraserver.example.com/rest/api/*/user/search?*startAt=10*"
        }
    }

    It "Provides information about the user's group membership in Jira" {
        $getResult = Get-JiraUser -UserName $testUsername

        $getResult.groups.size | Should Be 2
        $getResult.groups.items[0].Name | Should Be $testGroup1
    } #>

}
