#requires -modules @{ ModuleName = "Pester"; ModuleVersion = "5.0" }

Describe "Remove-JiraIssueLink" -Tag 'Unit' {

    BeforeAll {
        Import-Module "$PSScriptRoot/../../Tools/TestTools.psm1" -Force
        Invoke-InitTest $PSScriptRoot

        Import-Module "$PSScriptRoot/../../JiraPS" -Force
    }
    AfterAll {
        Invoke-TestCleanup
    }

    $jiraServer = 'http://jiraserver.example.com'

    $issueLinkId = 1234

    # We don't care about anything except for the id
    $resultsJson = @"
{
    "id": "$issueLinkId",
    "self": "",
    "type": {},
    "inwardIssue": {},
    "outwardIssue": {}
}
"@

    Mock Get-JiraConfigServer -ModuleName JiraPS {
        Write-Output $jiraServer
    }

    Mock Get-JiraIssueLink -ModuleName JiraPS {
        $obj = [PSCustomObject]@{
            "id"          = $issueLinkId
            "type"        = "foo"
            "inwardIssue" = "bar"
        }
        $obj.PSObject.TypeNames.Insert(0, 'JiraPS.IssueLink')
        return $obj
    }

    Mock Get-JiraIssue -ModuleName JiraPS -ParameterFilter { $Key -eq "TEST-01" } {
        # We don't care about the content of any field except for the id of the issuelinks
        $issue = [PSCustomObject]@{
            issueLinks = @( (Get-JiraIssueLink -Id 1234) )
        }
        $issue.PSObject.TypeNames.Insert(0, 'JiraPS.Issue')
        return $issue
    }

    Mock Invoke-JiraMethod -ModuleName JiraPS -ParameterFilter { $Method -eq 'Delete' -and $URI -like "$jiraServer/rest/api/*/issueLink/1234" } {
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
        $command = Get-Command -Name Remove-JiraIssueLink

        It "has a parameter 'IssueLink' of type [Object[]]" {
            $command | Should -HaveParameter "IssueLink" -Type [Object[]]
        }

        It "has a parameter 'Credential' of type [PSCredential]" {
            $command | Should -HaveParameter "Credential" -Type [PSCredential]
        }
    }

    Describe "Functionality" {

        It "Accepts generic object with the correct properties" {
            $issueLink = Get-JiraIssueLink -Id 1234
            $issue = Get-JiraIssue -Issue TEST-01
            { Remove-JiraIssueLink -IssueLink $issueLink } | Should -Not -Throw
            { Remove-JiraIssueLink -IssueLink $issue } | Should -Not -Throw
            Assert-MockCalled -CommandName Invoke-JiraMethod -Exactly -Times 2 -Scope It
        }

        It "Accepts a JiraPS.Issue object over the pipeline" {
            { Get-JiraIssue -Issue TEST-01 | Remove-JiraIssueLink } | Should -Not -Throw
            Assert-MockCalled -CommandName Invoke-JiraMethod -Exactly -Times 1 -Scope It
        }

        It "Accepts a JiraPS.IssueType over the pipeline" {
            { Get-JiraIssueLink -Id 1234 | Remove-JiraIssueLink } | Should -Not -Throw
            Assert-MockCalled -CommandName Invoke-JiraMethod -Exactly -Times 1 -Scope It
        }

        It "Validates pipeline input" {
            { @{id = 1 } | Remove-JiraIssueLink -ErrorAction SilentlyContinue } | Should -Throw
        }
    }
}
