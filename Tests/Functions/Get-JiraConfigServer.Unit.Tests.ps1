#requires -modules @{ ModuleName = "Pester"; ModuleVersion = "5.0" }

Import-Module "$PSScriptRoot/../../JiraPS" -Force
Import-Module "$PSScriptRoot/../../Tools/TestTools.psm1" -Force

Describe "Get-JiraConfigServer" -Tag 'Unit' {
    Describe 'Behavior checking' {
        It "returns the server stored in the module's session" {
            InModuleScope JiraPS { $script:JiraServerUrl = 'http://jiraserver.example.com' }

            Get-JiraConfigServer | Should -Be 'http://jiraserver.example.com'
        }

        It 'Removes the trailing /' {
            InModuleScope JiraPS { $script:JiraServerUrl = 'http://jiraserver.example.com/' }

            Get-JiraConfigServer | Should -Be 'http://jiraserver.example.com'
        }
    }
}
