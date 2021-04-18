#requires -modules @{ ModuleName = "Pester"; ModuleVersion = "5.0" }

Import-Module "$PSScriptRoot/../../JiraPS" -Force
Import-Module "$PSScriptRoot/../../Tools/TestTools.psm1" -Force

Describe "ConvertTo-JiraComment" -Tag 'Unit' {
    BeforeAll {
        $sampleObject = ConvertFrom-Json -InputObject @"
{
    "self": "http://jiraserver.example.com/rest/api/2/issue/41701/comment/90730",
    "id": "90730",
    "author": {
        "self": "http://jiraserver.example.com/rest/api/2/user?username=JonDoe",
        "name": "JonDoe",
        "emailAddress": "JonDoe@server.com",
        "avatarUrls": {
            "48x48": "http://jiraserver.example.com/secure/useravatar?avatarId=10202",
            "24x24": "http://jiraserver.example.com/secure/useravatar?size=small&avatarId=10202",
            "16x16": "http://jiraserver.example.com/secure/useravatar?size=xsmall&avatarId=10202",
            "32x32": "http://jiraserver.example.com/secure/useravatar?size=medium&avatarId=10202"
        },
        "displayName": "Doe, Jon",
        "active": true
    },
    "body": "Test comment",
    "updateAuthor": {
        "self": "http://jiraserver.example.com/rest/api/2/user?username=JonDoe",
        "name": "JonDoe",
        "emailAddress": "JonDoe@server.com",
        "avatarUrls": {
            "48x48": "http://jiraserver.example.com/secure/useravatar?avatarId=10202",
            "24x24": "http://jiraserver.example.com/secure/useravatar?size=small&avatarId=10202",
            "16x16": "http://jiraserver.example.com/secure/useravatar?size=xsmall&avatarId=10202",
            "32x32": "http://jiraserver.example.com/secure/useravatar?size=medium&avatarId=10202"
        },
        "displayName": "Doe, Jon",
        "active": true
    },
    "created": "2015-05-01T16:24:38.000-0500",
    "updated": "2015-05-01T16:24:38.000-0500",
    "visibility": {
        "type": "role",
        "value": "Developers"
    }
}
"@

        #region Mocks
        Add-MockConvertToJiraUser

        $date = Get-Date
        Mock Get-Date { $date }
        #endregion Mocks
    }

    Describe "Instanciating an object" {
        It "Creates a new instance via typed input" {
            [AtlassianPS.JiraPS.Comment]"My Comment" | Should -BeOfType [AtlassianPS.JiraPS.Comment]
        }

        It "Creates a new instance via hashtable" {
            [AtlassianPS.JiraPS.Comment]@{
                body   = "My Comment"
                author = $mockedJiraCloudUser
            } | Should -BeOfType [AtlassianPS.JiraPS.Comment]
        }
    }

    Describe "Conversion of InputObject" {
        BeforeAll {
            $comment = InModuleScope JiraPS {
                param($sampleObject)
                ConvertTo-JiraComment -InputObject $sampleObject
            } -Parameters @{ sampleObject = $sampleObject }
        }

        It "can convert to Comment object" {
            $comment | Should -HaveCount 1
        }

        It "returns an object of type [AtlassianPS.JiraPS.Comment]" {
            $comment | Should -BeOfType [AtlassianPS.JiraPS.Comment]
        }

        It 'converts nested types' {
            Assert-MockCalled -CommandName 'ConvertTo-JiraUser' -ModuleName 'JiraPS' -Scope 'Describe' -Exactly -Times 2

            Assert-MockCalled -CommandName 'Get-Date' -ModuleName 'JiraPS' -Scope 'Describe' -Exactly -Times 2
        }
    }

    Describe "Return the expected format" {
        BeforeEach {
            $commnet = InModuleScope JiraPS {
                param($sampleObject)
                ConvertTo-JiraComment -InputObject $sampleObject
            } -Parameters @{ sampleObject = $sampleObject }
        }

        It "has a property '<property>' with value '<value>' of type '<type>'" -ForEach @(
            @{ property = 'Id'; value = 90730 }
            @{ property = 'Body'; value = 'Test comment' }
            @{ property = 'RestUrl'; value = 'http://jiraserver.example.com/rest/api/2/issue/41701/comment/90730' }
            @{ property = 'Created'; value = (Get-Date '2015-05-01T16:24:38.000-0500') }
            @{ property = 'Updated'; value = (Get-Date '2015-05-01T16:24:38.000-0500') }
        ) {
            $commnet.PSObject.Properties.Name | Should -Contain $property
            if ($value) {
                $commnet.$property | Should -Be $value
            }
            if ($type) {
                , ($commnet.$property) | Should -BeOfType $type
            }
        }

        It "prints nicely to string" {
            $commnet.ToString() | Should -Be 'Test comment'
        }
    }
}
