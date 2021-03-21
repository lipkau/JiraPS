#requires -modules @{ ModuleName = "Pester"; ModuleVersion = "5.0" }

Describe "General project validation" -Tag Unit {

    BeforeAll {
        Import-Module "$PSScriptRoot/../Tools/TestTools.psm1" -force
        Invoke-InitTest $PSScriptRoot

        Import-Module "$PSScriptRoot/../JiraPS" -Force

        $module = Get-Module JiraPS
        $testFiles = Get-ChildItem "$PSScriptRoot/*.Tests.ps1" -Recurse
    }
    AfterAll {
        Invoke-TestCleanup
    }

    Describe "Public function: <basename>" -ForEach (Get-ChildItem "$env:BHModulePath/Public/*.ps1" | Foreach-Object {
            @{ BaseName = $_.BaseName }
        }) {
        # TODO
        It "has a test file" {
            $BaseName = $BaseName -replace "\-", "-$($module.Prefix)"
            $expectedTestFile = "$BaseName.Unit.Tests.ps1"

            $testFiles.Name | Should -Contain $expectedTestFile
        }

        It "is exported" {
            $expectedFunctionName = $BaseName -replace "\-", "-$($module.Prefix)"

            $module.ExportedCommands.keys | Should -Contain $expectedFunctionName
        }
    }

    Describe "Private function: <basename>"  -ForEach (Get-ChildItem "$env:BHModulePath/Private/*.ps1" | Foreach-Object {
            @{ BaseName = $_.BaseName }
        }) {
        # TODO
        # It "has a test file for $function" {
        #     $expectedTestFile = "$BaseName.Unit.Tests.ps1"

        #     $testFiles.Name | Should -Contain $expectedTestFile
        # }

        It "is not exported $BaseName" {
            $expectedFunctionName = $BaseName -replace "\-", "-$($module.Prefix)"

            $module.ExportedCommands.keys | Should -Not -Contain $expectedFunctionName
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
        It "has all the public functions as a file in 'JiraPS/Public'" {
            foreach ($function in $module.ExportedFunctions.Keys) {
                # $function = $function.Replace($module.Prefix, '')

                (Get-ChildItem "$env:BHModulePath/Public").BaseName | Should -Contain $function
            }
        }
    }
}
