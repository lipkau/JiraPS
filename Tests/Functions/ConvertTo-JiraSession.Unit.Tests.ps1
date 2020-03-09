#requires -modules BuildHelpers
#requires -modules @{ ModuleName = "Pester"; ModuleVersion = "4.10.1" }

Describe "ConvertTo-JiraSession" -Tag 'Unit' {

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

        $sampleUsername = 'powershell-test'
        $sampleSession = @{}

        $r = ConvertTo-JiraSession -Session $sampleSession -Username $sampleUsername

        It "Creates a PSObject out of Web request data" {
            $r | Should Not BeNullOrEmpty
        }

        checkPsType $r 'JiraPS.Session'
        defProp $r 'Username' $sampleUsername
    }
}
