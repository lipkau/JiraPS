#requires -modules @{ ModuleName = "Pester"; ModuleVersion = "5.0" }

Import-Module "$PSScriptRoot/../../JiraPS" -Force
Import-Module "$PSScriptRoot/../../Tools/TestTools.psm1" -Force

Describe "ConvertTo-JiraFilterPermission" -Tag 'Unit' {
    BeforeAll {
        $sampleObject = ConvertFrom-Json -InputObject @"
[
    {
        "id": 10000,
        "type": "global"
    },
    {
        "id": 10010,
        "type": "project",
        "project": {
            "self": "https://example.com/jira/rest/api/2/project/EX",
            "id": "10000",
            "key": "EX",
            "name": "Example",
            "avatarUrls": {
                "48x48": "https://example.com/jira/secure/projectavatar?size=large&pid=10000",
                "24x24": "https://example.com/jira/secure/projectavatar?size=small&pid=10000",
                "16x16": "https://example.com/jira/secure/projectavatar?size=xsmall&pid=10000",
                "32x32": "https://example.com/jira/secure/projectavatar?size=medium&pid=10000"
            },
            "projectCategory": {
                "self": "https://example.com/jira/rest/api/2/projectCategory/10000",
                "id": "10000",
                "name": "FIRST",
                "description": "First Project Category"
            },
            "simplified": false
        }
    },
    {
        "id": 10010,
        "type": "project",
        "project": {
            "self": "https://example.com/jira/rest/api/2/project/MKY",
            "id": "10002",
            "key": "MKY",
            "name": "Example",
            "avatarUrls": {
                "48x48": "https://example.com/jira/secure/projectavatar?size=large&pid=10002",
                "24x24": "https://example.com/jira/secure/projectavatar?size=small&pid=10002",
                "16x16": "https://example.com/jira/secure/projectavatar?size=xsmall&pid=10002",
                "32x32": "https://example.com/jira/secure/projectavatar?size=medium&pid=10002"
            },
            "projectCategory": {
                "self": "https://example.com/jira/rest/api/2/projectCategory/10000",
                "id": "10000",
                "name": "FIRST",
                "description": "First Project Category"
            },
            "simplified": false
        },
        "role": {
            "self": "https://example.com/jira/rest/api/2/project/MKY/role/10360",
            "name": "Developers",
            "id": 10360,
            "description": "A project role that represents developers in a project",
            "actors": [
                {
                    "id": 10240,
                    "displayName": "jira-developers",
                    "type": "atlassian-group-role-actor",
                    "name": "jira-developers"
                },
                {
                    "id": 10241,
                    "displayName": "Fred F. User",
                    "type": "atlassian-user-role-actor",
                    "name": "fred"
                }
            ]
        }
    },
    {
        "id": 10010,
        "type": "group",
        "group": {
            "name": "jira-administrators",
            "self": "https://example.com/jira/rest/api/2/group?groupname=jira-administrators"
        }
    }
]
"@

        #region Mocks
        Mock ConvertTo-JiraGroup -ModuleName 'JiraPS' { [AtlassianPS.JiraPS.Group]@{} }

        Mock ConvertTo-JiraProject -ModuleName 'JiraPS' { [AtlassianPS.JiraPS.Project]@{} }

        Mock ConvertTo-JiraRole -ModuleName 'JiraPS' { [AtlassianPS.JiraPS.Role]@{} }
        #endregion Mocks
    }

    Describe "Instanciating an object" {
        It "Creates a new instance via typed input" { }

        It "Creates a new instance via hashtable" {
            [AtlassianPS.JiraPS.FilterPermission]@{
                Id   = 123
                Type = "GLOBAL"
            } | Should -BeOfType [AtlassianPS.JiraPS.FilterPermission]
        }
    }

    Describe "Conversion of InputObject" {
        BeforeAll {
            $filterPermission = InModuleScope JiraPS {
                param($sampleObject)
                ConvertTo-JiraFilterPermission -InputObject $sampleObject
            } -Parameters @{ sampleObject = $sampleObject }
        }

        It "can convert to JiraFilterPermission object" {
            $filterPermission | Should -HaveCount 4
        }

        It "returns an object of type [AtlassianPS.JiraPS.FilterPermission]" {
            $filterPermission | Should -BeOfType [AtlassianPS.JiraPS.FilterPermission]
        }

        It 'converts nested types' {
            Assert-MockCalled -CommandName 'ConvertTo-JiraGroup' -ModuleName 'JiraPS' -Scope 'Describe' -Exactly -Times 4
            Assert-MockCalled -CommandName 'ConvertTo-JiraProject' -ModuleName 'JiraPS' -Scope 'Describe' -Exactly -Times 4
            Assert-MockCalled -CommandName 'ConvertTo-JiraRole' -ModuleName 'JiraPS' -Scope 'Describe' -Exactly -Times 4
        }
    }

    Describe "Return the expected format" {
        BeforeEach {
            $filterPermission = InModuleScope JiraPS {
                param($sampleObject)
                ConvertTo-JiraFilterPermission -InputObject $sampleObject
            } -Parameters @{ sampleObject = $sampleObject }
        }

        It "has a property '<property>' with value '<value>' of type '<type>'" -ForEach @(
            @{ property = 'id'; value = '10010' }
            @{ property = 'type'; value = 'PROJECT'; type = 'AtlassianPS.JiraPS.FilterShareType' }
            @{ property = 'project'; type = 'AtlassianPS.JiraPS.Project' }
            @{ property = 'role'; type = 'AtlassianPS.JiraPS.Role' }
        ) {
            $filterPermission[2].PSObject.Properties.Name | Should -Contain $property
            if ($value) {
                $filterPermission[2].$property | Should -Be $value
            }
            if ($type) {
                , ($filterPermission[2].$property) | Should -BeOfType $type
            }
        }

        It "prints nicely to string" { }
    }
}
