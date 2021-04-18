#requires -modules @{ ModuleName = "Pester"; ModuleVersion = "5.0" }

Import-Module "$PSScriptRoot/../../JiraPS" -Force
Import-Module "$PSScriptRoot/../../Tools/TestTools.psm1" -Force

Describe "ConvertTo-JiraPriority" -Tag 'Unit' {
    BeforeAll {
        $sampleObject = ConvertFrom-Json -InputObject @"
{
    "self": "http://jiraserver.example.com/rest/api/2/priority/1",
    "statusColor": "#cc0000",
    "description": "Cannot contine normal operations",
    "name": "Critical",
    "id": "1"
}
"@

        #region Mocks
        Add-MockConvertToJiraUser
        #endregion Mocks
    }

    Describe "Instanciating an object" {
        It "Creates a new instance via typed input" {
            [AtlassianPS.JiraPS.Priority]10001 | Should -BeOfType [AtlassianPS.JiraPS.Priority]
            [AtlassianPS.JiraPS.Priority]"10001" | Should -BeOfType [AtlassianPS.JiraPS.Priority]
            [AtlassianPS.JiraPS.Priority]"Major" | Should -BeOfType [AtlassianPS.JiraPS.Priority]
        }

        It "Creates a new instance via hashtable" {
            [AtlassianPS.JiraPS.Priority]@{
                Id   = 10001
                Name = 'Major'
            } | Should -BeOfType [AtlassianPS.JiraPS.Priority]
        }
    }

    Describe "Conversion of InputObject" {
        BeforeAll {
            $priority = InModuleScope JiraPS {
                param($sampleObject)
                ConvertTo-JiraPriority -InputObject $sampleObject
            } -Parameters @{ sampleObject = $sampleObject }
        }

        It "can convert to Priority object" {
            $priority | Should -HaveCount 1
        }

        It "returns an object of type [AtlassianPS.JiraPS.Priority]" {
            $priority | Should -BeOfType [AtlassianPS.JiraPS.Priority]
        }

        It 'converts nested types' { }
    }

    Describe "Return the expected format" {
        BeforeEach {
            $priority = InModuleScope JiraPS {
                param($sampleObject)
                ConvertTo-JiraPriority -InputObject $sampleObject
            } -Parameters @{ sampleObject = $sampleObject }
        }

        It "has a property '<property>' with value '<value>' of type '<type>'" -ForEach @(
            @{ property = 'Id'; value = '1' }
            @{ property = 'name'; value = 'Critical' }
            @{ property = 'description'; value = 'Cannot contine normal operations' }
            @{ property = 'statusColor'; value = '#cc0000' }
            @{ property = 'IsSubtask'; value = $false }
            @{ property = 'AvatarId' }
            @{ property = 'EntityId' }
            @{ property = 'HierarchyLevel' }
            @{ property = 'IconUrl' }
            @{ property = 'restUrl'; value = 'http://jiraserver.example.com/rest/api/2/priority/1' }
        ) {
            $priority.PSObject.Properties.Name | Should -Contain $property
            if ($value) {
                $priority.$property | Should -Be $value
            }
            if ($type) {
                , ($priority.$property) | Should -BeOfType $type
            }
        }

        It "prints nicely to string" {
            $priority1 = [AtlassianPS.JiraPS.Priority]10001
            $priority2 = [AtlassianPS.JiraPS.Priority]"10001"
            $priority3 = [AtlassianPS.JiraPS.Priority]"Major"
            $priority4 = [AtlassianPS.JiraPS.Priority]@{
                Id   = 10001
                Name = 'Major'
            }

            $priority1.ToString() | Should -Be 'id: 10001'
            $priority2.ToString() | Should -Be 'id: 10001'
            $priority3.ToString() | Should -Be 'Major'
            $priority4.ToString() | Should -Be 'Major'
        }
    }
}
