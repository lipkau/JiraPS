#requires -modules @{ ModuleName = "Pester"; ModuleVersion = "5.0" }

Describe "Remove-JiraSession" -Tag 'Unit' {

    BeforeAll {
        Import-Module "$PSScriptRoot/../../Tools/TestTools.psm1" -Force
        Invoke-InitTest $PSScriptRoot

        Import-Module "$PSScriptRoot/../../JiraPS" -Force
    }
    AfterAll {
        Invoke-TestCleanup
    }

    #region Mocks
    Mock Get-JiraSession -ModuleName JiraPS {
        (Get-Module JiraPS).PrivateData.Session
    }
    #endregion Mocks

    Describe "Sanity checking" {
        $command = Get-Command -Name Remove-JiraSession

        It "has a parameter 'Session' of type [Object]" {
            $command | Should -HaveParameter "Session" -Type [Object]
        }
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
