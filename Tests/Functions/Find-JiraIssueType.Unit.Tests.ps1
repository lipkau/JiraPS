#requires -modules @{ ModuleName = "Pester"; ModuleVersion = "5.0" }

Import-Module "$PSScriptRoot/../../JiraPS" -Force
Import-Module "$PSScriptRoot/../../Tools/TestTools.psm1" -Force

Describe "Find-JiraIssueType" -Tag 'Unit' {
    BeforeAll {
        #region Definitions
        $issueTypeResponse = ConvertFrom-Json -InputObject @"
[
    {
        "self": "https://powershell.atlassian.net/rest/api/2/issuetype/10207",
        "id": "10207",
        "description": "For customer support issues. Created by JIRA Service Desk.",
        "iconUrl": "https://powershell.atlassian.net/secure/viewavatar?size=medium&avatarId=10607&avatarType=issuetype",
        "name": "Support Change",
        "untranslatedName": "Support Change",
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

        Mock Get-JiraIssueType { $issueTypeResponse }
        #endregion Mocks
    }

    Describe 'Behavior testing' {
        BeforeAll {
            $assertMockCalledSplat = @{
                CommandName = 'Get-JiraIssueType'
                ModuleName  = 'JiraPS'
                Exactly     = $true
                Times       = 1
                Scope       = 'It'
            }
        }

        It "Find an IssueType by it's name" {
            Find-JiraIssueType -Name 'Change' | Should -HaveCount 1

            Assert-MockCalled @assertMockCalledSplat
        }

        It 'Find an IssueType with wildcards' {
            Find-JiraIssueType '*Change' | Should -HaveCount 2

            Assert-MockCalled @assertMockCalledSplat
        }
    }

    Describe 'Input testing' {
        It "accepts multiple names" {
            Find-JiraIssueType 'Change', 'Support Change' | Should -HaveCount 2
        }

        It "allows for the name to be passed over the pipeline" {
            'Change', 'Support Change' | Find-JiraIssueType | Should -HaveCount 2
        }
    }

    Describe 'Forming of the request' { }
}

