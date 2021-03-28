#requires -modules @{ ModuleName = "Pester"; ModuleVersion = "5.0" }

Import-Module "$PSScriptRoot/../../JiraPS" -Force
Import-Module "$PSScriptRoot/../../Tools/TestTools.psm1" -Force

Describe "Set-JiraConfigServer" -Tag 'Unit' {
    Describe 'Behavior checking' {
        BeforeAll {
            InModuleScope JiraPS { $script:serverConfig = "TestDrive:\jira.config" }
        }

        It "stores the server address in the module session" {
            Set-JiraConfigServer -Server 'http://jiraserver.example.com'

            InModuleScope JiraPS { $script:JiraServerUrl } | Should -Be "http://jiraserver.example.com/"
        }

        It "stores the server address in a config file" {
            Set-JiraConfigServer -Server 'http://jiraserver.example2.com'

            Get-Content TestDrive:\jira.config | Should -Be "http://jiraserver.example2.com/"
        }
    }
}
