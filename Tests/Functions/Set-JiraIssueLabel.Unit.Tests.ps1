#requires -modules @{ ModuleName = "Pester"; ModuleVersion = "5.0" }

Describe "Set-JiraIssueLabel" -Tag 'Unit' {

    BeforeAll {
        Import-Module "$PSScriptRoot/../../Tools/TestTools.psm1" -Force
        Invoke-InitTest $PSScriptRoot

        Import-Module "$PSScriptRoot/../../JiraPS" -Force

        #region Mocking
        Invoke-CommonMocking

        Mock Get-JiraIssue {
            [AtlassianPS.JiraPS.Issue]@{
                'Id'      = 123
                'Labels'  = @('existingLabel1', 'existingLabel2')
                'RestURL' = "http://jiraserver.example.com/rest/api/2/issue/12345"
            }
        }

        Mock Invoke-JiraMethod -ParameterFilter {
            $Method -eq "Put" -and
            $Uri -like "*/issue/12345"
        } {
            Write-MockInfo 'Invoke-JiraMethod' @{ Method = $Method; Uri = $Uri; Body = $Body }
        }
        #endregion Mocking
    }
    AfterAll {
        Invoke-TestCleanup
    }

    Describe "Behavior testing" {
        BeforeEach {
            $assertMockCalledSplat = @{
                CommandName = 'Invoke-JiraMethod'
                ModuleName  = JiraPS
                Times       = 1
                Scope       = 'It'
            }

            $issue = Get-JiraIssue "TEST-001"
        }

        It "Replaces Labels of an Issue" {
            Set-JiraIssueLabel $issue -Set 'testLabel1', 'testLabel2' -ErrorAction Stop

            $assertMockCalledSplat['ParameterFilter'] = {
                $Method -eq 'Put' -and
                $URI -like '*/rest/api/2/issue/12345' -and
                $Body -like '*update*labels*set*testLabel1*testLabel2*'
            }
            Assert-MockCalled @assertMockCalledSplat
        }
        It "Adds Labels to an Issue" {
            Set-JiraIssueLabel $issue -Add 'testLabel3' -ErrorAction Stop

            $assertMockCalledSplat['ParameterFilter'] = {
                $Method -eq 'Put' -and
                $URI -like '*/rest/api/2/issue/12345' -and
                $Body -like '*update*labels*set*testLabel3*'
            }
            Assert-MockCalled @assertMockCalledSplat
        }

        It "Removes Labels from an Issue" {
            Set-JiraIssueLabel $issue -Remove 'existingLabel1' -ErrorAction Stop

            $assertMockCalledSplat['ParameterFilter'] = {
                $Method -eq 'Put' -and
                $URI -like '*/rest/api/2/issue/12345' -and
                $Body -like '*update*labels*set*existingLabel2*'
            }
            Assert-MockCalled @assertMockCalledSplat
        }

        It "Clears all Labels of an Issue" {
            Set-JiraIssueLabel -Issue "TEST-001" -Clear -ErrorAction Stop

            $assertMockCalledSplat['ParameterFilter'] = {
                $Method -eq 'Put' -and
                $URI -like '*/rest/api/2/issue/12345' -and
                $Body -like '*update*labels*set*'
            }
            Assert-MockCalled @assertMockCalledSplat
        }

        It "Adds and removes Labels of an Issue at the same time" {
            Set-JiraIssueLabel -Issue "TEST-001" -Add 'testLabel1' -Remove 'testLabel2' -ErrorAction Stop
        }

        It "Changes Labels of an Issue using the pipeline" {
            "TEST-001" | Set-JiraIssueLabel -Set 'testLabel1', 'testLabel2' -ErrorAction Stop
        }

        It "fetches the Issue if an incomplete object was provided" {
            Set-JiraIssueLabel -Issue "TEST-001" -Set 'testLabel1', 'testLabel2' -ErrorAction Stop

            Assert-MockCalled -CommandName Get-JiraIssue -Exactly -Times 1 -Scope It
        }

        It "uses the provided Issue when a complete object was provided" {
            $issue | Set-JiraIssueLabel -Set 'testLabel1', 'testLabel2' -ErrorAction Stop

            Assert-MockCalled -CommandName Get-JiraIssue -Exactly -Times 1 -Scope It
        }

        It "returns an Issue when using PassThru" {
            Set-JiraIssueLabel $issue -Set 'testLabel1', 'testLabel2' -PassThru -ErrorAction Stop

            Assert-MockCalled -CommandName Get-JiraIssue -Exactly -Times 1 -Scope It
        }
    }

    Describe "Input testing" {
        BeforeAll {
            $issue = Get-JiraIssue -Issue "TEST-001"
        }

        It "Accepts an issue key for the -Issue parameter" {
            Set-JiraIssueLabel -Issue "TEST-001" -Set 'testLabel1' -ErrorAction Stop
        }

        It "Accepts an issue object for the -Issue parameter" {
            Set-JiraIssueLabel -Issue $issue -Set 'testLabel1' -ErrorAction Stop
        }

        It "Accepts the output of Get-JiraIssue by pipeline for the -Issue parameter" {
            $issue | Set-JiraIssueLabel -Set 'testLabel1' -ErrorAction Stop
        }
    }
}
