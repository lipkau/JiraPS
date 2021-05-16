#requires -modules @{ ModuleName = "Pester"; ModuleVersion = "5.0" }

Import-Module "$PSScriptRoot/../../JiraPS" -Force
Import-Module "$PSScriptRoot/../../Tools/TestTools.psm1" -Force

Describe 'Add-JiraIssueLink' -Tag 'Unit' {
    BeforeAll {
        #region Mock
        Add-CommonMocks

        Add-MockGetJiraConfigServer

        Add-MockGetJiraIssue

        Mock Invoke-JiraMethod -ParameterFilter {
            $Method -eq 'Post' -and
            $URI -like '*/issueLink'
        } {
            Write-MockInfo 'Invoke-JiraMethod' @{ Method = $Method; Uri = $Uri; Body = $Body }
        }
        #endregion Mock
    }

    Describe 'Behavior checking' {
        BeforeAll {
            $issue = $mockedJiraIssue
            $issueLink = $mockedJiraIssueLink
        }

        It 'Adds a new IssueLink' {
            Add-JiraIssueLink -Issue $issue -IssueLink $issueLink -Comment "this must be done first." -ErrorAction Stop

            $assertMockCalledSplat = @{
                CommandName = 'Invoke-JiraMethod'
                Exactly     = $true
                Times       = 1
                Scope       = 'It'
            }
            Assert-MockCalled @assertMockCalledSplat
        }
    }

    Describe 'Input testing' {
        BeforeAll {
            $issue = $mockedJiraIssue
            $issueLink = $mockedJiraIssueLink
        }

        It 'fetches the Issue if an incomplete object was provided' {
            Add-JiraIssueLink -Issue 'TEST-001' -IssueLink $issueLink -ErrorAction Stop

            Assert-MockCalled -CommandName Get-JiraIssue -ModuleName JiraPS -Exactly -Times 1 -Scope It
        }

        It 'uses the provided Issue when a complete object was provided' {
            Add-JiraIssueLink -Issue $issue -IssueLink $issueLink -ErrorAction Stop

            Assert-MockCalled -CommandName Get-JiraIssue -ModuleName JiraPS -Exactly -Times 0 -Scope It
        }

        It 'accepts multiple IssueLinks' {
            Add-JiraIssueLink -Issue $issue -IssueLink $issueLink, $issueLink, $issueLink -ErrorAction Stop

            $assertMockCalledSplat = @{
                CommandName = 'Invoke-JiraMethod'
                Exactly     = $true
                Times       = 3
                Scope       = 'It'
            }
            Assert-MockCalled @assertMockCalledSplat
        }

        It 'accepts Issues over the pipeline' {
            $issue | Add-JiraIssueLink -IssueLink $issueLink -ErrorAction Stop
        }
    }

    Describe 'Forming of the request' {
        BeforeAll {
            $issue = $mockedJiraIssue
            $issueLink = $mockedJiraIssueLink
        }

        It 'constructs a valid request for adding an issue link' {
            Add-JiraIssueLink -Issue $issue -IssueLink $issueLink -ErrorAction Stop

            $assertMockCalledSplat = @{
                CommandName     = 'Invoke-JiraMethod'
                Exactly         = $true
                Times           = 1
                Scope           = 'It'
                ParameterFilter = {
                    $Method -eq 'Post' -and
                    $Uri -eq 'http://jiraserver.example.com/rest/api/latest/issueLink' -and
                    (ConvertFrom-Json $Body).type.name -eq 'Composition' -and
                    (ConvertFrom-Json $Body).inwardIssue.key -eq 'TEST-001' -and
                    (ConvertFrom-Json $Body).outwardIssue.key -eq 'TEST-002'
                }
            }
            Assert-MockCalled @assertMockCalledSplat
        }
        It 'constructs a valid request for adding an issue link' {
            $issueLink = [AtlassianPS.JiraPS.IssueLink]@{
                type        = [AtlassianPS.JiraPS.IssueLinkType]@{name = 'Composition' }
                inwardIssue = [AtlassianPS.JiraPS.Issue]@{key = 'TEST-003' }
            }

            Add-JiraIssueLink -Issue $issue -IssueLink $issueLink -ErrorAction Stop

            $assertMockCalledSplat = @{
                CommandName     = 'Invoke-JiraMethod'
                Exactly         = $true
                Times           = 1
                Scope           = 'It'
                ParameterFilter = {
                    $Method -eq 'Post' -and
                    $Uri -eq 'http://jiraserver.example.com/rest/api/latest/issueLink' -and
                    (ConvertFrom-Json $Body).type.name -eq 'Composition' -and
                    (ConvertFrom-Json $Body).inwardIssue.key -eq 'TEST-003' -and
                    (ConvertFrom-Json $Body).outwardIssue.key -eq 'TEST-001'
                }
            }
            Assert-MockCalled @assertMockCalledSplat
        }

        It 'constructs a valid request for adding an issue link with a comment' {
            Add-JiraIssueLink -Issue $issue -IssueLink $issueLink -Comment "this must be done first." -ErrorAction Stop

            $assertMockCalledSplat = @{
                CommandName     = 'Invoke-JiraMethod'
                Exactly         = $true
                Times           = 1
                Scope           = 'It'
                ParameterFilter = {
                    $Method -eq 'Post' -and
                    $Uri -eq 'http://jiraserver.example.com/rest/api/latest/issueLink' -and
                    (ConvertFrom-Json $Body).type.name -eq 'Composition' -and
                    (ConvertFrom-Json $Body).inwardIssue.key -eq 'TEST-001' -and
                    (ConvertFrom-Json $Body).outwardIssue.key -eq 'TEST-002' -and
                    (ConvertFrom-Json $Body).comment.body -eq 'this must be done first.'
                }
            }
            Assert-MockCalled @assertMockCalledSplat
        }
    }
}
