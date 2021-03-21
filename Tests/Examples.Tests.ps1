#requires -modules @{ ModuleName = "Pester"; ModuleVersion = "5.0" }

Describe "Validation of example codes in the documentation" -Tag Documentation, NotImplemented {

    BeforeAll {
        Import-Module "$PSScriptRoot/../Tools/TestTools.psm1" -force
        Invoke-InitTest $PSScriptRoot

        Import-Module "$PSScriptRoot/../JiraPS" -Force
    }
    AfterAll {
        Invoke-TestCleanup
    }

    <# $functions = Get-Command -Module JiraPS | Get-Help
    foreach ($function in $functions) {
        Describe "Examples of $($function.Name)" {

            # TODO: execute the script in example blocks of the documentation

        }
    } #>
}
