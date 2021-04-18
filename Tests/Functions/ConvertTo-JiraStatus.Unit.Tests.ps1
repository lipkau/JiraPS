#requires -modules @{ ModuleName = "Pester"; ModuleVersion = "5.0" }

Import-Module "$PSScriptRoot/../../JiraPS" -Force
Import-Module "$PSScriptRoot/../../Tools/TestTools.psm1" -Force

Describe "ConvertTo-JiraStatus" -Tag 'Unit' {
    BeforeAll {
        $sampleObject = ConvertFrom-Json -InputObject @"
{
    "self": "http://jiraserver.example.com/rest/api/2/status/3",
    "description": "This issue is being actively worked on at the moment by the assignee.",
    "iconUrl": "http://jiraserver.example.com/images/icons/statuses/inprogress.png",
    "name": "In Progress",
    "id": "3",
    "statusCategory": {
        "self": "http://jiraserver.example.com/rest/api/2/statuscategory/4",
        "id": 4,
        "key": "indeterminate",
        "colorName": "yellow",
        "name": "In Progress"
    }
}
"@

        #region Mocks
        Mock ConvertTo-JiraStatusCategory -ModuleName 'JiraPS' { [AtlassianPS.JiraPS.StatusCategory]@{} }
        #endregion Mocks
    }

    Describe "Instanciating an object" {
        It "Creates a new instance via typed input" {
            [AtlassianPS.JiraPS.Status]10001 | Should -BeOfType [AtlassianPS.JiraPS.Status]
            [AtlassianPS.JiraPS.Status]"10001" | Should -BeOfType [AtlassianPS.JiraPS.Status]
            [AtlassianPS.JiraPS.Status]"In Progress" | Should -BeOfType [AtlassianPS.JiraPS.Status]
        }

        It "Creates a new instance via hashtable" {
            [AtlassianPS.JiraPS.Status]@{
                Id   = 10001
                Name = 'In Progress'
            } | Should -BeOfType [AtlassianPS.JiraPS.Status]
        }
    }

    Describe "Conversion of InputObject" {
        BeforeAll {
            $status = InModuleScope JiraPS {
                param($sampleObject)
                ConvertTo-JiraStatus -InputObject $sampleObject
            } -Parameters @{ sampleObject = $sampleObject }
        }

        It "can convert to Status object" {
            $status | Should -HaveCount 1
        }

        It "returns an object of type [AtlassianPS.JiraPS.Status]" {
            $status | Should -BeOfType [AtlassianPS.JiraPS.Status]
        }

        It 'converts nested types' {
            Assert-MockCalled -CommandName 'ConvertTo-JiraStatusCategory' -ModuleName 'JiraPS' -Scope 'Describe' -Exactly -Times 1
        }
    }

    Describe "Return the expected format" {
        BeforeEach {
            $status = InModuleScope JiraPS {
                param($sampleObject)
                ConvertTo-JiraStatus -InputObject $sampleObject
            } -Parameters @{ sampleObject = $sampleObject }
        }

        It "has a property '<property>' with value '<value>' of type '<type>'" -ForEach @(
            @{ property = 'Id'; value = '3' }
            @{ property = 'Name'; value = 'In Progress' }
            @{ property = 'Description'; value = 'This issue is being actively worked on at the moment by the assignee.' }
            @{ property = 'Category'; type = 'AtlassianPS.JiraPS.StatusCategory' }
            @{ property = 'IconUrl'; value = 'http://jiraserver.example.com/images/icons/statuses/inprogress.png' }
            @{ property = 'restUrl'; value = 'http://jiraserver.example.com/rest/api/2/status/3' }
        ) {
            $status.PSObject.Properties.Name | Should -Contain $property
            if ($value) {
                $status.$property | Should -Be $value
            }
            if ($type) {
                , ($status.$property) | Should -BeOfType $type
            }
        }

        It "prints nicely to string" {
            $status.ToString() | Should -Be 'In Progress'
        }
    }
}

