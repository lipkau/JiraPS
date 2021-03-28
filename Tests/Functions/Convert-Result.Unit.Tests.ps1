#requires -modules @{ ModuleName = "Pester"; ModuleVersion = "5.0" }

Import-Module "$PSScriptRoot/../../JiraPS" -Force
Import-Module "$PSScriptRoot/../../Tools/TestTools.psm1" -Force

Describe 'Convert-Result' -Tag 'Unit' {
    BeforeAll {
        Add-MockConvertToJiraUser
    }

    Describe 'Behavior checking' {
        It 'uses private function for converting the object' {
            InModuleScope JiraPS { Convert-Result -InputObject @{ name = 'Anthony van Dyck' } -OutputType 'JiraUser' }

            Assert-MockCalled -CommandName 'ConvertTo-JiraUser' -ModuleName 'JiraPS' -Scope 'It' -Exactly -Times 1
        }

        It 'returns the input object if the necessary private function is missing' {
            InModuleScope JiraPS { Convert-Result -InputObject @{ name = 'Anthony van Dyck' } -OutputType 'InvalidType' }

            Assert-MockCalled -CommandName 'ConvertTo-JiraUser' -ModuleName 'JiraPS' -Scope 'It' -Exactly -Times 0
        }

        It 'returns the input object if no conversion is expected' {
            InModuleScope JiraPS { Convert-Result -InputObject @{ name = 'Anthony van Dyck' } }

            Assert-MockCalled -CommandName 'ConvertTo-JiraUser' -ModuleName 'JiraPS' -Scope 'It' -Exactly -Times 0
        }
    }
}
