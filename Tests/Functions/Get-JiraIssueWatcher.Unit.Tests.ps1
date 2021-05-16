#requires -modules @{ ModuleName = "Pester"; ModuleVersion = "5.0" }

Describe "Get-JiraIssueWatcher" -Tag 'Unit' {

    BeforeAll {
        Import-Module "$PSScriptRoot/../../Tools/TestTools.psm1" -Force
        Invoke-InitTest $PSScriptRoot

        Import-Module "$PSScriptRoot/../../JiraPS" -Force
    }
    AfterAll {
        Invoke-TestCleanup
    }

    $jiraServer = 'https://jiraserver.example.com'
    $issueID = 41701
    $issueKey = 'IT-3676'


    ## Sample straight from the API:
    ##    https://docs.atlassian.com/jira/REST/cloud/#api/2/issue-getIssueWatchers
    $restResult = @"
{
    "self": "$jiraServer/jira/rest/api/2/issue/EX-1/watchers",
    "isWatching": false,
    "watchCount": 1,
    "watchers": [
        {
            "self": "$jiraServer/jira/rest/api/2/user?username=fred",
            "name": "fred",
            "displayName": "Fred F. User",
            "active": false
        }
    ]
}
"@
    Mock Get-JiraConfigServer -ModuleName JiraPS {
        Write-Output $jiraServer
    }

    Mock Get-JiraIssue -ModuleName JiraPS {
        $object = [PSCustomObject] @{
            ID      = $issueID
            Key     = $issueKey
            RestUrl = "$jiraServer/rest/api/latest/issue/$issueID"
        }
        $object.PSObject.TypeNames.Insert(0, 'JiraPS.Issue')
        return $object
    }

    Mock Resolve-JiraIssueObject -ModuleName JiraPS {
        Get-JiraIssue -Issue $Issue
    }

    # Obtaining watchers from an issue...this is IT-3676 in the test environment
    Mock Invoke-JiraMethod -ModuleName JiraPS -ParameterFilter { $Method -eq 'Get' -and $URI -eq "$jiraServer/rest/api/latest/issue/$issueID/watchers" } {
        Write-MockInfo 'Invoke-JiraMethod' @{ Method = $Method; Uri = $Uri }
        ConvertFrom-Json -InputObject $restResult
    }

    # Generic catch-all. This will throw an exception if we forgot to mock something.
    Mock Invoke-JiraMethod -ModuleName JiraPS {
        Write-MockInfo 'Invoke-JiraMethod' @{ Method = $Method; Uri = $Uri }
        throw "Unidentified call to Invoke-JiraMethod"
    }

    #############
    # Tests
    #############

    Describe "Sanity checking" {
        $command = Get-Command -Name Get-JiraIssueWatcher

        It "has a parameter 'Issue' of type [Object]" {
            $command | Should -HaveParameter "Issue" -Type [Object]
        }

        It "has an alias 'Key' for parameter 'Issue" {
            $command | Should -HaveParameter "Issue" -Alias "Key"
        }

        It "has a parameter 'Credential' of type [PSCredential]" {
            $command | Should -HaveParameter "Credential" -Type [PSCredential]
        }
    }

    Describe "Behavior testing" {

        It "Obtains all Jira watchers from a Jira issue if the issue key is provided" {
            $watchers = Get-JiraIssueWatcher -Issue $issueKey
            $watchers | Should -Not -BeNullOrEmpty
            @($watchers).Count | Should -Be 1
            $watchers.Name | Should -Be "fred"
            $watchers.DisplayName | Should -Be "Fred F. User"
            $watchers.self | Should -Be "$jiraServer/jira/rest/api/2/user?username=fred"

            # Get-JiraIssue Should -Be called to identify the -Issue parameter
            Assert-MockCalled -CommandName Get-JiraIssue -ModuleName JiraPS -Exactly -Times 1 -Scope It

            # Normally, this would be called once in Get-JiraIssue and a second time in Get-JiraIssueWatcher, but
            # since we've mocked Get-JiraIssue out, it will only be called once.
            Assert-MockCalled -CommandName Invoke-JiraMethod -ModuleName JiraPS -Exactly -Times 1 -Scope It
        }

        It "Obtains all Jira watchers from a Jira issue if the Jira object is provided" {
            $issue = Get-JiraIssue -Issue $issueKey
            $watchers = Get-JiraIssueWatcher -Issue $issue
            $watchers | Should -Not -BeNullOrEmpty
            $watchers.name | Should -Be "fred"
            Assert-MockCalled -CommandName Invoke-JiraMethod -ModuleName JiraPS -Exactly -Times 1 -Scope It
        }

        It "Handles pipeline input from Get-JiraIssue" {
            $watchers = Get-JiraIssue -Issue $issueKey | Get-JiraIssueWatcher
            $watchers | Should -Not -BeNullOrEmpty
            $watchers.name | Should -Be "fred"
            Assert-MockCalled -CommandName Invoke-JiraMethod -ModuleName JiraPS -Exactly -Times 1 -Scope It
        }
    }
}
