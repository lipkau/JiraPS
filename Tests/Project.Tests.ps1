#requires -modules BuildHelpers
#requires -modules Pester

Describe "General project validation" -Tag Unit {

    BeforeAll {
        Import-Module "$PSScriptRoot/../../Tools/TestTools.psm1" -force
        Invoke-InitTest $PSScriptRoot

        Import-Module $env:BHManifestToTest -Force
    }
    AfterAll {
        Invoke-TestCleanup
    }

    $module = Get-Module $env:BHProjectName
    $testFiles = Get-ChildItem $PSScriptRoot -Include "*.Tests.ps1" -Recurse

    Describe "Public functions" {
        $publicFunctions = (Get-ChildItem "$env:BHModulePath/Public/*.ps1").BaseName

        foreach ($function in $publicFunctions) {

            # TODO
            It "has a test file for $function" {
                $expectedTestFile = "$function.Unit.Tests.ps1"

                $testFiles.Name | Should -Contain $expectedTestFile
            }

            It "exports $function" {
                $expectedFunctionName = $function -replace "\-", "-$($module.Prefix)"

                $module.ExportedCommands.keys | Should -Contain $expectedFunctionName
            }
        }
    }

    Describe "Private functions" {
        $privateFunctions = (Get-ChildItem "$env:BHModulePath/Private/*.ps1").BaseName

        foreach ($function in $privateFunctions) {

            # TODO
            # It "has a test file for $function" {
            #     $expectedTestFile = "$function.Unit.Tests.ps1"

            #     $testFiles.Name | Should -Contain $expectedTestFile
            # }

            It "does not export $function" {
                $expectedFunctionName = $function -replace "\-", "-$($module.Prefix)"

                $module.ExportedCommands.keys | Should -Not -Contain $expectedFunctionName
            }
        }
    }

    <#
    Describe "Classes" {

        foreach ($class in ([AtlassianPS.ServerData].Assembly.GetTypes() | Where-Object IsClass)) {
            It "has a test file for $class" {
                $expectedTestFile = "$class.Unit.Tests.ps1"
                $testFiles.Name | Should -Contain $expectedTestFile
            }
        }
    }

    Describe "Enumeration" {

        foreach ($enum in ([AtlassianPS.ServerData].Assembly.GetTypes() | Where-Object IsEnum)) {
            It "has a test file for $enum" {
                $expectedTestFile = "$enum.Unit.Tests.ps1"
                $testFiles.Name | Should -Contain $expectedTestFile
            }
        }
    }
#>

    Describe "Project stucture" {
        $publicFunctions = (Get-Module -Name $env:BHProjectName).ExportedFunctions.Keys

        It "has all the public functions as a file in '$env:BHProjectName/Public'" {
            foreach ($function in $publicFunctions) {
                # $function = $function.Replace((Get-Module -Name $env:BHProjectName).Prefix, '')

                (Get-ChildItem "$env:BHModulePath/Public").BaseName | Should -Contain $function
            }
        }
    }
}
