#requires -modules BuildHelpers
#requires -modules @{ ModuleName = "Pester"; ModuleVersion = "4.10.1" }

Describe "Add-JiraIssueComment" -Tag 'Unit' {

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

        $restResponse = @"
{
    "self": "$jiraServer/rest/api/2/issue/$issueID/comment/90730",
    "id": "90730",
    "body": "Test comment",
    "created": "2015-05-01T16:24:38.000-0500",
    "updated": "2015-05-01T16:24:38.000-0500"
}
"@

        Mock Get-JiraConfigServer {
            Write-Output $jiraServer
        }

        Mock Get-JiraIssue {
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

        Mock Invoke-JiraMethod -ParameterFilter { $Method -eq 'POST' -and $URI -eq "$jiraServer/rest/api/latest/issue/$issueID/comment" } {
            ShowMockInfo 'Invoke-JiraMethod' 'Method', 'Uri'
            ConvertFrom-Json $restResponse
        }

        # Generic catch-all. This will throw an exception if we forgot to mock something.
        Mock Invoke-JiraMethod {
            ShowMockInfo 'Invoke-JiraMethod' 'Method', 'Uri'
            throw "Unidentified call to Invoke-JiraMethod"
        }

        #############
        # Tests
        #############

        It "Adds a comment to an issue in JIRA" {
            $commentResult = Add-JiraIssueComment -Comment 'This is a test comment from Pester.' -Issue $issueKey
            $commentResult | Should Not BeNullOrEmpty

            Assert-MockCalled 'Get-JiraIssue' -ModuleName JiraPS -Exactly -Times 1 -Scope It
            Assert-MockCalled 'Resolve-JiraIssueObject' -ModuleName JiraPS -Exactly -Times 1 -Scope It
            Assert-MockCalled 'Invoke-JiraMethod' -ModuleName JiraPS -Exactly -Times 1 -Scope It
        }

        It "Accepts pipeline input from Get-JiraIssue" {
            $commentResult = Get-JiraIssue -Key $IssueKey | Add-JiraIssueComment -Comment 'This is a test comment from Pester, using the pipeline!'
            $commentResult | Should Not BeNullOrEmpty

            Assert-MockCalled 'Get-JiraIssue' -ModuleName JiraPS -Exactly -Times 2 -Scope It
            Assert-MockCalled 'Resolve-JiraIssueObject' -ModuleName JiraPS -Exactly -Times 1 -Scope It
            Assert-MockCalled 'Invoke-JiraMethod' -ModuleName JiraPS -Exactly -Times 1 -Scope It
        }

        Describe "Output checking" {
            Mock ConvertTo-JiraComment { }
            Add-JiraIssueComment -Comment 'This is a test comment from Pester.' -Issue $issueKey | Out-Null


            It "Uses ConvertTo-JiraComment to beautify output" {
                Assert-MockCalled 'ConvertTo-JiraComment'
            }
        }
    }
}
