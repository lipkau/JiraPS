#requires -modules @{ ModuleName = "Pester"; ModuleVersion = "5.0" }

Import-Module "$PSScriptRoot/../../JiraPS" -Force
Import-Module "$PSScriptRoot/../../Tools/TestTools.psm1" -Force

Describe "ConvertTo-JiraTransition" -Tag 'Unit' {
    BeforeAll {
        $sampleObject = ConvertFrom-Json -InputObject @"
{
    "id": "11",
    "name": "To Do",
    "to": {
        "self": "https://powershell.atlassian.net/rest/api/2/status/10000",
        "description": "",
        "iconUrl": "https://powershell.atlassian.net/",
        "name": "To Do",
        "id": "10000",
        "statusCategory": {
            "self": "https://powershell.atlassian.net/rest/api/2/statuscategory/2",
            "id": 2,
            "key": "new",
            "colorName": "blue-gray",
            "name": "To Do"
        }
    },
    "hasScreen": false,
    "isGlobal": true,
    "isInitial": false,
    "isAvailable": true,
    "isConditional": false,
    "isLooped": false
}
"@

        #region Mocks
        Mock ConvertTo-JiraStatus -ModuleName 'JiraPS' { [AtlassianPS.JiraPS.Status]@{ } }
        #endregion Mocks
    }

    Describe "Instanciating an object" {
        It "Creates a new instance via typed input" {
            [AtlassianPS.JiraPS.Transition]11 | Should -BeOfType [AtlassianPS.JiraPS.Transition]
            [AtlassianPS.JiraPS.Transition]"11" | Should -BeOfType [AtlassianPS.JiraPS.Transition]
            [AtlassianPS.JiraPS.Transition]"In Progress" | Should -BeOfType [AtlassianPS.JiraPS.Transition]
        }

        It "Creates a new instance via hashtable" {
            [AtlassianPS.JiraPS.Transition]@{
                Id           = 4
                Name         = "In Process"
                ResultStatus = $mockedJiraStatus
            } | Should -BeOfType [AtlassianPS.JiraPS.Transition]
        }
    }

    Describe "Conversion of InputObject" {
        BeforeAll {
            $transition = InModuleScope JiraPS {
                param($sampleObject)
                ConvertTo-JiraTransition -InputObject $sampleObject
            } -Parameters @{ sampleObject = $sampleObject }
        }

        It "can convert to Transition object" {
            $transition | Should -HaveCount 1
        }

        It "returns an object of type [AtlassianPS.JiraPS.Transition]" {
            $transition | Should -BeOfType [AtlassianPS.JiraPS.Transition]
        }

        It 'converts nested types' {
            Assert-MockCalled -CommandName 'ConvertTo-JiraStatus' -ModuleName 'JiraPS' -Scope 'Describe' -Exactly -Times 1
        }
    }

    Describe "Return the expected format" {
        BeforeEach {
            $transition = InModuleScope JiraPS {
                param($sampleObject)
                ConvertTo-JiraTransition -InputObject $sampleObject
            } -Parameters @{ sampleObject = $sampleObject }
        }

        It "has a property '<property>' with value '<value>' of type '<type>'" -ForEach @(
            @{ property = 'Id'; value = '11' }
            @{ property = 'Name'; value = 'To Do' }
            @{ property = 'ResultStatus'; type = 'AtlassianPS.JiraPS.Status' }
        ) {
            $transition.PSObject.Properties.Name | Should -Contain $property
            if ($value) {
                $transition.$property | Should -Be $value
            }
            if ($type) {
                , ($transition.$property) | Should -BeOfType $type
            }
        }

        It "prints nicely to string" {
            $transition1 = [AtlassianPS.JiraPS.Transition]11
            $transition2 = [AtlassianPS.JiraPS.Transition]"11"
            $transition3 = [AtlassianPS.JiraPS.Transition]"In Progress"
            $transition4 = [AtlassianPS.JiraPS.Transition]@{
                Id           = 4
                Name         = "In Process"
                ResultStatus = $mockedJiraStatus
            }

            $transition1.ToString() | Should -Be $null
            $transition2.ToString() | Should -Be $null
            $transition3.ToString() | Should -Be 'In Progress'
            $transition4.ToString() | Should -Be 'In Process'
        }
    }
}
