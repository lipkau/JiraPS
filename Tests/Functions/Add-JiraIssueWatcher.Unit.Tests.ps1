#requires -modules BuildHelpers
#requires -modules @{ ModuleName = "Pester"; ModuleVersion = "4.10.1" }

Describe "Add-JiraIssueWatcher" -Tag 'Unit' {

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
            Get-JiraIssue -Key $Issue
        }

        Mock Invoke-JiraMethod -ModuleName JiraPS -ParameterFilter { $Method -eq 'POST' -and $URI -eq "$jiraServer/rest/api/latest/issue/$issueID/watchers" } {
            ShowMockInfo 'Invoke-JiraMethod' @{ Method = $Method; Uri = $Uri }
        }

        # Generic catch-all. This will throw an exception if we forgot to mock something.
        Mock Invoke-JiraMethod -ModuleName JiraPS {
            ShowMockInfo 'Invoke-JiraMethod' @{ Method = $Method; Uri = $Uri }
            throw "Unidentified call to Invoke-JiraMethod"
        }

        #############
        # Tests
        #############

        Describe "Sanity checking" {
            $command = Get-Command -Name Add-JiraIssueWatcher

            defParam $command 'Watcher'
            defParam $command 'Issue'
            defParam $command 'Credential'
        }

        Describe "Behavior testing" {

            It "Adds a Watcher to an issue in JIRA" {
                $WatcherResult = Add-JiraIssueWatcher -Watcher 'fred' -Issue $issueKey
                $WatcherResult | Should BeNullOrEmpty

                # Get-JiraIssue should be used to identify the issue parameter
                Assert-MockCalled -CommandName Get-JiraIssue -ModuleName JiraPS -Exactly -Times 1 -Scope It

                # Invoke-JiraMethod should be used to add the Watcher
                Assert-MockCalled -CommandName Invoke-JiraMethod -ModuleName JiraPS -Exactly -Times 1 -Scope It
            }

            It "Accepts pipeline input from Get-JiraIssue" {
                $WatcherResult = Get-JiraIssue -Key $issueKey | Add-JiraIssueWatcher -Watcher 'fred'
                $WatcherResult | Should BeNullOrEmpty

                # Get-JiraIssue should be called once here, and once inside Add-JiraIssueWatcher (to identify the InputObject parameter)
                Assert-MockCalled -CommandName Get-JiraIssue -ModuleName JiraPS -Exactly -Times 2 -Scope It
                Assert-MockCalled -CommandName Invoke-JiraMethod -ModuleName JiraPS -Exactly -Times 1 -Scope It
            }
        }
    }
}