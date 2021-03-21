#requires -modules BuildHelpers
#requires -modules @{ ModuleName = "Pester"; ModuleVersion = "4.10.1" }

Describe "Remove-JiraSession" -Tag 'Unit' {

    BeforeAll {
        Import-Module "$PSScriptRoot/../../../Tools/TestTools.psm1" -force
        Invoke-InitTest $PSScriptRoot

        Import-Module $env:BHManifestToTest -Force
    }
    AfterAll {
        Invoke-TestCleanup
    }

    . "$PSScriptRoot/../Shared.ps1"

    #region Mocks
    Mock Get-JiraSession -ModuleName JiraPS {
        (Get-Module JiraPS).PrivateData.Session
    }
    #endregion Mocks

    Describe "Sanity checking" {
        $command = Get-Command -Name Remove-JiraSession

        defParam $command 'Session'
    }

    Describe "Behavior testing" {
        It "Closes a removes the JiraPS.Session data from module PrivateData" {
            (Get-Module JiraPS).PrivateData = @{ Session = $true }
            (Get-Module JiraPS).PrivateData.Session | Should -Not -BeNullOrEmpty

            Remove-JiraSession

            (Get-Module JiraPS).PrivateData.Session | Should -BeNullOrEmpty
        }
    }
}