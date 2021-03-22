#requires -modules @{ ModuleName = "Pester"; ModuleVersion = "5.0" }

Import-Module "$PSScriptRoot/../../JiraPS" -Force
Import-Module "$PSScriptRoot/../../Tools/TestTools.psm1" -Force

Describe "ConvertTo-JiraStatusCategory" -Tag 'Unit' {
    BeforeAll {
        $sampleObject = ConvertFrom-Json -InputObject @"
{
    "self": "http://jiraserver.example.com/rest/api/2/statusCategory/4",
    "id": 4,
    "key": "indeterminate",
    "colorName": "yellow",
    "name": "In Progress"
}
"@
    }

    Describe "Instanciating an object" {
        It "Creates a new instance via typed input" { }

        It "Creates a new instance via hashtable" {
            [AtlassianPS.JiraPS.StatusCategory]@{
                id  = 4
                key = "indeterminate"
            } | Should -BeOfType [AtlassianPS.JiraPS.StatusCategory]
        }
    }

    Describe "Conversion of InputObject" {
        BeforeAll {
            Add-MockConvertToJiraUser

            $statusCategory = InModuleScope JiraPS { param($sampleObject) ConvertTo-JiraStatusCategory -InputObject $sampleObject } -Parameters @{ sampleObject = $sampleObject }
        }

        It "can convert to StatusCategory object" {
            $statusCategory | Should -HaveCount 1
        }

        It "returns an object of type [AtlassianPS.JiraPS.StatusCategory]" {
            $statusCategory | Should -BeOfType [AtlassianPS.JiraPS.StatusCategory]
        }

        It 'converts nested types' { }
    }

    Describe "Return the expected format" {
        BeforeEach {
            $statusCategory = InModuleScope JiraPS { param($sampleObject) ConvertTo-JiraStatusCategory -InputObject $sampleObject } -Parameters @{ sampleObject = $sampleObject }
        }

        It "has a property '<property>' with value '<value>' of type '<type>'" -ForEach @(
            @{ property = 'id'; value = '4' }
            @{ property = 'key'; value = 'indeterminate' }
            @{ property = 'colorName'; value = 'yellow' }
            @{ property = 'name'; value = 'In Progress' }
            @{ property = 'restUrl'; value = 'http://jiraserver.example.com/rest/api/2/statusCategory/4' }
        ) {
            $statusCategory.PSObject.Properties.Name | Should -Contain $property
            if ($value) {
                $statusCategory.$property | Should -Be $value
            }
            if ($type) {
                , ($statusCategory.$property) | Should -BeOfType $type
            }
        }

        It "prints nicely to string" { }
    }
}

