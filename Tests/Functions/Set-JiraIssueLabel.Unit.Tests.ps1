#requires -modules BuildHelpers
#requires -modules @{ ModuleName = "Pester"; ModuleVersion = "4.10.1" }

Describe "Set-JiraIssueLabel" -Tag 'Unit' {

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

        $jiraServer = 'https://jira.example.com'

        Mock Get-JiraConfigServer {
            $jiraServer
        }

        Mock Get-JiraIssue {
            $object = [PSCustomObject] @{
                'Id'      = 123
                'RestURL' = "$jiraServer/rest/api/2/issue/12345"
                'Labels'  = @('existingLabel1', 'existingLabel2')
            }
            $object.PSObject.TypeNames.Insert(0, 'JiraPS.Issue')
            return $object
        }

        Mock Resolve-JiraIssueObject -ModuleName JiraPS {
            Get-JiraIssue -Key $Issue
        }

        Mock Invoke-JiraMethod -ModuleName JiraPS -ParameterFilter {$Method -eq "Put" -and $Uri -like "$jiraServer/rest/api/*/issue/12345"} {
        }

        Mock Invoke-JiraMethod {
            ShowMockInfo 'Invoke-JiraMethod' 'Method', 'Uri'
            throw "Unidentified call to Invoke-JiraMethod"
        }

        Context "Sanity checking" {
            $command = Get-Command -Name Set-JiraIssueLabel

            It "has a parameter 'Issue' of type [Object[]]" {
                $command | Should -HaveParameter "Issue" -Type [Object[]]
            }

            It "has an alias 'Key' for parameter 'Issue" {
                $command | Should -HaveParameter "Issue" -Alias "Key"
            }

            It "has a parameter 'Set' of type [String[]]" {
                $command | Should -HaveParameter "Set" -Type [String[]]
            }

            It "has an alias 'Replace' for parameter 'Set" {
                $command | Should -HaveParameter "Set" -Alias "Replace"
            }

            It "has an alias 'Label' for parameter 'Set" {
                $command | Should -HaveParameter "Set" -Alias "Label"
            }

            It "has a parameter 'Add' of type [String[]]" {
                $command | Should -HaveParameter "Add" -Type [String[]]
            }

            It "has a parameter 'Remove' of type [String[]]" {
                $command | Should -HaveParameter "Remove" -Type [String[]]
            }

            It "has a parameter 'Clear' of type [Switch]" {
                $command | Should -HaveParameter "Clear" -Type [Switch]
            }

            It "has a parameter 'Credential' of type [PSCredential]" {
                $command | Should -HaveParameter "Credential" -Type [PSCredential]
            }

            It "has a parameter 'PassThru' of type [Switch]" {
                $command | Should -HaveParameter "PassThru" -Type [Switch]
            }
        }

        Context "Behavior testing" {
            It "Replaces all issue labels if the Set parameter is supplied" {
                { Set-JiraIssueLabel -Issue TEST-001 -Set 'testLabel1', 'testLabel2' } | Should Not Throw
                # The String in the ParameterFilter is made from the keywords
                # we should expect to see in the JSON that should be sent,
                # including the summary provided in the test call above.
                Assert-MockCalled -CommandName Invoke-JiraMethod -ModuleName JiraPS -Times 1 -Scope It -ParameterFilter { $Method -eq 'Put' -and $URI -like '*/rest/api/2/issue/12345' -and $Body -like '*update*labels*set*testLabel1*testLabel2*' }
            }

            It "Adds new labels if the Add parameter is supplied" {
                { Set-JiraIssueLabel -Issue TEST-001 -Add 'testLabel3' } | Should Not Throw
                Assert-MockCalled -CommandName Invoke-JiraMethod -ModuleName JiraPS -Times 1 -Scope It -ParameterFilter { $Method -eq 'Put' -and $URI -like '*/rest/api/2/issue/12345' -and $Body -like '*update*labels*set*testLabel3*' }
            }

            It "Removes labels if the Remove parameter is supplied" {
                # The issue already has labels existingLabel1 and
                # existingLabel2. It should be set to just existingLabel2.
                { Set-JiraIssueLabel -Issue TEST-001 -Remove 'existingLabel1' } | Should Not Throw
                Assert-MockCalled -CommandName Invoke-JiraMethod -ModuleName JiraPS -Times 1 -Scope It -ParameterFilter { $Method -eq 'Put' -and $URI -like '*/rest/api/2/issue/12345' -and $Body -like '*update*labels*set*existingLabel2*' }
            }

            It "Clears all labels if the Clear parameter is supplied" {
                { Set-JiraIssueLabel -Issue TEST-001 -Clear } | Should Not Throw
                Assert-MockCalled -CommandName Invoke-JiraMethod -ModuleName JiraPS -Times 1 -Scope It -ParameterFilter { $Method -eq 'Put' -and $URI -like '*/rest/api/2/issue/12345' -and $Body -like '*update*labels*set*' }
            }

            It "Allows use of both Add and Remove parameters at the same time" {
                { Set-JiraIssueLabel -Issue TEST-001 -Add 'testLabel1' -Remove 'testLabel2' } | Should Not Throw
            }
        }

        Context "Input testing" {
            It "Accepts an issue key for the -Issue parameter" {
                { Set-JiraIssueLabel -Issue TEST-001 -Set 'testLabel1' } | Should Not Throw
                Assert-MockCalled -CommandName Get-JiraIssue -ModuleName JiraPS -Exactly -Times 1 -Scope It
                Assert-MockCalled -CommandName Invoke-JiraMethod -ModuleName JiraPS -Exactly -Times 1 -Scope It
            }

            It "Accepts an issue object for the -Issue parameter" {
                $issue = Get-JiraIssue -Key TEST-001
                { Set-JiraIssueLabel -Issue $issue -Set 'testLabel1' } | Should Not Throw
                # Get-JiraIssue is called once explicitly in this test, and a
                # second time by Set-JiraIssue
                Assert-MockCalled -CommandName Get-JiraIssue -ModuleName JiraPS -Exactly -Times 2 -Scope It
                Assert-MockCalled -CommandName Invoke-JiraMethod -ModuleName JiraPS -Exactly -Times 1 -Scope It
            }

            It "Accepts the output of Get-JiraIssue by pipeline for the -Issue parameter" {
                { Get-JiraIssue -Key TEST-001 | Set-JiraIssueLabel -Set 'testLabel1' } | Should Not Throw
                Assert-MockCalled -CommandName Get-JiraIssue -ModuleName JiraPS -Exactly -Times 2 -Scope It
                Assert-MockCalled -CommandName Invoke-JiraMethod -ModuleName JiraPS -Exactly -Times 1 -Scope It
            }
        }
    }
}
