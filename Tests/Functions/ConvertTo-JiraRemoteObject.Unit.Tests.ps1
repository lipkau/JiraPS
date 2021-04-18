#requires -modules @{ ModuleName = "Pester"; ModuleVersion = "5.0" }

Import-Module "$PSScriptRoot/../../JiraPS" -Force
Import-Module "$PSScriptRoot/../../Tools/TestTools.psm1" -Force

Describe "ConvertTo-JiraRemoteObject" -Tag 'Unit' {
    BeforeAll {
        $sampleObject = ConvertFrom-Json -InputObject @"
{
    "url": "http://www.mycompany.com/support?id=1",
    "title": "TSTSUP-111",
    "summary": "Crazy customer support issue"
}
"@
    }

    Describe "Instanciating an object" {
        It "Creates a new instance via typed input" { }

        It "Creates a new instance via hashtable" {
            [AtlassianPS.JiraPS.RemoteObject]@{
                url     = "http://www.mycompany.com/support?id=1"
                title   = "TSTSUP-111"
                summary = "Crazy customer support issue"
            } | Should -BeOfType [AtlassianPS.JiraPS.RemoteObject]
        }
    }

    Describe "Conversion of InputObject" {
        BeforeAll {
            $remoteObject = InModuleScope JiraPS {
                param($sampleObject)
                ConvertTo-JiraRemoteObject -InputObject $sampleObject
            } -Parameters @{ sampleObject = $sampleObject }
        }

        It "can convert to Project object" {
            $remoteObject | Should -HaveCount 1
        }

        It "returns an object of type [AtlassianPS.JiraPS.RemoteObject]" {
            $remoteObject | Should -BeOfType [AtlassianPS.JiraPS.RemoteObject]
        }

        It 'converts nested types' { }
    }

    Describe "Return the expected format" {
        BeforeEach {
            $remoteObject = InModuleScope JiraPS {
                param($sampleObject)
                ConvertTo-JiraRemoteObject -InputObject $sampleObject
            } -Parameters @{ sampleObject = $sampleObject }
        }

        It "has a property '<property>' with value '<value>' of type '<type>'" -ForEach @(
            @{ property = 'Url'; value = 'http://www.mycompany.com/support?id=1' }
            @{ property = 'Title'; value = 'TSTSUP-111' }
            @{ property = 'Summary'; value = 'Crazy customer support issue' }
            @{ property = 'Icon'; }
            @{ property = 'Status'; }
        ) {
            $remoteObject.PSObject.Properties.Name | Should -Contain $property
            if ($value) {
                $remoteObject.$property | Should -Be $value
            }
            if ($type) {
                , ($remoteObject.$property) | Should -BeOfType $type
            }
        }

        It "prints nicely to string" { }
    }
}
