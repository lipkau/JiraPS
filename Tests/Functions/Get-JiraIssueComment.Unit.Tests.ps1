#requires -modules @{ ModuleName = "Pester"; ModuleVersion = "5.0" }

Import-Module "$PSScriptRoot/../../JiraPS" -Force
Import-Module "$PSScriptRoot/../../Tools/TestTools.psm1" -Force

Describe "Get-JiraIssueComment" -Tag 'Unit' {
    BeforeAll {
        $commentResponse = @"
{
    "startAt": 0,
    "maxResults": 1048576,
    "total": 2,
    "comments": [
        {
            "self": "https://powershell.atlassian.net/rest/api/2/issue/10013/comment/10005",
            "id": "10005",
            "author": {
                "emailAddress": "oliver@lipkau.net",
            },
            "body": "Joined Sample Sprint 2 1 days 4 hours 10 minutes ago",
            "updateAuthor": {
                "emailAddress": "oliver@lipkau.net",
            },
            "created": "2017-06-23T04:35:22.145+0200",
            "updated": "2017-06-23T04:35:22.145+0200",
            "jsdPublic": true
        },
        {
            "self": "https://powershell.atlassian.net/rest/api/2/issue/10013/comment/10103",
            "id": "10103",
            "author": {
                "emailAddress": "oliver@lipkau.net",
            },
            "body": "restricted comment",
            "updateAuthor": {
                "emailAddress": "oliver@lipkau.net",
            },
            "created": "2021-04-05T20:35:03.838+0200",
            "updated": "2021-04-05T20:35:03.838+0200",
            "visibility": {
                "type": "role",
                "value": "Developers"
            },
            "jsdPublic": true
        }
    ]
}
"@

        #region Mocks
        Add-CommonMocks

        Add-MockGetJiraIssue

        Add-MockResolveJiraIssueUrl

        Mock Invoke-JiraMethod -ParameterFilter {
            $Method -eq 'GET' -and
            $URI -like '*/issue/41701/comment'
        } {
            Write-MockInfo 'Invoke-JiraMethod' @{ Method = $Method; Uri = $Uri; Body = $Body }
            $mockedJiraIssueComment, $mockedJiraIssueComment
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

        It 'Get all comments of an Issue' {
            Get-JiraIssueComment -Issue 'TEST-001'

            Assert-MockCalled @assertMockCalledSplat
        }

        It 'Resolves pagination' {
            Get-JiraIssueComment -Issue 'TEST-001'

            Assert-MockCalled @assertMockCalledSplat -ParameterFilter { $Paging -eq $true }
        }

        It 'Converts results to [AtlassianPS.JiraPS.Comment]' {
            Get-JiraIssueComment -Issue 'TEST-001'

            Assert-MockCalled @assertMockCalledSplat -ParameterFilter { $OutputType -eq "JiraComment" }
        }
    }

    Describe 'Input testing' {
        It 'resolves the url of the issue' {
            Get-JiraIssueComment -Issue 12844

            Assert-MockCalled -CommandName Resolve-JiraIssueUrl -ModuleName 'JiraPS' -Exactly -Times 1 -Scope It
        }

        It 'accepts all forms of Issue input' {
            Get-JiraIssueComment -Issue 41701  -ErrorAction Stop
            Get-JiraIssueComment -Issue 'TEST-001'  -ErrorAction Stop
            Get-JiraIssueComment -Issue $mockedJiraIssue  -ErrorAction Stop
        }

        It "allows for the IssueType to be passed over the pipeline" {
            $mockedJiraIssue | Get-JiraIssueComment -ErrorAction Stop
        }
    }

    Describe 'Forming of the request' { }
}
