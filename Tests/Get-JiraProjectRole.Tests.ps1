Describe 'Get-JiraProjectRole' {
    BeforeAll {
        Remove-Module JiraPS -ErrorAction SilentlyContinue
        Import-Module "$PSScriptRoot/../JiraPS" -Force -ErrorAction Stop
    }

    InModuleScope JiraPS {

        . "$PSScriptRoot/Shared.ps1"

        #region Definitions
        $jiraServer = "https://jira.example.com"
        #endregion Definitions

        #region Mocks
        Mock Get-JiraConfigServer -ModuleName JiraPS {
            $jiraServer
        }

        Mock Invoke-JiraMethod -ModuleName JiraPS {
            ShowMockInfo 'Invoke-JiraMethod' 'Method', 'Uri'
            throw "Unidentified call to Invoke-JiraMethod"
        }
        #endregion Mocks

        Context "Sanity checking" {
            $command = Get-Command -Name Get-JiraProjectRole
        }

        Context "Behavior testing" {
        }

        Context "Input testing" {
        }
    }
}
