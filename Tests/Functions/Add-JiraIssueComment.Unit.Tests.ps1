#requires -modules @{ ModuleName = "Pester"; ModuleVersion = "5.0" }

Import-Module "$PSScriptRoot/../../JiraPS" -Force
Import-Module "$PSScriptRoot/../../Tools/TestTools.psm1" -Force

Describe 'Add-JiraIssueComment' -Tag 'Unit' {
    BeforeAll {
        $commentResponse = @{
            restUrl = 'http://jiraserver.example.com/rest/api/2/issue/41701/comment/90730'
            id      = '90730'
            body    = 'Test comment'
            created = '2015-05-01T16:24:38.000-0500'
            updated = '2015-05-01T16:24:38.000-0500'
        }

        #region Mock
        Add-CommonMocks

        Add-MockGetJiraIssue

        Add-MockResolveJiraIssueUrl

        Mock Invoke-JiraMethod -ParameterFilter {
            $Method -eq 'POST' -and
            $URI -like '*/issue/*/comment'
        } {
            Write-MockInfo 'Invoke-JiraMethod' @{ Method = $Method; Uri = $Uri; Body = $Body }
        }
        #endregion Mock
    }

    Describe 'Behavior checking' {
        BeforeAll {
            $assertMockCalledSplat = @{
                CommandName = 'Invoke-JiraMethod'
                Exactly     = $true
                Times       = 1
                Scope       = 'It'
            }
        }

        It 'Adds a comment to an issue in JIRA' {
            Add-JiraIssueComment -Comment 'This is a test comment from Pester.' -Issue 'TEST-001' -ErrorAction Stop

            Assert-MockCalled @assertMockCalledSplat
        }

        It 'Adds a comment with restrictions to a Group' {
            Add-JiraIssueComment -Comment 'This is a test comment from Pester.' -Issue 'TEST-001' -RestrictToGroup 'Administrators' -ErrorAction Stop
        }

        It 'Adds a comment with restrictions to a Role' {
            Add-JiraIssueComment -Comment 'This is a test comment from Pester.' -Issue 'TEST-001' -RestrictToRole 'Responsibles' -ErrorAction Stop
        }

        It "handles the restriction to 'All Users' gracefully" {
            Add-JiraIssueComment -Comment 'This is a test comment from Pester.' -Issue 'TEST-001' -RestrictToRole 'All Users' -ErrorAction Stop

            Assert-MockCalled @assertMockCalledSplat -ParameterFilter {
                $Body -notlike "*`"visibility`":*"
            }
        }
    }

    Describe 'Input testing' {
        It 'resolves the url of the issue' {
            Add-JiraIssueComment -Comment 'This is a test comment from Pester.' -Issue 'TEST-001' -ErrorAction Stop

            Assert-MockCalled -CommandName Resolve-JiraIssueUrl -ModuleName 'JiraPS' -Exactly -Times 1 -Scope It
        }

        It 'accepts Issues over the pipeline' {
            $mockedJiraIssue | Add-JiraIssueComment -Comment 'This is a test comment from Pester.' -ErrorAction Stop
        }

        It "can't set restrictions for a Role and a Group simulaniouly" {
            {
                Add-JiraIssueComment -Comment 'This is a test comment from Pester.' `
                    -Issue 'TEST-001' `
                    -RestrictToGroup 'Administrators' `
                    -RestrictToRole 'Responsibles' `
                    -ErrorAction Stop
            } | Should -Throw
        }
    }

    Describe 'Forming of the request' {
        BeforeAll {
            $assertMockCalledSplat = @{
                CommandName = 'Invoke-JiraMethod'
                Exactly     = $true
                Times       = 1
                Scope       = 'It'
            }
        }

        It 'constructs a valid request for adding a comment' {
            Add-JiraIssueComment -Comment 'This is a test comment from Pester.' -Issue $mockedJiraIssue -ErrorAction Stop

            Assert-MockCalled @assertMockCalledSplat -ParameterFilter {
                $Body -eq '{"body":"This is a test comment from Pester."}'
            }
        }

        It 'constructs a valid request for adding a comment with role restrictions' {
            Add-JiraIssueComment -Comment 'This is a test comment from Pester.' -Issue $mockedJiraIssue -RestrictToRole 'Developers'

            Assert-MockCalled @assertMockCalledSplat -ParameterFilter {
                (ConvertFrom-Json $Body).body -eq "This is a test comment from Pester." -and
                (ConvertFrom-Json $Body).visibility.type -eq "role" -and
                (ConvertFrom-Json $Body).visibility.value -eq "Developers"
            }
        }

        It 'constructs a valid request for adding a comment with group restrictions' {
            Add-JiraIssueComment -Comment 'This is a test comment from Pester.' -Issue $mockedJiraIssue -RestrictToGroup 'Administrators'

            Assert-MockCalled @assertMockCalledSplat -ParameterFilter {
                (ConvertFrom-Json $Body).body -eq "This is a test comment from Pester." -and
                (ConvertFrom-Json $Body).visibility.type -eq "group" -and
                (ConvertFrom-Json $Body).visibility.value -eq "Administrators"
            }
        }
    }
}
