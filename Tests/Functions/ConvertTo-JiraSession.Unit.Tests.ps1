#requires -modules @{ ModuleName = "Pester"; ModuleVersion = "5.0" }

Import-Module "$PSScriptRoot/../../JiraPS" -Force
Import-Module "$PSScriptRoot/../../Tools/TestTools.psm1" -Force

Describe "ConvertTo-JiraSession" -Tag 'Unit' {
    BeforeAll {
        $mockedSession = New-Object -TypeName Microsoft.PowerShell.Commands.WebRequestSession
    }

    Describe "Instanciating an object" {
        It "Creates a new instance via typed input" { }

        It "Creates a new instance via hashtable" {
            [AtlassianPS.JiraPS.Session]@{
                WebSession = $mockedSession
                Username   = 'user'
            } | Should -BeOfType [AtlassianPS.JiraPS.Session]
        }
    }

    Describe "Conversion of InputObject" {
        BeforeAll {
            $session = InModuleScope JiraPS {
                param($mockedSession, $Username)
                ConvertTo-JiraSession -Session $mockedSession -Username $Username
            } -Parameters @{ mockedSession = $mockedSession; Username = 'Admin' }
        }
        
        It "can convert to Session object" {
            $session | Should -HaveCount 1
        }

        It "returns an object of type [AtlassianPS.JiraPS.Session]" {
            $session | Should -BeOfType [AtlassianPS.JiraPS.Session]
        }

        It 'converts nested types' { }
    }

    Describe "Return the expected format" {
        BeforeEach {
            $session = InModuleScope JiraPS {
                param($mockedSession, $Username)
                ConvertTo-JiraSession -Session $mockedSession -Username $Username
            } -Parameters @{ mockedSession = $mockedSession; Username = 'Admin' }
        }

        It "has a property '<property>' with value '<value>' of type '<type>'" -ForEach @(
            @{ property = 'WebSession'; type = 'Microsoft.PowerShell.Commands.WebRequestSession' }
            @{ property = 'Username'; value = 'Admin' }
        ) {
            $session.PSObject.Properties.Name | Should -Contain $property
            if ($value) {
                $session.$property | Should -Be $value
            }
            if ($type) {
                , ($session.$property) | Should -BeOfType $type
            }
        }

        It "prints nicely to string" { }
    }
}
