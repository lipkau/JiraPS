#requires -modules @{ ModuleName = "Pester"; ModuleVersion = "5.0" }

Import-Module "$PSScriptRoot/../../JiraPS" -Force
Import-Module "$PSScriptRoot/../../Tools/TestTools.psm1" -Force

Describe "Add-JiraIssueWatcher" -Tag 'Unit' {
    BeforeAll {
        #region Mock
        Add-CommonMocks

        Add-MockGetJiraConfigServer

        Add-MockGetJiraIssue

        Mock Invoke-JiraMethod -ParameterFilter {
            $Method -eq 'Post' -and
            $Uri -like "*/issue/*/watchers"
        } {
            Write-MockInfo 'Invoke-JiraMethod' @{ Method = $Method; Uri = $Uri; Body = $Body }
        }
        #endregion Mock
    }

    Describe 'Behavior checking' {
        BeforeAll {
            $issue = $mockedJiraIssue
            $user = $mockedJiraServerUser
        }

        It "Adds a Watcher to an Issue" {
            Add-JiraIssueWatcher -Watcher $user -Issue $issue -ErrorAction Stop

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
            $user = $mockedJiraServerUser
        }

        It 'fetches the Issue if an incomplete object was provided' {
            Add-JiraIssueWatcher -Issue 'TEST-001' -Watcher $user -ErrorAction Stop

            Assert-MockCalled -CommandName Get-JiraIssue -ModuleName JiraPS -Exactly -Times 1 -Scope It
        }

        It 'uses the provided Issue when a complete object was provided' {
            Add-JiraIssueWatcher -Issue $issue -Watcher $user -ErrorAction Stop

            Assert-MockCalled -CommandName Get-JiraIssue -ModuleName JiraPS -Exactly -Times 0 -Scope It
        }

        It 'accepts multiple Users' {
            Add-JiraIssueWatcher -Watcher $user, $user, $user -Issue $issue -ErrorAction Stop

            $assertMockCalledSplat = @{
                CommandName = 'Invoke-JiraMethod'
                Exactly     = $true
                Times       = 3
                Scope       = 'It'
            }
            Assert-MockCalled @assertMockCalledSplat
        }

        It 'accepts Users over the pipeline' {
            $user | Add-JiraIssueWatcher -Issue $issue -ErrorAction Stop
        }
    }

    Describe 'Forming of the request' {
        BeforeAll {
            $issue = $mockedJiraIssue
            $serverUser = $mockedJiraServerUser
            $cloudUser = $mockedJiraCloudUser
        }

        It 'constructs a valid request for adding a watcher on jira server' {
            Add-JiraIssueWatcher -Issue $issue -Watcher $serverUser -ErrorAction Stop

            $assertMockCalledSplat = @{
                CommandName     = 'Invoke-JiraMethod'
                Exactly         = $true
                Times           = 1
                Scope           = 'It'
                ParameterFilter = {
                    $Method -eq 'Post' -and
                    $Uri -eq 'http://jiraserver.example.com/rest/api/latest/issue/41701/watchers' -and
                    $Body -eq '"fred"'
                }
            }
            Assert-MockCalled @assertMockCalledSplat
        }
        It 'constructs a valid request for adding a watcher on jira cloud' {
            Add-JiraIssueWatcher -Issue $issue -Watcher $cloudUser -ErrorAction Stop

            $assertMockCalledSplat = @{
                CommandName     = 'Invoke-JiraMethod'
                Exactly         = $true
                Times           = 1
                Scope           = 'It'
                ParameterFilter = {
                    $Method -eq 'Post' -and
                    $Uri -eq 'http://jiraserver.example.com/rest/api/latest/issue/41701/watchers' -and
                    $Body -eq '"hannes"'
                }
            }
            Assert-MockCalled @assertMockCalledSplat
        }
    }
}
