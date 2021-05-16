#requires -modules @{ ModuleName = "Pester"; ModuleVersion = "5.0" }

Describe "Set-JiraIssue" -Tag 'Unit' {

    BeforeAll {
        Import-Module "$PSScriptRoot/../../Tools/TestTools.psm1" -Force
        Invoke-InitTest $PSScriptRoot

        Import-Module "$PSScriptRoot/../../JiraPS" -Force

        #region Mocking
        Mock Get-JiraUser { [AtlassianPS.JiraPS.User]@{ 'Name' = 'username' } }

        Mock Set-JiraIssueLabel { }

        Mock Get-JiraField {
            [AtlassianPS.JiraPS.Field]@{ 'Name' = $Field; 'ID' = $Field }
        }

        Mock Get-JiraIssue {
            [AtlassianPS.JiraPS.Issue]@{ 'RestURL' = "https://jira.example.com/rest/api/2/issue/12345" }
        }

        Mock Invoke-JiraMethod -ParameterFilter {
            $Method -eq "Put" -and
            $Uri -like "*/rest/api/*/issue/12345"
        } {
            Write-MockInfo 'Invoke-JiraMethod' @{ Method = $Method; Uri = $Uri }
        }

        Mock Invoke-JiraMethod -ParameterFilter {
            $Method -eq "Put" -and
            $Uri -like "*/rest/api/*/issue/12345/assignee"
        } {
            Write-MockInfo 'Invoke-JiraMethod' @{ Method = $Method; Uri = $Uri }
        }
        #endregion Mocking
    }
    AfterAll {
        Invoke-TestCleanup
    }

    Describe "Behavior testing" {
        BeforeAll {
            $assertMockCalledSplat = @{
                CommandName = 'Invoke-JiraMethod'
                ModuleName  = JiraPS
                Times       = 1
                Scope       = 'It'
            }

            $issue = Get-JiraIssue "TEST-001"
        }

        It "Modifies the summary of an issue if the -Summary parameter is passed" {
            Set-JiraIssue -Issue $issue -Summary 'New summary' -ErrorAction Stop

            $assertMockCalledSplat['ParameterFilter'] = {
                $Method -eq 'Put' -and
                $URI -like "*/rest/api/2/issue/12345" -and
                $Body -like '*summary*set*New summary*'
            }
            Assert-MockCalled @assertMockCalledSplat
        }

        It "Modifies the description of an issue if the -Description parameter is passed" {
            Set-JiraIssue -Issue $issue -Description 'New description' -ErrorAction Stop

            $assertMockCalledSpla['ParameterFilter'] = {
                $Method -eq 'Put' -and
                $URI -like "*/rest/api/2/issue/12345" -and
                $Body -like '*description*set*New description*'
            }
            Assert-MockCalled @assertMockCalledSplat
        }

        It "Modifies the description of an issue without sending notifications if the -Description parameter is passed" {
            Set-JiraIssue -Issue $issue -Description 'New description' -SkipNotification -ErrorAction Stop

            $assertMockCalledSplat['ParameterFilter'] = {
                $Method -eq 'Put' -and
                $URI -like "*/rest/api/2/issue/12345" -and
                $Body -like '*description*set*New description*'
            }
            Assert-MockCalled @assertMockCalledSplat
        }

        It "Modifies the assignee of an issue if -Assignee is passed" {
            Set-JiraIssue -Issue $issue -Assignee username -ErrorAction Stop

            $assertMockCalledSplat['ParameterFilter'] = {
                $Method -eq 'Put' -and
                $URI -like "*/rest/api/2/issue/12345/assignee" -and
                $Body -like '*name*username*'
            }
            Assert-MockCalled @assertMockCalledSplat
        }

        It "Unassigns an issue if 'Unassigned' is passed to the -Assignee parameter" {
            Set-JiraIssue -Issue $issue -Assignee unassigned -ErrorAction Stop

            $assertMockCalledSplat['ParameterFilter'] = {
                $Method -eq 'Put' -and
                $URI -like "*/rest/api/2/issue/12345/assignee" -and
                $Body -like '*"name":*null*'
            }
            Assert-MockCalled @assertMockCalledSplat
        }

        It "Sets the default assignee to an issue if 'Default' is passed to the -Assignee parameter" {
            Set-JiraIssue -Issue $issue -Assignee default -ErrorAction Stop

            $assertMockCalledSplat['ParameterFilter'] = {
                $Method -eq 'Put' -and
                $URI -like "*/rest/api/2/issue/12345/assignee" -and
                $Body -like '*"name":*"-1"*'
            }
            Assert-MockCalled @assertMockCalledSplat
        }

        It "Calls Invoke-JiraMethod twice if using Assignee and another field" {
            Set-JiraIssue -Issue $issue -Summary 'New summary' -Assignee username -ErrorAction Stop

            $assertMockCalledSplat['ParameterFilter'] = {
                $Method -eq 'Put' -and
                $URI -like "*/rest/api/2/issue/12345" -and
                $Body -like '*summary*set*New summary*'
            }
            Assert-MockCalled @assertMockCalledSplat

            $assertMockCalledSplat['ParameterFilter'] = {
                $Method -eq 'Put' -and
                $URI -like "*/rest/api/2/issue/12345/assignee" -and
                $Body -like '*name*username*'
            }
            Assert-MockCalled @assertMockCalledSplat
        }

        It "Uses Set-JiraIssueLabel with the -Set parameter when the -Label parameter is used" {
            Set-JiraIssue -Issue $issue -Label 'test' -ErrorAction Stop

            $assertMockCalledSplat['ParameterFilter'] = { $Set -ne $null }
            Assert-MockCalled @assertMockCalledSplat
        }

        It "Adds a comment if the -AddComemnt parameter is passed" {
            Set-JiraIssue -Issue $issue -AddComment 'New Comment' -ErrorAction Stop

            $assertMockCalledSplat['ParameterFilter'] = {
                $Method -eq 'Put' -and
                $Uri -like "*/rest/api/2/issue/12345" -and
                $Body -like '*comment*add*body*New Comment*'
            }
            Assert-MockCalled @assertMockCalledSplat
        }

        It "Updates custom fields if provided to the -Fields parameter" {
            Set-JiraIssue -Issue $issue -Fields @{
                'customfield_12345'  = 'foo'
                'customfield_67890'  = 'bar'
                'customfield_111222' = @( @{ 'value' = 'foobar' } )
            } -ErrorAction Stop

            $assertMockCalledSplat['ParameterFilter'] = {
                $Method -eq 'Put' -and
                $URI -like "*/rest/api/*/issue/12345" -and
                $Body -like '*customfield_12345*set*foo*' -and
                $Body -like '*customfield_67890*set*bar*' -and
                $Body -like '*customfield_111222*set*foobar*'
            }
            Assert-MockCalled @assertMockCalledSplat
        }
    }

    Describe "Input testing" {
        BeforeAll {
            $issue = Get-JiraIssue "TEST-001"
        }

        It "Accepts an issue key for the -Issue parameter" {
            Set-JiraIssue -Issue "TEST-001" -Summary 'Test summary - using issue key' -ErrorAction Stop
        }

        It "Accepts an issue object for the -Issue parameter" {
            Set-JiraIssue -Issue $issue -Summary 'Test summary - Object' -ErrorAction Stop
        }

        It "Accepts the output of Get-JiraObject by pipeline for the -Issue paramete" {
            $issue | Set-JiraIssue -Summary 'Test summary - InputObject pipeline' -ErrorAction Stop
        }
    }
}
