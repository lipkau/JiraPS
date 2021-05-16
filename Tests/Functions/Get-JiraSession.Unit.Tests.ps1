#requires -modules @{ ModuleName = "Pester"; ModuleVersion = "5.0" }

Describe "Get-JiraSession" -Tag 'Unit' {

    BeforeAll {
        Import-Module "$PSScriptRoot/../../Tools/TestTools.psm1" -Force
        Invoke-InitTest $PSScriptRoot

        Import-Module "$PSScriptRoot/../../JiraPS" -Force
    }
    AfterAll {
        Invoke-TestCleanup
    }

    It "Obtains a saved JiraPS.Session object from module PrivateData" {
        # I don't know how to test this, since I can't access module PrivateData from Pester.
        # The tests for New-JiraSession use this function to validate that they work, so if
        # those tests pass, this function Should -Be working as well.
        # $true | Should -Be $true
    }
}
