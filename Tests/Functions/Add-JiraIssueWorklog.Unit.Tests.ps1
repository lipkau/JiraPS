#requires -modules @{ ModuleName = "Pester"; ModuleVersion = "5.0" }

Import-Module "$PSScriptRoot/../../JiraPS" -Force
Import-Module "$PSScriptRoot/../../Tools/TestTools.psm1" -Force

Describe "Add-JiraIssueWorklog" -Tag 'Unit' {
    BeforeAll {
        #region Mock
        Add-CommonMocks

        Add-MockGetJiraConfigServer

        Add-MockGetJiraIssue

        Mock Invoke-JiraMethod -ParameterFilter {
            $Method -eq 'Post' -and
            $Uri -like "*/issue/*/worklog"
        } {
            Write-MockInfo 'Invoke-JiraMethod' @{ Method = $Method; Uri = $Uri; Body = $Body }
        }
        #endregion Mock
    }

    Describe 'Behavior checking' {
        BeforeAll {
            $issue = $mockedJiraIssue
        }

        It "Adds a worklog item to an Issue" {
            Add-JiraIssueWorklog -Issue $issue -TimeSpent 3600 -DateStarted "2018-01-01" -Comment 'This is a test worklog entry from Pester.' -ErrorAction Stop

            $assertMockCalledSplat = @{
                CommandName     = 'Invoke-JiraMethod'
                Exactly         = $true
                Times           = 1
                Scope           = 'It'
                ParameterFilter = {
                    $Method -eq 'Post' -and
                    $Uri -eq 'http://jiraserver.example.com/rest/api/latest/issue/41701/worklog'
                }
            }
            Assert-MockCalled @assertMockCalledSplat
        }
    }

    Describe 'Input testing' {
        BeforeAll {
            $issue = $mockedJiraIssue
        }

        It 'fetches the Issue if an incomplete object was provided' {
            Add-JiraIssueWorklog -Issue 'TEST-001' -TimeSpent 3600 -DateStarted "2018-01-01" -Comment 'This is a test worklog entry from Pester.' -ErrorAction Stop

            Assert-MockCalled -CommandName Get-JiraIssue -ModuleName JiraPS -Exactly -Times 1 -Scope It
        }

        It 'uses the provided Issue when a complete object was provided' {
            Add-JiraIssueWorklog -Issue $issue -TimeSpent 3600 -DateStarted "2018-01-01" -Comment 'This is a test worklog entry from Pester.' -ErrorAction Stop

            Assert-MockCalled -CommandName Get-JiraIssue -ModuleName JiraPS -Exactly -Times 0 -Scope It
        }

        It 'accepts files over the pipeline' {
            $issue | Add-JiraIssueWorklog -TimeSpent 3600 -DateStarted "2018-01-01" -Comment 'This is a test worklog entry from Pester.' -ErrorAction Stop
        }
    }
    Describe 'Forming of the request' {
        BeforeEach {
            $issue = $mockedJiraIssue

            $assertMockCalledSplat = @{
                CommandName = 'Invoke-JiraMethod'
                Exactly     = $true
                Times       = 1
                Scope       = 'It'
            }
        }

        It "formats DateStarted independetly of the input" {
            Add-JiraIssueWorklog -Comment 'This is a test worklog entry from Pester.' -Issue $issue -TimeSpent "00:10:00" -DateStarted "2018-01-01" -ErrorAction Stop
            Add-JiraIssueWorklog -Comment 'This is a test worklog entry from Pester.' -Issue $issue -TimeSpent "00:10:00" -DateStarted (Get-Date) -ErrorAction Stop
            Add-JiraIssueWorklog -Comment 'This is a test worklog entry from Pester.' -Issue $issue -TimeSpent "00:10:00" -DateStarted (Get-Date -Date "01.01.2000") -ErrorAction Stop

            $assertMockCalledSplat['times'] = 3
            Assert-MockCalled @assertMockCalledSplat -ParameterFilter {
                $Body -match '\"started\":\s*"\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}.\d{3}[\+\-]\d{4}"'
            }
        }

        It 'constructs a valid request for adding a comment' {
            Add-JiraIssueWorklog -Comment 'This is a test worklog entry from Pester.' -Issue $issue -TimeSpent "00:10:00" -DateStarted "2018-01-01" -ErrorAction Stop

            Assert-MockCalled @assertMockCalledSplat -ParameterFilter {
                (ConvertFrom-Json $Body).comment -eq 'This is a test worklog entry from Pester.'
            }
        }

        It 'constructs a valid request for adding a comment with role restrictions' {
            Add-JiraIssueWorklog -Comment 'This is a test worklog entry from Pester.' -Issue $issue -TimeSpent "00:10:00" -DateStarted "2018-01-01" -VisibleRole "Developers" -ErrorAction Stop

            Assert-MockCalled @assertMockCalledSplat -ParameterFilter {
                (ConvertFrom-Json $Body).visibility.type -eq "role" -and
                (ConvertFrom-Json $Body).visibility.value -eq "Developers"
            }
        }
    }
}
