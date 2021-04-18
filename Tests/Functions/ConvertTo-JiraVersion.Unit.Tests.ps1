#requires -modules @{ ModuleName = "Pester"; ModuleVersion = "5.0" }

Import-Module "$PSScriptRoot/../../JiraPS" -Force
Import-Module "$PSScriptRoot/../../Tools/TestTools.psm1" -Force

Describe "ConvertTo-JiraVersion" -Tag 'Unit' {
    BeforeAll {
        $sampleObject = ConvertFrom-Json -InputObject @"
{
    "self": "http://jiraserver.example.com/rest/api/2/version/10000",
    "id": "10000",
    "description": "An excellent version",
    "name": "New Version 1",
    "archived": false,
    "released": true,
    "releaseDate": "2010-07-06",
    "overdue": true,
    "userReleaseDate": "6/Jul/2010",
    "projectId": 20000
}
"@

        #region Mocks
        Add-MockGetJiraProject

        $date = Get-Date
        Mock Get-Date { $date }
        #endregion Mocks
    }

    Describe "Instanciating an object" {
        It "Creates a new instance via typed input" {
            [AtlassianPS.JiraPS.Version]10001 | Should -BeOfType [AtlassianPS.JiraPS.Version]
            [AtlassianPS.JiraPS.Version]"10001" | Should -BeOfType [AtlassianPS.JiraPS.Version]
            [AtlassianPS.JiraPS.Version]"v1.0" | Should -BeOfType [AtlassianPS.JiraPS.Version]
        }

        It "Creates a new instance via hashtable" {
            [AtlassianPS.JiraPS.Version]@{
                id          = "10000"
                description = "An excellent version"
                name        = "New Version 1"
            } | Should -BeOfType [AtlassianPS.JiraPS.Version]
        }
    }

    Describe "Conversion of InputObject" {
        BeforeAll {
            $version = InModuleScope JiraPS {
                param($sampleObject)
                ConvertTo-JiraVersion -InputObject $sampleObject
            } -Parameters @{ sampleObject = $sampleObject }
        }

        It "can convert to Status object" {
            $version | Should -HaveCount 1
        }

        It "returns an object of type [AtlassianPS.JiraPS.Version]" {
            $version | Should -BeOfType [AtlassianPS.JiraPS.Version]
        }

        It 'converts nested types' { }
    }

    Describe "Return the expected format" {
        BeforeEach {
            $version = InModuleScope JiraPS {
                param($sampleObject)
                ConvertTo-JiraVersion -InputObject $sampleObject
            } -Parameters @{ sampleObject = $sampleObject }
        }

        It "has a property '<property>' with value '<value>'" -TestCases @(
            @{ property = "ID"; value = 10000 }
            @{ property = "Project"; type = 'AtlassianPS.JiraPS.Project' }
            @{ property = "Name"; value = "New Version 1" }
            @{ property = "Description"; value = "An excellent version" }
            @{ property = "Archived"; type = 'Boolean' }
            @{ property = "Released"; type = 'Boolean' }
            @{ property = "Overdue"; type = 'Boolean' }
            @{ property = "startDate"; type = 'DateTime' }
            @{ property = "releaseDate"; type = 'DateTime' }
            @{ property = "RestUrl"; value = "http://jiraserver.example.com/rest/api/2/version/10000" }
        ) {
            param($property, $value)

            if ($value) {
                $version.$property | Should -Be $value
            }
            else {
                $version.PSObject.Properties.Name | Should -Contain $property
            }
        }

        It "prints nicely to string" {
            $version1 = [AtlassianPS.JiraPS.Version]10001
            $version2 = [AtlassianPS.JiraPS.Version]"10001"
            $version3 = [AtlassianPS.JiraPS.Version]"v1.0"
            $version4 = [AtlassianPS.JiraPS.Version]@{
                id          = "10000"
                description = "An excellent version"
                name        = "New Version 1"
            }

            $version1.ToString() | Should -Be $null
            $version2.ToString() | Should -Be $null
            $version3.ToString() | Should -Be 'v1.0'
            $version4.ToString() | Should -Be 'New Version 1'
        }
    }
}
