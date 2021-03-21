#requires -modules @{ ModuleName = "Pester"; ModuleVersion = "5.0" }

Describe "General project validation" -Tag Unit {

    BeforeAll {
        Import-Module "$PSScriptRoot/../Tools/TestTools.psm1" -force
        Invoke-InitTest $PSScriptRoot

        Import-Module "$PSScriptRoot/../JiraPS" -Force

        $module = Get-Module JiraPS
        $manifestFile = "$($module.ModuleBase)/JiraPS.psd1"
    }
    AfterAll {
        Invoke-TestCleanup
    }

    It "passes Test-ModuleManifest" {
        Test-ModuleManifest -Path $manifestFile -ErrorAction Stop
    }

    It "module 'JiraPS' can import cleanly" {
        Import-Module $manifestFile -Force
    }

    It "module 'JiraPS' exports functions" {
        Import-Module $manifestFile -Force

        (Get-Command -Module JiraPS | Measure-Object).Count | Should -BeGreaterThan 0
    }

    It "module uses the correct root module" {
        Get-Metadata -Path $manifestFile -PropertyName RootModule | Should -Be 'JiraPS.psm1'
    }

    It "module uses the correct guid" {
        Get-Metadata -Path $manifestFile -PropertyName Guid | Should -Be '4bf3eb15-037e-43b7-9e47-20a30436324f'
    }

    It "module uses a valid version" {
        [Version](Get-Metadata -Path $manifestFile -PropertyName ModuleVersion) | Should -Not -BeNullOrEmpty
        [Version](Get-Metadata -Path $manifestFile -PropertyName ModuleVersion) | Should -BeOfType [Version]
    }

    # It "module uses the previous server config when loaded" {
    #     Set-Content -Value "https://example.com" -Path $serverConfig -Force

    #     Import-Module $manifestFile -Force

    #     Get-JiraConfigServer | Should -Be "https://example.com"
    # }

    # It "module is imported with default prefix" {
    #     $prefix = Get-Metadata -Path $manifestFile -PropertyName DefaultCommandPrefix

    #     Import-Module $manifestFile -Force -ErrorAction Stop
    #     (Get-Command -Module JiraPS).Name | ForEach-Object {
    #         $_ | Should -Match "\-$prefix"
    #     }
    # }

    # It "module is imported with custom prefix" {
    #     $prefix = "Wiki"

    #     Import-Module $manifestFile -Force -Prefix $prefix -Force -ErrorAction Stop
    #     (Get-Command -Module JiraPS).Name | ForEach-Object {
    #         $_ | Should -Match "\-$prefix"
    #     }
    # }
}
