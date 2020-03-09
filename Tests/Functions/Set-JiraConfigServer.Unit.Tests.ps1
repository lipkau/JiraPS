#requires -modules BuildHelpers
#requires -modules @{ ModuleName = "Pester"; ModuleVersion = "4.10.1" }

Describe "Set-JiraConfigServer" -Tag 'Unit' {

    BeforeAll {
        Import-Module "$PSScriptRoot/../../Tools/TestTools.psm1" -force
        Invoke-InitTest $PSScriptRoot

        Import-Module $env:BHManifestToTest -force
    }
    AfterAll {
        Invoke-TestCleanup
    }

    InModuleScope JiraPS {

        . "$PSScriptRoot/../Shared.ps1"

        $jiraServer = 'http://jiraserver.example.com'

        It "stores the server address in the module session" {
            Set-JiraConfigServer -Server $jiraServer

            $script:JiraServerUrl | Should -Be "$jiraServer/"
        }

        It "stores the server address in a config file" {
            $script:serverConfig | Should -Exist

            Get-Content $script:serverConfig | Should -Be "$jiraServer/"
        }
    }
}
