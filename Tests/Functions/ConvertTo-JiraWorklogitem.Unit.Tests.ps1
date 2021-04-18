#requires -modules @{ ModuleName = "Pester"; ModuleVersion = "5.0" }

Import-Module "$PSScriptRoot/../../JiraPS" -Force
Import-Module "$PSScriptRoot/../../Tools/TestTools.psm1" -Force

Describe "ConvertTo-JiraWorklogitem" -Tag 'Unit' {
    BeforeAll {
        $sampleObject = ConvertFrom-Json -InputObject @"
{
    "self": "https://powershell.atlassian.net/rest/api/2/issue/10013/worklog/10007",
    "comment": "a comment",
    "author": {
        "self": "https://powershell.atlassian.net/rest/api/2/user?accountId=557058%3A15b2a9f1-1893-42b3-a6b5-ab899c878d00",
        "accountId": "557058:15b2a9f1-1893-42b3-a6b5-ab899c878d00",
        "emailAddress": "oliver@lipkau.net",
    },
    "updateAuthor": {
        "self": "https://powershell.atlassian.net/rest/api/2/user?accountId=557058%3A15b2a9f1-1893-42b3-a6b5-ab899c878d00",
        "accountId": "557058:15b2a9f1-1893-42b3-a6b5-ab899c878d00",
        "emailAddress": "oliver@lipkau.net",
    },
    "created": "2021-03-20T22:30:47.694+0100",
    "updated": "2021-03-20T22:30:47.694+0100",
    "started": "2021-03-20T22:30:00.000+0100",
    "timeSpent": "3d",
    "timeSpentSeconds": 86400,
    "id": "10007",
    "issueId": "10013"
}
"@

        #region Mocks
        Add-MockConvertToJiraUser
        #endregion Mocks
    }

    Describe "Instanciating an object" {
        It "Creates a new instance via typed input" { }

        It "Creates a new instance via hashtable" {
            [AtlassianPS.JiraPS.WorklogItem]@{
                Issue   = 10001
                Comment = 'A comment'
            } | Should -BeOfType [AtlassianPS.JiraPS.WorklogItem]
        }
    }

    Describe "Conversion of InputObject" {
        BeforeAll {
            $worklogItem = InModuleScope JiraPS {
                param($sampleObject)
                ConvertTo-JiraWorklogItem -InputObject $sampleObject
            } -Parameters @{ sampleObject = $sampleObject }
        }

        It "can convert to Status object" {
            $worklogItem | Should -HaveCount 1
        }

        It "returns an object of type [AtlassianPS.JiraPS.WorklogItem]" {
            $worklogItem | Should -BeOfType [AtlassianPS.JiraPS.WorklogItem]
        }

        It 'converts nested types' {
            Assert-MockCalled -CommandName 'ConvertTo-JiraUser' -ModuleName 'JiraPS' -Scope 'Describe' -Exactly -Times 2
        }
    }

    Describe "Return the expected format" {
        BeforeEach {
            $worklogItem = InModuleScope JiraPS {
                param($sampleObject)
                ConvertTo-JiraWorklogItem -InputObject $sampleObject
            } -Parameters @{ sampleObject = $sampleObject }
        }

        It "has a property '<property>' with value '<value>' of type '<type>'" -ForEach @(
            @{ property = 'Id'; value = '10007' }
            @{ property = 'Issue'; type = 'AtlassianPS.JiraPS.Issue' }
            @{ property = 'Comment'; value = 'a comment' }
            @{ property = 'Author'; type = 'AtlassianPS.JiraPS.User' }
            @{ property = 'UpdateAuthor'; type = 'AtlassianPS.JiraPS.User' }
            @{ property = 'Created'; type = 'DateTime' }
            @{ property = 'Updated'; type = 'DateTime' }
            @{ property = 'Started'; type = 'DateTime' }
            @{ property = 'TimeSpent'; value = '3d' }
            @{ property = 'timeSpentSeconds'; value = '86400' }
            @{ property = 'restUrl'; value = 'https://powershell.atlassian.net/rest/api/2/issue/10013/worklog/10007' }
        ) {
            $worklogItem.PSObject.Properties.Name | Should -Contain $property
            if ($value) {
                $worklogItem.$property | Should -Be $value
            }
            if ($type) {
                , ($worklogItem.$property) | Should -BeOfType $type
            }
        }

        It "prints nicely to string" {
            $worklogItem.ToString() | Should -Be 'id: 10007'
        }
    }
}
