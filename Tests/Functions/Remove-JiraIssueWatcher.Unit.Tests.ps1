#requires -modules @{ ModuleName = "Pester"; ModuleVersion = "5.0" }

Describe "Remove-JiraIssueWatcher" -Tag 'Unit' {

    BeforeAll {
        Import-Module "$PSScriptRoot/../../Tools/TestTools.psm1" -Force
        Invoke-InitTest $PSScriptRoot

        Import-Module "$PSScriptRoot/../../JiraPS" -Force
    }
    AfterAll {
        Invoke-TestCleanup
    }

    $jiraServer = 'http://jiraserver.example.com'
    $issueID = 41701
    $issueKey = 'IT-3676'

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

    Mock Invoke-JiraMethod -ModuleName JiraPS -ParameterFilter { $Method -eq 'DELETE' -and $URI -eq "$jiraServer/rest/api/latest/issue/$issueID/watchers?username=fred" } {
        Write-MockInfo 'Invoke-JiraMethod' @{ Method = $Method; Uri = $Uri }
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
        $command = Get-Command -Name Remove-JiraIssueWatcher

        It "has a parameter 'Watcher' of type [AtlassianPS.JiraPS.User[]]" {
            $command | Should -HaveParameter "Watcher" -Type [AtlassianPS.JiraPS.User[]]
        }

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

        It "Removes a Watcher from an issue in JIRA" {
            $WatcherResult = Remove-JiraIssueWatcher -Watcher 'fred' -Issue $issueKey
            $WatcherResult | Should -BeNullOrEmpty

            # Get-JiraIssue Should -Be used to identiyf the issue parameter
            Assert-MockCalled -CommandName Get-JiraIssue -ModuleName JiraPS -Exactly -Times 1 -Scope It

            # Invoke-JiraMethod Should -Be used to add the Watcher
            Assert-MockCalled -CommandName Invoke-JiraMethod -ModuleName JiraPS -Exactly -Times 1 -Scope It
        }

        It "Accepts pipeline input from Get-JiraIssue" {
            $WatcherResult = Get-JiraIssue -Issue $IssueKey | Remove-JiraIssueWatcher -Watcher 'fred'
            $WatcherResult | Should -BeNullOrEmpty

            # Get-JiraIssue Should -Be called once here, and once inside Add-JiraIssueWatcher (to identify the InputObject parameter)
            Assert-MockCalled -CommandName Get-JiraIssue -ModuleName JiraPS -Exactly -Times 2 -Scope It
            Assert-MockCalled -CommandName Invoke-JiraMethod -ModuleName JiraPS -Exactly -Times 1 -Scope It
        }
    }
}
