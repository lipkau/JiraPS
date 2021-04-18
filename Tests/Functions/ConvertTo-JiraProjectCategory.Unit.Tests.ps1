#requires -modules @{ ModuleName = "Pester"; ModuleVersion = "5.0" }

Import-Module "$PSScriptRoot/../../JiraPS" -Force
Import-Module "$PSScriptRoot/../../Tools/TestTools.psm1" -Force

Describe "ConvertTo-JiraProjectCategory" -Tag 'Unit' {
    BeforeAll {
        $sampleObject = ConvertFrom-Json -InputObject  @"
{
    "self":"https://example.com/rest/api/2/projectCategory/10000",
    "id":"10000",
    "name":"Important",
    "description":"Important Projects"
}
"@
    }

    Describe "Instanciating an object" {
        It "Creates a new instance via typed input" { }

        It "Creates a new instance via hashtable" {
            [AtlassianPS.JiraPS.ProjectCategory]@{
                name        = "jira-developers"
                description = "A project Category that represents administrators in a project"
            } | Should -BeOfType [AtlassianPS.JiraPS.ProjectCategory]
        }
    }

    Describe "Conversion of InputObject" {
        BeforeAll {
            $category = InModuleScope JiraPS {
                param($sampleObject)
                ConvertTo-JiraProjectCategory -InputObject $sampleObject
            } -Parameters @{ sampleObject = $sampleObject }
        }

        It "can convert to Category object" {
            $category | Should -HaveCount 1
        }

        It "returns an object of type [AtlassianPS.JiraPS.ProjectCategory]" {
            $category | Should -BeOfType [AtlassianPS.JiraPS.ProjectCategory]
        }

        It 'converts nested types' { }
    }

    Describe "Return the expected format" {
        BeforeEach {
            $category = InModuleScope JiraPS {
                param($sampleObject)
                ConvertTo-JiraProjectCategory -InputObject $sampleObject
            } -Parameters @{ sampleObject = $sampleObject }
        }

        It "has a property '<property>' with value '<value>' of type '<type>'" -ForEach @(
            @{ property = 'Id'; value = '10000' }
            @{ property = 'name'; value = 'Important' }
            @{ property = 'description'; value = 'Important Projects' }
            @{ property = 'RestUrl'; value = 'https://example.com/rest/api/2/projectCategory/10000' }
        ) {
            $category.PSObject.Properties.Name | Should -Contain $property
            if ($value) {
                $category.$property | Should -Be $value
            }
            if ($type) {
                , ($category.$property) | Should -BeOfType $type
            }
        }

        It "prints nicely to string" {
            $category.ToString() | Should -Be 'Important'
        }
    }
}
