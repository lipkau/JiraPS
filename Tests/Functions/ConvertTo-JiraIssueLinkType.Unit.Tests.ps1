#requires -modules @{ ModuleName = "Pester"; ModuleVersion = "5.0" }

Import-Module "$PSScriptRoot/../../JiraPS" -Force
Import-Module "$PSScriptRoot/../../Tools/TestTools.psm1" -Force

Describe "ConvertTo-JiraIssueLinkType" -Tag 'Unit' {
    BeforeAll {
        $sampleObject = ConvertFrom-Json -InputObject @'
{
    "id": "10000",
    "name": "Blocks",
    "inward": "is blocked by",
    "outward": "blocks"
}
'@
    }

    Describe "Instanciating an object" {
        It "Creates a new instance via typed input" { }

        It "Creates a new instance via hashtable" {
            [AtlassianPS.JiraPS.IssueLinkType]@{
                id          = "10000"
                name        = "Blocks"
                inwardText  = "is blocked by"
                outwardText = "blocks"
            } | Should -BeOfType [AtlassianPS.JiraPS.IssueLinkType]
        }
    }

    Describe "Conversion of InputObject" {
        BeforeAll {
            $issueLinkType = InModuleScope JiraPS {
                param($sampleObject)
                ConvertTo-JiraIssueLinkType -InputObject $sampleObject
            } -Parameters @{ sampleObject = $sampleObject }
        }

        It "can convert to IssueLinkType object" {
            $issueLinkType | Should -HaveCount 1
        }

        It "returns an object of type [AtlassianPS.JiraPS.IssueLinkType]" {
            $issueLinkType | Should -BeOfType [AtlassianPS.JiraPS.IssueLinkType]
        }

        It 'converts nested types' { }
    }

    Describe "Return the expected format" {
        BeforeEach {
            $issueLinkType = InModuleScope JiraPS {
                param($sampleObject)
                ConvertTo-JiraIssueLinkType -InputObject $sampleObject
            } -Parameters @{ sampleObject = $sampleObject }
        }

        It "has a property '<property>' with value '<value>' of type '<type>'" -ForEach @(
            @{ property = 'id'; value = '10000' }
            @{ property = 'name'; value = 'Blocks' }
            @{ property = 'InwardText'; value = 'is blocked by' }
            @{ property = 'OutwardText'; value = 'blocks' }
        ) {
            $issueLinkType.PSObject.Properties.Name | Should -Contain $property
            if ($value) {
                $issueLinkType.$property | Should -Be $value
            }
            if ($type) {
                , ($issueLinkType.$property) | Should -BeOfType $type
            }
        }

        It "prints nicely to string" {
            $issueLinkType.ToString() | Should -Be 'Blocks'
        }
    }
}
