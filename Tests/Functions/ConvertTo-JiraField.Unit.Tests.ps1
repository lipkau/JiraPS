#requires -modules @{ ModuleName = "Pester"; ModuleVersion = "5.0" }

Import-Module "$PSScriptRoot/../../JiraPS" -Force
Import-Module "$PSScriptRoot/../../Tools/TestTools.psm1" -Force

Describe "ConvertTo-JiraField" -Tag 'Unit' {
    BeforeAll {
        $sampleObject = ConvertFrom-Json -InputObject @'
{
    "id": "issuelinks",
    "key": "issuelinks",
    "name": "Linked Issues",
    "custom": false,
    "orderable": true,
    "navigable": true,
    "searchable": true,
    "clauseNames": [
        "issueLink",
        "somethingelse"
    ],
    "schema": {
        "type": "array",
        "items": "issuelinks",
        "system": "issuelinks"
    }
}
'@

        #region Mocks
        Add-MockConvertToJiraUser
        #endregion Mocks
    }

    Describe "Instanciating an object" {
        It "Creates a new instance via typed input" {
            $field1 = [AtlassianPS.JiraPS.Field]"issuelink"
            $field2 = [AtlassianPS.JiraPS.Field]"Issue Link"
            $field3 = [AtlassianPS.JiraPS.Field]"CustomField_10000"

            $field1, $field2, $field3 | Should -BeOfType [AtlassianPS.JiraPS.Field]

            $field1.Id | Should -Be 'issuelink'
            $field1.Name | Should -Be $null

            $field2.Id | Should -Be $null
            $field2.Name | Should -Be 'Issue Link'

            $field3.Id | Should -Be 'customfield_10000'
            $field3.Name | Should -Be $null
        }

        It "Creates a new instance via hashtable" {
            [AtlassianPS.JiraPS.Field]@{
                id   = "issuelinks"
                name = "Linked Issues"
            } | Should -BeOfType [AtlassianPS.JiraPS.Field]
        }
    }

    Describe "Conversion of InputObject" {
        BeforeAll {
            $field = InModuleScope JiraPS {
                param($sampleObject)
                ConvertTo-JiraField -InputObject $sampleObject
            } -Parameters @{ sampleObject = $sampleObject }
        }

        It "can convert to Field object" {
            $field | Should -HaveCount 1
        }

        It "returns an object of type [AtlassianPS.JiraPS.Field]" {
            $field | Should -BeOfType [AtlassianPS.JiraPS.Field]
        }

        It 'converts nested types' { }
    }

    Describe "Return the expected format" {
        BeforeEach {
            $field = InModuleScope JiraPS {
                param($sampleObject)
                ConvertTo-JiraField -InputObject $sampleObject
            } -Parameters @{ sampleObject = $sampleObject }
        }

        It "has a property '<property>' with value '<value>' of type '<type>'" -ForEach @(
            @{ property = 'Id'; value = 'issuelinks' }
            @{ property = 'Key'; value = 'issuelinks' }
            @{ property = 'Name'; value = 'Linked Issues' }
            @{ property = 'Custom'; value = $false; type = 'Boolean' }
            @{ property = 'Orderable'; value = $true; type = 'Boolean' }
            @{ property = 'Navigable'; value = $true; type = 'Boolean' }
            @{ property = 'Searchable'; value = $true; type = 'Boolean' }
            @{ property = 'ClauseNames'; type = 'String[]' }
            @{ property = 'Schema'; }
        ) {
            $field.PSObject.Properties.Name | Should -Contain $property
            if ($value) {
                $field.$property | Should -Be $value
            }
            if ($type) {
                , ($field.$property) | Should -BeOfType $type
            }
        }

        It "prints nicely to string" {
            $field1 = [AtlassianPS.JiraPS.Field]"issuelink"
            $field2 = [AtlassianPS.JiraPS.Field]"Linked Issues"
            $field3 = [AtlassianPS.JiraPS.Field]@{
                id   = "issuelinks"
                name = "Linked Issues"
            }

            $field1.ToString() | Should -Be 'id: issuelink'
            $field2.ToString() | Should -Be 'Linked Issues'
            $field3.ToString() | Should -Be 'Linked Issues'
        }
    }
}
