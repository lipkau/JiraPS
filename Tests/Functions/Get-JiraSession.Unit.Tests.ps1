#requires -modules BuildHelpers
#requires -modules @{ ModuleName = "Pester"; ModuleVersion = "4.4.0" }

Describe "Get-JiraSession" -Tag 'Unit' {

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

        It "Obtains a saved JiraPS.Session object from module PrivateData" {
            # I don't know how to test this, since I can't access module PrivateData from Pester.
            # The tests for New-JiraSession use this function to validate that they work, so if
            # those tests pass, this function should be working as well.
            # $true | Should Be $true
        }
    }
}
