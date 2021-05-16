#requires -modules @{ ModuleName = "Pester"; ModuleVersion = "5.0" }

Import-Module "$PSScriptRoot/../../JiraPS" -Force
Import-Module "$PSScriptRoot/../../Tools/TestTools.psm1" -Force

Describe 'Add-JiraGroupMember' -Tag 'Unit' {
    BeforeAll {
        #region Mocks
        Add-CommonMocks

        Add-MockGetJiraConfigServer

        Mock Invoke-JiraMethod -ParameterFilter {
            $Method -eq 'Post' -and
            $URI -like '*/group/user*'
        } {
            Write-MockInfo 'Invoke-JiraMethod' @{ Method = $Method; Uri = $Uri; Body = $Body }
            return $true
        }
        #endregion Mocks
    }

    Describe 'Behavior testing' {
        It 'Adds users to groups' {
            Add-JiraGroupMember -Group 'TheCoolGuys' -User 'jon.doe', 'evel.knievel' -ErrorAction Stop

            $assertMockCalledSplat = @{
                CommandName     = 'Invoke-JiraMethod'
                Exactly         = $true
                Times           = 2
                Scope           = 'It'
                ParameterFilter = { $GetParameter['groupname'] -eq 'TheCoolGuys' }
            }
            Assert-MockCalled @assertMockCalledSplat
        }
    }

    Describe 'Input testing' {
        BeforeAll {
            Mock Get-JiraGroup {
                foreach ($_name in $Name) { [AtlassianPS.JiraPS.Group] $_name }
            }
            Mock Get-JiraUser {
                foreach ($_user in $Username) { [AtlassianPS.JiraPS.User] $_user }
            }
        }

        It 'Accepts multipe user as input' {
            Add-JiraGroupMember -Group 'Drivers' -User 'Max.Verstappen', 'Lewis Hamilton' -ErrorAction Stop

            $assertMockCalledSplat = @{
                CommandName = 'Invoke-JiraMethod'
                Exactly     = $true
                Times       = 2
                Scope       = 'It'
            }
            Assert-MockCalled @assertMockCalledSplat
        }

        It 'Accepts user via pipeline' {
            'Max.Verstappen', 'Lewis Hamilton' | Add-JiraGroupMember -Group 'Drivers' -ErrorAction Stop
        }

        It 'Accepts user objects' {
            $user = Get-JiraUser 'Max.Verstappen'

            Add-JiraGroupMember -Group 'Drivers' -User $user -ErrorAction Stop
        }

        It 'Accepts group objects' {
            $group = Get-JiraGroup 'Drivers'

            Add-JiraGroupMember -Group $group -User 'Lewis Hamilton' -ErrorAction Stop
        }
    }
}
