#requires -modules @{ ModuleName = "Pester"; ModuleVersion = "5.0" }

Import-Module "$PSScriptRoot/../../JiraPS" -Force
Import-Module "$PSScriptRoot/../../Tools/TestTools.psm1" -Force

Describe "ConvertTo-JiraAvatar" -Tag 'Unit' {
    BeforeAll {
        $sampleObject = ConvertFrom-Json -InputObject @"
{
    "48x48": "http://jiraserver.example.com/secure/useravatar?avatarId=10202",
    "24x24": "http://jiraserver.example.com/secure/useravatar?size=small&avatarId=10202",
    "16x16": "http://jiraserver.example.com/secure/useravatar?size=xsmall&avatarId=10202",
    "32x32": "http://jiraserver.example.com/secure/useravatar?size=medium&avatarId=10202"
}
"@
    }

    Describe "Instanciating an object" {
        It "Creates a new instance via typed input" { }

        It "Creates a new instance via hashtable" {
            [AtlassianPS.JiraPS.Avatar]@{
                "x32" = "http://jiraserver.example.com/secure/useravatar?size=medium&avatarId=10202"
            } | Should -BeOfType [AtlassianPS.JiraPS.Avatar]
        }
    }

    Describe "Conversion of InputObject" {
        BeforeAll {
            $avatar = InModuleScope JiraPS {
                param($sampleObject)
                ConvertTo-JiraAvatar -InputObject $sampleObject
            } -Parameters @{ sampleObject = $sampleObject }
        }

        It "can convert to Avatar object" {
            $avatar | Should -HaveCount 1
        }

        It "returns an object of type [AtlassianPS.JiraPS.Avatar]" {
            $avatar | Should -BeOfType [AtlassianPS.JiraPS.Avatar]
        }

        It 'converts nested types' {}
    }

    Describe "Return the expected format" {
        BeforeEach {
            $avatar = InModuleScope JiraPS {
                param($sampleObject)
                ConvertTo-JiraAvatar -InputObject $sampleObject
            } -Parameters @{ sampleObject = $sampleObject }
        }

        It "has a property '<property>' with value '<value>' of type '<type>'" -ForEach @(
            @{ property = 'x48'; value = 'http://jiraserver.example.com/secure/useravatar?avatarId=10202' }
            @{ property = 'x24'; value = 'http://jiraserver.example.com/secure/useravatar?size=small&avatarId=10202' }
            @{ property = 'x16'; value = 'http://jiraserver.example.com/secure/useravatar?size=xsmall&avatarId=10202' }
            @{ property = 'x32'; value = 'http://jiraserver.example.com/secure/useravatar?size=medium&avatarId=10202' }
        ) {
            $avatar.PSObject.Properties.Name | Should -Contain $property
            if ($value) {
                $avatar.$property | Should -Be $value
            }
            if ($type) {
                , ($avatar.$property) | Should -BeOfType $type
            }
        }

        It "prints nicely to string" { }
    }
}
