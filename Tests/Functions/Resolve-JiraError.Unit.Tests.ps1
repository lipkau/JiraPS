#requires -modules BuildHelpers
#requires -modules @{ ModuleName = "Pester"; ModuleVersion = "4.10.1" }

Describe "Resolve-JiraError" -Tag 'Unit' {

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

        $testErrorKey = 'error'
        $testError = 'This is an error message.'

        $testJson = @"
{
    "errorMessages": [],
    "errors":
    {
        "$testErrorKey":"$testError"
    }
}
"@
        $testErrorMessage = "Jira encountered an error: [$testErrorKey] - $testError"

        It "Converts a JIRA result into a PSObject with error results" {
            $obj = Resolve-JiraError -InputObject (ConvertFrom-Json $testJson)
            $obj | Should Not BeNullOrEmpty
            $obj.Key | Should Be $testErrorKey
            $obj.Message | Should Be $testError
        }

        It "Writes output to the Error stream if the -WriteError parameter is passed" {
            $obj = Resolve-JiraError -InputObject (ConvertFrom-Json $testJson) -WriteError -ErrorAction SilentlyContinue -ErrorVariable errOutput
            $errOutput | Should Be $testErrorMessage
        }

        It "Does not write a PSObject if the -WriteError parameter is passed" {
            $obj = Resolve-JiraError -InputObject (ConvertFrom-Json $testJson) -WriteError -ErrorAction SilentlyContinue -ErrorVariable errOutput
            $obj | Should BeNullOrEmpty
        }
    }
}
