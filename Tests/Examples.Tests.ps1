#requires -modules BuildHelpers
#requires -modules Pester

Describe "Validation of example codes in the documentation" -Tag Documentation, NotImplemented {

    BeforeAll {
        Import-Module "$PSScriptRoot/../../Tools/TestTools.psm1" -force
        Invoke-InitTest $PSScriptRoot

        Import-Module $env:BHManifestToTest -Force
    }
    AfterAll {
        Invoke-TestCleanup
    }

    Assert-True $script:isBuild "Examples can only be tested in the build environment. Please run `Invoke-Build -Task Build`."

    $functions = Get-Command -Module $env:BHProjectName | Get-Help
    foreach ($function in $functions) {
        Context "Examples of $($function.Name)" {


        }
    }
}
