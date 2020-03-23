#requires -modules BuildHelpers
#requires -modules @{ ModuleName = "Pester"; ModuleVersion = "4.10.1" }

Describe "Remove-JiraRemoteLink" -Tag 'Unit' {

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

        $testIssueKey = 'EX-1'

        $testLink = @"
{
    "id": 10000,
    "self": "http://www.example.com/jira/rest/api/issue/MKY-1/remotelink/10000",
    "globalId": "system=http://www.mycompany.com/support&id=1",
    "application": {
        "type": "com.acme.tracker",
        "name": "My Acme Tracker"
    },
    "relationship": "causes",
    "object": {
        "url": "http://www.mycompany.com/support?id=1",
        "title": "TSTSUP-111",
        "summary": "Crazy customer support issue",
        "icon": {
            "url16x16": "http://www.mycompany.com/support/ticket.png",
            "title": "Support Ticket"
        }
    }
}
"@

        Mock Get-JiraConfigServer -ModuleName JiraPS {
            Write-Output $jiraServer
        }

        Mock Get-JiraIssue {
            $object = [PSCustomObject] @{
                'RestURL' = 'https://jira.example.com/rest/api/2/issue/12345'
                'Key'     = $testIssueKey
            }
            $object.PSObject.TypeNames.Insert(0, 'JiraPS.Issue')
            return $object
        }

        Mock Resolve-JiraIssueObject -ModuleName JiraPS {
            Get-JiraIssue -Key $Issue
        }

        Mock Get-JiraRemoteLink {
            $object = ConvertFrom-Json $testLink
            $object.PSObject.TypeNames.Insert(0, 'JiraPS.IssueLinkType')
            return $object
        }

        Mock Invoke-JiraMethod -ModuleName JiraPS -ParameterFilter { $Method -eq 'DELETE' } {
            ShowMockInfo 'Invoke-JiraMethod' @{ Method = $Method; Uri = $Uri }
            # This REST method should produce no output
        }

        # Generic catch-all. This will throw an exception if we forgot to mock something.
        Mock Invoke-JiraMethod -ModuleName JiraPS {
            ShowMockInfo 'Invoke-JiraMethod' @{ Method = $Method; Uri = $Uri }
            throw "Unidentified call to Invoke-JiraMethod"
        }

        #############
        # Tests
        #############

        It "Accepts a issue key to the -Issue parameter" {
            { Remove-JiraRemoteLink -Issue $testIssueKey -LinkId 10000 -Force } | Should Not Throw
            Assert-MockCalled -CommandName Invoke-JiraMethod -Exactly -Times 1 -Scope It
        }

        It "Accepts a JiraPS.Issue object to the -Issue parameter" {
            $Issue = Get-JiraIssue $testIssueKey
            { Remove-JiraRemoteLink -Issue $Issue -LinkId 10000 -Force } | Should Not Throw
            Assert-MockCalled -CommandName Invoke-JiraMethod -Exactly -Times 1 -Scope It
        }

        It "Accepts pipeline input from Get-JiraIssue" {
            { Get-JiraIssue $testIssueKey | Remove-JiraRemoteLink -LinkId 10000 -Force } | Should Not Throw
            Assert-MockCalled -CommandName Invoke-JiraMethod -Exactly -Times 1 -Scope It
        }

        It "Accepts the output of Get-JiraRemoteLink" {
            $remoteLink = Get-JiraRemoteLink $testIssueKey
            { Remove-JiraRemoteLink -Issue $testIssueKey -LinkId $remoteLink.id -Force } | Should Not Throw
            Assert-MockCalled -CommandName Invoke-JiraMethod -Exactly -Times 1 -Scope It
        }

        It "Removes a group from JIRA" {
            { Remove-JiraRemoteLink -Issue $testIssueKey -LinkId 10000 -Force } | Should Not Throw
            Assert-MockCalled -CommandName Invoke-JiraMethod -Exactly -Times 1 -Scope It
        }

        It "Provides no output" {
            Remove-JiraRemoteLink -Issue $testIssueKey -LinkId 10000 -Force | Should BeNullOrEmpty
        }
    }
}
