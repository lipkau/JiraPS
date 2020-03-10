#requires -modules BuildHelpers
#requires -modules @{ ModuleName = "Pester"; ModuleVersion = "4.10.1" }

Describe "Get-JiraConfigServer" -Tag 'Unit' {

    BeforeAll {
        Import-Module "$PSScriptRoot/../../../Tools/TestTools.psm1" -force
        Invoke-InitTest $PSScriptRoot

        Import-Module $env:BHManifestToTest -Force
    }
    AfterAll {
        Invoke-TestCleanup
    }

    InModuleScope JiraPS {

        . "$PSScriptRoot/../Shared.ps1"

        $jiraServer = 'http://jiraserver.example.com'

        It "returns the server stored in the module's session" {
            $script:JiraServerUrl = $jiraServer

            Get-JiraConfigServer | Should -Be $jiraServer
        }
    }
}
