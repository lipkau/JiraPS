#requires -modules @{ ModuleName = "Pester"; ModuleVersion = "5.0" }

Import-Module "$PSScriptRoot/../../JiraPS" -Force
Import-Module "$PSScriptRoot/../../Tools/TestTools.psm1" -Force

Describe "ConvertTo-JiraComponent" -Tag 'Unit' {
    BeforeAll {
        $sampleObject = ConvertFrom-Json -InputObject @"
{
    "self": "https://your-domain.atlassian.net/rest/api/3/component/10000",
    "id": "10000",
    "name": "Component 1",
    "description": "This is a Jira component",
    "lead": {
        "self": "https://your-domain.atlassian.net/rest/api/3/user?accountId=5b10a2844c20165700ede21g",
        "key": "",
        "accountId": "5b10a2844c20165700ede21g",
        "name": ""
    },
    "assigneeType": "PROJECT_LEAD",
    "assignee": {
        "self": "https://your-domain.atlassian.net/rest/api/3/user?accountId=5b10a2844c20165700ede21g",
        "key": "",
        "accountId": "5b10a2844c20165700ede21g",
        "name": ""
    },
    "realAssigneeType": "PROJECT_LEAD",
    "realAssignee": {
        "self": "https://your-domain.atlassian.net/rest/api/3/user?accountId=5b10a2844c20165700ede21g",
        "key": "",
        "accountId": "5b10a2844c20165700ede21g",
        "name": ""
    },
    "isAssigneeTypeValid": false,
    "project": "HSP",
    "projectId": 10000
    }
"@

        #region Mocks
        Add-MockConvertToJiraUser
        #endregion Mocks
    }

    Describe "Instanciating an object" {
        It "Creates a new instance via typed input" {
            [AtlassianPS.JiraPS.Component]"Component 1" | Should -BeOfType [AtlassianPS.JiraPS.Component]
        }

        It "Creates a new instance via hashtable" {
            [AtlassianPS.JiraPS.Component]@{
                name        = "Component 1"
                description = "This is a Jira component"
            } | Should -BeOfType [AtlassianPS.JiraPS.Component]
        }
    }

    Describe "Conversion of InputObject" {
        BeforeAll {
            $component = InModuleScope JiraPS {
                param($sampleObject)
                ConvertTo-JiraComponent -InputObject $sampleObject
            } -Parameters @{ sampleObject = $sampleObject }
        }

        It "can convert to Component object" {
            $component | Should -HaveCount 1
        }

        It "returns an object of type [AtlassianPS.JiraPS.Component]" {
            $component | Should -BeOfType [AtlassianPS.JiraPS.Component]
        }

        It 'converts nested types' {
            Assert-MockCalled -CommandName 'ConvertTo-JiraUser' -ModuleName 'JiraPS' -Scope 'Describe' -Exactly -Times 3
        }
    }

    Describe "Return the expected format" {
        BeforeEach {
            $component = InModuleScope JiraPS {
                param($sampleObject)
                ConvertTo-JiraComponent -InputObject $sampleObject
            } -Parameters @{ sampleObject = $sampleObject }
        }

        It "has a property '<property>' with value '<value>' of type '<type>'" -ForEach @(
            @{ property = 'Id'; value = '10000' }
            @{ property = 'Name'; value = 'Component 1' }
            @{ property = 'Description'; value = 'This is a Jira component' }
            @{ property = 'Lead'; type = 'AtlassianPS.JiraPS.User' }
            @{ property = 'AssigneeType'; type = 'AtlassianPS.JiraPS.AssigneeType'; value = 'PROJECT_LEAD' }
            @{ property = 'Assignee'; type = 'AtlassianPS.JiraPS.User' }
            @{ property = 'RealAssigneeType'; type = 'AtlassianPS.JiraPS.AssigneeType'; value = 'PROJECT_LEAD' }
            @{ property = 'RealAssignee'; type = 'AtlassianPS.JiraPS.User' }
            @{ property = 'IsAssigneeTypeValid'; type = 'Boolean'; value = $false }
            @{ property = 'Project'; type = 'AtlassianPS.JiraPS.Project' }
            @{ property = 'RestUrl'; value = 'https://your-domain.atlassian.net/rest/api/3/component/10000' }
        ) {
            $component.PSObject.Properties.Name | Should -Contain $property
            if ($value) {
                $component.$property | Should -Be $value
            }
            if ($type) {
                , ($component.$property) | Should -BeOfType $type
            }
        }

        It "prints nicely to string" {
            $component.ToString() | Should -Be 'Component 1'
        }
    }
}
