#requires -modules @{ ModuleName = "Pester"; ModuleVersion = "5.0" }

Describe 'Remove-JiraFilter' -Tag 'Unit' {

    BeforeAll {
        Import-Module "$PSScriptRoot/../../Tools/TestTools.psm1" -Force
        Invoke-InitTest $PSScriptRoot

        Import-Module "$PSScriptRoot/../../JiraPS" -Force
    }
    AfterAll {
        Invoke-TestCleanup
    }

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

    Mock Invoke-JiraMethod -ModuleName JiraPS -ParameterFilter { $Method -eq 'Delete' -and $URI -like "$jiraServer/rest/api/*/filter/*" } {
        Write-MockInfo 'Invoke-JiraMethod' @{ Method = $Method; Uri = $Uri }
        ConvertFrom-Json $responseFilter
    }

    Mock Invoke-JiraMethod -ModuleName JiraPS {
        Write-MockInfo 'Invoke-JiraMethod' @{ Method = $Method; Uri = $Uri }
        throw "Unidentified call to Invoke-JiraMethod"
    }
    #endregion Mocks

    Describe "Sanity checking" {
        $command = Get-Command -Name Remove-JiraFilter

        It "has a parameter 'Filter' of type [AtlassianPS.JiraPS.Filter]" {
            $command | Should -HaveParameter "Filter" -Type [AtlassianPS.JiraPS.Filter]
        }

        It "has an alias 'Id' for parameter 'Filter" {
            $command | Should -HaveParameter "Filter" -Alias "Id"
        }

        It "has a parameter 'Credential' of type [PSCredential]" {
            $command | Should -HaveParameter "Credential" -Type [PSCredential]
        }
    }

    Describe "Behavior testing" {
        Get-JiraFilter -Id 12844
        It "deletes a filter based on one or more InputObjects" {
            { Get-JiraFilter -Id 12844 | Remove-JiraFilter } | Should -Not -Throw

            Assert-MockCalled -CommandName Invoke-JiraMethod -ModuleName JiraPS -Exactly -Times 1 -Scope It -ParameterFilter { $Method -eq 'Delete' -and $URI -like '*/rest/api/*/filter/12844' }
        }

        It "deletes a filter based on one ore more filter ids" {
            { Remove-JiraFilter -Id 12844 } | Should -Not -Throw

            Assert-MockCalled -CommandName Get-JiraFilter -ModuleName JiraPS -Exactly -Times 1 -Scope It
            Assert-MockCalled -CommandName Invoke-JiraMethod -ModuleName JiraPS -Exactly -Times 1 -Scope It -ParameterFilter { $Method -eq 'Delete' -and $URI -like '*/rest/api/*/filter/12844' }
        }
    }

    Describe "Input testing" {
        It "Accepts a filter object for the -InputObject parameter" {
            { Remove-JiraFilter -InputObject (Get-JiraFilter "12345") } | Should -Not -Throw

            Assert-MockCalled -CommandName Invoke-JiraMethod -ModuleName JiraPS -Exactly -Times 1 -Scope It
        }

        It "Accepts a filter object without the -InputObject parameter" {
            { Remove-JiraFilter (Get-JiraFilter "12345") } | Should -Not -Throw

            Assert-MockCalled -CommandName Invoke-JiraMethod -ModuleName JiraPS -Exactly -Times 1 -Scope It
        }

        It "Accepts multiple filter objects to the -Filter parameter" {
            { Remove-JiraFilter -InputObject (Get-JiraFilter 12345, 12345) } | Should -Not -Throw

            Assert-MockCalled -CommandName Invoke-JiraMethod -ModuleName JiraPS -Exactly -Times 2 -Scope It
        }

        It "Accepts a JiraPS.Filter object via pipeline" {
            { Get-JiraFilter 12345, 12345 | Remove-JiraFilter } | Should -Not -Throw

            Assert-MockCalled -CommandName Invoke-JiraMethod -ModuleName JiraPS -Exactly -Times 2 -Scope It
        }

        It "Accepts an ID of a filter" {
            { Remove-JiraFilter -Id 12345 } | Should -Not -Throw

            Assert-MockCalled -CommandName Invoke-JiraMethod -ModuleName JiraPS -Exactly -Times 1 -Scope It
        }

        It "Accepts multiple IDs of filters" {
            { Remove-JiraFilter -Id 12345, 12345 } | Should -Not -Throw

            Assert-MockCalled -CommandName Invoke-JiraMethod -ModuleName JiraPS -Exactly -Times 2 -Scope It
        }

        It "Accepts multiple IDs of filters over the pipeline" {
            { 12345, 12345 | Remove-JiraFilter } | Should -Not -Throw

            Assert-MockCalled -CommandName Invoke-JiraMethod -ModuleName JiraPS -Exactly -Times 2 -Scope It
        }

        It "fails if a negative number is passed as ID" {
            { Remove-JiraFilter -Id -1 } | Should -Throw
        }

        It "fails if something other than [JiraPS.Filter] is provided" {
            { Get-Date | Remove-JiraFilter -ErrorAction Stop } | Should -Throw
            { Remove-JiraFilter "12345" -ErrorAction Stop } | Should -Throw
        }
    }
}
