#requires -modules BuildHelpers
#requires -modules @{ ModuleName = "Pester"; ModuleVersion = "4.10.1" }

Describe 'Set-JiraFilter' -Tag 'Unit' {

    BeforeAll {
        Import-Module "$PSScriptRoot/../../../Tools/TestTools.psm1" -force
        Invoke-InitTest $PSScriptRoot

        Import-Module $env:BHManifestToTest -Force
    }
    AfterAll {
        Invoke-TestCleanup
    }

    InModuleScope JiraPS {

        . "$PSScriptRoot/../Shared.ps1"

        #region Definitions
        $jiraServer = "https://jira.example.com"

        $responseFilter = @"
{
    "self": "$jiraServer/rest/api/latest/filter/12844",
    "id": "12844",
    "name": "All JIRA Bugs",
    "owner": {
        "self": "$jiraServer/rest/api/2/user?username=scott@atlassian.com",
        "key": "scott@atlassian.com",
        "name": "scott@atlassian.com",
        "avatarUrls": {
            "16x16": "$jiraServer/secure/useravatar?size=xsmall&avatarId=10612",
            "24x24": "$jiraServer/secure/useravatar?size=small&avatarId=10612",
            "32x32": "$jiraServer/secure/useravatar?size=medium&avatarId=10612",
            "48x48": "$jiraServer/secure/useravatar?avatarId=10612"
        },
        "displayName": "Scott Farquhar [Atlassian]",
        "active": true
    },
    "jql": "project = 10240 AND issuetype = 1 ORDER BY key DESC",
    "viewUrl": "$jiraServer/secure/IssueNavigator.jspa?mode=hide&requestId=12844",
    "searchUrl": "$jiraServer/rest/api/latest/search?jql=project+%3D+10240+AND+issuetype+%3D+1+ORDER+BY+key+DESC",
    "favourite": false,
    "sharePermissions": [
        {
            "id": 10049,
            "type": "global"
        }
    ],
    "sharedUsers": {
        "size": 0,
        "items": [],
        "max-results": 1000,
        "start-index": 0,
        "end-index": 0
    },
    "subscriptions": {
        "size": 0,
        "items": [],
        "max-results": 1000,
        "start-index": 0,
        "end-index": 0
    }
}
"@
        #endregion Definitions

        #region Mocks
        Mock Get-JiraConfigServer -ModuleName JiraPS {
            $jiraServer
        }

        Mock ConvertTo-JiraFilter -ModuleName JiraPS {
            foreach ($i in $InputObject) {
                $i.PSObject.TypeNames.Insert(0, 'JiraPS.Filter')
                $i | Add-Member -MemberType AliasProperty -Name 'RestURL' -Value 'self'
                $i
            }
        }

        Mock Get-JiraFilter -ModuleName JiraPS {
            foreach ($i in $Id) {
                ConvertTo-JiraFilter (ConvertFrom-Json $responseFilter)
            }
        }

        Mock Invoke-JiraMethod -ModuleName JiraPS -ParameterFilter { $Method -eq 'Put' -and $URI -like "$jiraServer/rest/api/*/filter/*" } {
            ShowMockInfo 'Invoke-JiraMethod' 'Method', 'Uri', 'Body'
            ConvertFrom-Json $responseFilter
        }

        Mock Invoke-JiraMethod -ModuleName JiraPS {
            ShowMockInfo 'Invoke-JiraMethod' 'Method', 'Uri'
            throw "Unidentified call to Invoke-JiraMethod"
        }
        #endregion Mocks

        Describe "Sanity checking" {
            $command = Get-Command -Name Set-JiraFilter

            defParam $command 'InputObject'
            defParam $command 'Name'
            defParam $command 'Description'
            defParam $command 'JQL'
            defParam $command 'Favorite'
            defParam $command 'Credential'

            defAlias $command 'Favourite' 'Favorite'
        }

        Describe "Behavior testing" {
            It "Invokes the Jira API to update a filter" {
                {
                    $newData = @{
                        Name        = "newName"
                        Description = "newDescription"
                        JQL         = "newJQL"
                        Favorite    = $true
                    }
                    Get-JiraFilter -Id 12844 | Set-JiraFilter @newData
                } | Should Not Throw

                Assert-MockCalled -CommandName Invoke-JiraMethod -ModuleName JiraPS -Exactly -Times 1 -Scope It -ParameterFilter {
                    $Method -eq 'Put' -and
                    $URI -like '*/rest/api/*/filter/12844' -and
                    $Body -match "`"name`":\s*`"newName`"" -and
                    $Body -match "`"description`":\s*`"newDescription`"" -and
                    $Body -match "`"jql`":\s*`"newJQL`"" -and
                    $Body -match "`"favourite`":\s*true"
                }
            }

            It "Can set the Description to Empty" {
                {
                    $newData = @{
                        Description = ""
                    }
                    Get-JiraFilter -Id 12844 | Set-JiraFilter @newData
                } | Should Not Throw

                Assert-MockCalled -CommandName Invoke-JiraMethod -ModuleName JiraPS -Exactly -Times 1 -Scope It -ParameterFilter {
                    $Method -eq 'Put' -and
                    $URI -like '*/rest/api/*/filter/12844' -and
                    $Body -match "`"description`":\s*`"`""
                }
            }

            It "Skips the filter if no value was changed" {
                { Get-JiraFilter -Id 12844 | Set-JiraFilter } | Should Not Throw

                Assert-MockCalled -CommandName Invoke-JiraMethod -ModuleName JiraPS -Exactly -Times 0 -Scope It
            }
        }

        Describe "Input testing" {
            It "accepts a filter object for the -InputObject parameter" {
                { Set-JiraFilter -InputObject (Get-JiraFilter "12345") -Name "test" } | Should Not Throw

                Assert-MockCalled -CommandName Invoke-JiraMethod -ModuleName JiraPS -Exactly -Times 1 -Scope It
            }

            It "accepts a filter object without the -InputObject parameter" {
                { Set-JiraFilter (Get-JiraFilter "12345") -Name "test" } | Should Not Throw

                Assert-MockCalled -CommandName Invoke-JiraMethod -ModuleName JiraPS -Exactly -Times 1 -Scope It
            }

            It "fails with multiple filter objects to the -Filter parameter" {
                { Set-JiraFilter -InputObject (Get-JiraFilter 12345, 12345) -Name "test" } | Should Throw
            }

            It "accepts a JiraPS.Filter object via pipeline" {
                { Get-JiraFilter 12345, 12345 | Set-JiraFilter -Name "test" } | Should Not Throw

                Assert-MockCalled -CommandName Invoke-JiraMethod -ModuleName JiraPS -Exactly -Times 2 -Scope It
            }

            It "fails if something other than [JiraPS.Filter] is provided to InputObject" {
                { "12345" | Set-JiraFilter -ErrorAction Stop } | Should Throw
                { Set-JiraFilter "12345" -ErrorAction Stop } | Should Throw
            }

            It "accepts -InputObject" {
                {
                    $parameter = @{
                        InputObject = Get-JiraFilter "12345"
                    }
                    Set-JiraFilter @parameter
                } | Should Not Throw

                Assert-MockCalled -CommandName Invoke-JiraMethod -ModuleName JiraPS -Exactly -Times 0 -Scope It
            }
            It "accepts -InputObject and -Name" {
                {
                    $parameter = @{
                        InputObject = Get-JiraFilter "12345"
                        Name        = "newName"
                    }
                    Set-JiraFilter @parameter
                } | Should Not Throw

                Assert-MockCalled -CommandName Invoke-JiraMethod -ModuleName JiraPS -Exactly -Times 1 -Scope It
            }
            It "accepts -InputObject and -Description" {
                {
                    $parameter = @{
                        InputObject = Get-JiraFilter "12345"
                        Description = "newDescription"
                    }
                    Set-JiraFilter @parameter
                } | Should Not Throw

                Assert-MockCalled -CommandName Invoke-JiraMethod -ModuleName JiraPS -Exactly -Times 1 -Scope It
            }
            It "accepts -InputObject and -JQL" {
                {
                    $parameter = @{
                        InputObject = Get-JiraFilter "12345"
                        JQL         = "newJQL"
                    }
                    Set-JiraFilter @parameter
                } | Should Not Throw

                Assert-MockCalled -CommandName Invoke-JiraMethod -ModuleName JiraPS -Exactly -Times 1 -Scope It
            }
            It "accepts -InputObject and -Favorite" {
                {
                    $parameter = @{
                        InputObject = Get-JiraFilter "12345"
                        Favorite    = $true
                    }
                    Set-JiraFilter @parameter
                } | Should Not Throw

                Assert-MockCalled -CommandName Invoke-JiraMethod -ModuleName JiraPS -Exactly -Times 1 -Scope It
            }
            It "accepts -InputObject and -Name and -Description" {
                {
                    $parameter = @{
                        InputObject = Get-JiraFilter "12345"
                        Name        = "newName"
                        Description = "newDescription"
                    }
                    Set-JiraFilter @parameter
                } | Should Not Throw

                Assert-MockCalled -CommandName Invoke-JiraMethod -ModuleName JiraPS -Exactly -Times 1 -Scope It
            }
            It "accepts -InputObject and -Name and -JQL" {
                {
                    $parameter = @{
                        InputObject = Get-JiraFilter "12345"
                        Name        = "newName"
                        JQL         = "newJQL"
                    }
                    Set-JiraFilter @parameter
                } | Should Not Throw

                Assert-MockCalled -CommandName Invoke-JiraMethod -ModuleName JiraPS -Exactly -Times 1 -Scope It
            }
            It "accepts -InputObject and -Name and -Favorite" {
                {
                    $parameter = @{
                        InputObject = Get-JiraFilter "12345"
                        Name        = "newName"
                        Favorite    = $true
                    }
                    Set-JiraFilter @parameter
                } | Should Not Throw

                Assert-MockCalled -CommandName Invoke-JiraMethod -ModuleName JiraPS -Exactly -Times 1 -Scope It
            }
            It "accepts -InputObject and -Name and -Description and -JQL" {
                {
                    $parameter = @{
                        InputObject = Get-JiraFilter "12345"
                        Name        = "newName"
                        Description = "newDescription"
                        JQL         = "newJQL"
                    }
                    Set-JiraFilter @parameter
                } | Should Not Throw

                Assert-MockCalled -CommandName Invoke-JiraMethod -ModuleName JiraPS -Exactly -Times 1 -Scope It
            }
            It "accepts -InputObject and -Name and -Description and -Favorite" {
                {
                    $parameter = @{
                        InputObject = Get-JiraFilter "12345"
                        Name        = "newName"
                        Description = "newDescription"
                        Favorite    = $true
                    }
                    Set-JiraFilter @parameter
                } | Should Not Throw

                Assert-MockCalled -CommandName Invoke-JiraMethod -ModuleName JiraPS -Exactly -Times 1 -Scope It
            }
            It "accepts -InputObject and -Name and -Description and -JQL and -Favorite" {
                {
                    $parameter = @{
                        InputObject = Get-JiraFilter "12345"
                        Name        = "newName"
                        Description = "newDescription"
                        JQL         = "newJQL"
                        Favorite    = $true
                    }
                    Set-JiraFilter @parameter
                } | Should Not Throw

                Assert-MockCalled -CommandName Invoke-JiraMethod -ModuleName JiraPS -Exactly -Times 1 -Scope It
            }
        }
    }
}
