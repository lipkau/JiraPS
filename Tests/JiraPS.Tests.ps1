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

    It "passes Test-ModuleManifest" {
        { Test-ModuleManifest -Path $env:BHManifestToTest -ErrorAction Stop } | Should -Not -Throw
    }

    It "module '$env:BHProjectName' can import cleanly" {
        { Import-Module $env:BHManifestToTest -Force } | Should Not Throw
    }

    It "module '$env:BHProjectName' exports functions" {
        Import-Module $env:BHManifestToTest -Force

        (Get-Command -Module $env:BHProjectName | Measure-Object).Count | Should -BeGreaterThan 0
    }

    It "module uses the correct root module" {
        Get-Metadata -Path $env:BHManifestToTest -PropertyName RootModule | Should -Be 'JiraPS.psm1'
    }

    It "module uses the correct guid" {
        Get-Metadata -Path $env:BHManifestToTest -PropertyName Guid | Should -Be '4bf3eb15-037e-43b7-9e47-20a30436324f'
    }

    It "module uses a valid version" {
        [Version](Get-Metadata -Path $env:BHManifestToTest -PropertyName ModuleVersion) | Should -Not -BeNullOrEmpty
        [Version](Get-Metadata -Path $env:BHManifestToTest -PropertyName ModuleVersion) | Should -BeOfType [Version]
    }

    It "module uses the previous server config when loaded" {
        Set-Content -Value "https://example.com" -Path $configFile -Force

        Import-Module $env:BHManifestToTest -Force

        Get-JiraConfigServer | Should -Be "https://example.com"
    }

    # It "module is imported with default prefix" {
    #     $prefix = Get-Metadata -Path $env:BHManifestToTest -PropertyName DefaultCommandPrefix

    #     Import-Module $env:BHManifestToTest -Force -ErrorAction Stop
    #     (Get-Command -Module $env:BHProjectName).Name | ForEach-Object {
    #         $_ | Should -Match "\-$prefix"
    #     }
    # }

    # It "module is imported with custom prefix" {
    #     $prefix = "Wiki"

    #     Import-Module $env:BHManifestToTest -Force -Prefix $prefix -Force -ErrorAction Stop
    #     (Get-Command -Module $env:BHProjectName).Name | ForEach-Object {
    #         $_ | Should -Match "\-$prefix"
    #     }
    # }
}
