#requires -modules @{ ModuleName = "Pester"; ModuleVersion = "5.0" }

Import-Module "$PSScriptRoot/../../JiraPS" -Force
Import-Module "$PSScriptRoot/../../Tools/TestTools.psm1" -Force

Describe "Expand-Result" -Tag 'Unit' {
    Describe 'Behavior checking' {
        It "Expands the module's default envelopes" {
            $comments = InModuleScope JiraPS {
                $commentPaginated = ConvertFrom-Json -InputObject @"
{
    "startAt": 0,
    "maxResults": 1,
    "total": 2,
    "comments": [
        {
            "self": "https://your-domain.atlassian.net/rest/api/3/issue/10010/comment/10000",
            "id": "10000"
        },
        {
            "self": "https://your-domain.atlassian.net/rest/api/3/issue/10010/comment/10001",
            "id": "10001"
        }
    ]
}
"@
                Expand-Result -InputObject $commentPaginated
            }

            $comments | Should -HaveCount 2
        }

        It "does not expand envelops which are unknown" {
            $users = InModuleScope JiraPS {
                $userPaginated = ConvertFrom-Json -InputObject @"
{
    "startAt": 0,
    "maxResults": 1,
    "total": 2,
    "users": [
        {
            "self": "https://your-domain.atlassian.net/rest/api/3/issue/10010/comment/10000",
            "id": "10000"
        },
        {
            "self": "https://your-domain.atlassian.net/rest/api/3/issue/10010/comment/10001",
            "id": "10001"
        }
    ]
}
"@
                Expand-Result -InputObject $userPaginated
            }

            $users | Should -BeNullOrEmpty
        }

        It "expands unknown envelops after they are made known" {
            $users = InModuleScope JiraPS {
                $script:PagingContainers += "users"

                $userPaginated = ConvertFrom-Json -InputObject @"
{
    "startAt": 0,
    "maxResults": 1,
    "total": 2,
    "users": [
        {
            "self": "https://your-domain.atlassian.net/rest/api/3/issue/10010/comment/10000",
            "id": "10000"
        },
        {
            "self": "https://your-domain.atlassian.net/rest/api/3/issue/10010/comment/10001",
            "id": "10001"
        }
    ]
}
"@
                Expand-Result -InputObject $userPaginated
            }

            $users | Should -HaveCount 2
        }
    }
}
