#requires -modules @{ ModuleName = "Pester"; ModuleVersion = "5.0" }

Import-Module "$PSScriptRoot/../../JiraPS" -Force
Import-Module "$PSScriptRoot/../../Tools/TestTools.psm1" -Force

Describe "Get-JiraIssueType" -Tag 'Unit' {
    BeforeAll {
        #region Definitions
        $issueTypeResponse = ConvertFrom-Json -InputObject @"
[
    {
        "self": "https://powershell.atlassian.net/rest/api/2/issuetype/10207",
        "id": "10207",
        "description": "For customer support issues. Created by JIRA Service Desk.",
        "iconUrl": "https://powershell.atlassian.net/secure/viewavatar?size=medium&avatarId=10607&avatarType=issuetype",
        "name": "Support",
        "untranslatedName": "Support",
        "subtask": false,
        "avatarId": 10607
    },
    {
        "self": "https://powershell.atlassian.net/rest/api/2/issuetype/10204",
        "id": "10204",
        "description": "Created by JIRA Service Desk.",
        "iconUrl": "https://powershell.atlassian.net/secure/viewavatar?size=medium&avatarId=10604&avatarType=issuetype",
        "name": "Change",
        "untranslatedName": "Change",
        "subtask": false,
        "avatarId": 10604
    }
]
"@
        #endregion Definitions

        #region Mocks
        Add-CommonMocks
        Add-MockGetJiraConfigServer

        Mock Invoke-JiraMethod -ParameterFilter {
            $Method -eq 'Get' -and
            $Uri -like '*/issuetype*'
        } {
            Write-MockInfo 'Invoke-JiraMethod' @{ Method = $Method; Uri = $Uri; Body = $Body }
        }
        #endregion Mocks
    }

    Describe 'Behavior testing' {
        BeforeAll {
            $assertMockCalledSplat = @{
                CommandName = 'Invoke-JiraMethod'
                ModuleName  = 'JiraPS'
                Exactly     = $true
                Times       = 1
                Scope       = 'It'
            }
        }

        It 'Get all available IssueTypes' {
            Get-JiraIssueType

            Assert-MockCalled @assertMockCalledSplat -ParameterFilter {
                $Method -eq 'Get' -and
                $Uri -like '*/rest/api/*/issuetype'
            }
        }

        It 'Get a specific IssueType' {
            Get-JiraIssueType -IssueType 1000

            Assert-MockCalled @assertMockCalledSplat -ParameterFilter {
                $Method -eq 'Get' -and
                $Uri -like '*/rest/api/*/issuetype/1000'
            }
        }
    }

    Describe 'Input testing' {
        It "can find an IssueType by it's Id" {
            Get-JiraIssueType -IssueType 12844 -ErrorAction Stop
        }

        It 'fails if the IssueType contains no Id' {
            { Get-JiraIssueType -IssueType "Bug" -ErrorAction Stop } | Should -Throw -ExpectedMessage 'IssueType needs to be identifiable by Id. Id was missing.'
        }

        It 'accecpts multiple IssueTypes' {
            Get-JiraIssueType -IssueType 12844, 12845, 12846 -ErrorAction Stop
        }

        It "allows for the IssueType to be passed over the pipeline" {
            10001 | Get-JiraIssueType -ErrorAction Stop
            $mockedJiraIssueType | Get-JiraIssueType -ErrorAction Stop
        }
    }

    Describe 'Forming of the request' { }
}
