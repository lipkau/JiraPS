#requires -modules @{ ModuleName = "Pester"; ModuleVersion = "5.0" }

Describe "Set-JiraUser" -Tag 'Unit' {

    BeforeAll {
        Import-Module "$PSScriptRoot/../../Tools/TestTools.psm1" -Force
        Invoke-InitTest $PSScriptRoot

        Import-Module "$PSScriptRoot/../../JiraPS" -Force

        #Sample response from the server
        $userResponse = @{
            "RestUrl"      = "http://jiraserver.example.com/rest/api/2/user?username=testUser"
            "key"          = "testUsername"
            "name"         = "testUsername"
            "displayName"  = "testDisplayName"
            "emailAddress" = "test@email.com"
            "active"       = $true
        }

        #region Mocking
        Invoke-CommonMocking

        Mock Get-JiraUser {
            [AtlassianPS.JiraPS.User]@{
                "restUrl" = "http://jiraserver.example.com/rest/api/2/user?username=testUser"
            }
        }

        Mock Invoke-JiraMethod -ParameterFilter {
            $Method -eq 'Put' -and
            $URI -like "*/user?username=testUser"
        } {
            Write-MockInfo 'Invoke-JiraMethod' @{ Method = $Method; Uri = $Uri; Body = $Body }
            [PSCustomObject]$userResponse
        }
        #endregion Mocking

        $user = Get-JiraUser -UserName "testUser" -ErrorAction Stop
    }
    AfterAll {
        Invoke-TestCleanup
    }

    Describe "Behavior checking" {
        It "Changes a User" {
            Set-JiraUser -User "testUser" -DisplayName "newName" -ErrorAction Stop

            Assert-MockCalled -CommandName Invoke-JiraMethod -Exactly -Times 1 -Scope It -ParameterFilter {
                $Method -eq 'Put' -and
                $OutputType -eq "JiraUser"
            }
        }

        It "Changes a User using the pipeline" {
            $user | Set-JiraUser -DisplayName "newName" -ErrorAction Stop

            Assert-MockCalled -CommandName Invoke-JiraMethod -Exactly -Times 1 -Scope It -ParameterFilter { $Method -eq 'Put' }
        }

        It "fetches the user if an incomplete object was provided" {
            Set-JiraUser -User "testUser" -DisplayName "NewName" -ErrorAction Stop

            Assert-MockCalled -CommandName Get-JiraUser -Exactly -Times 1 -Scope It
        }

        It "uses the provided user when a complete object was provided" {
            $user | Set-JiraUser -DisplayName "NewName" -ErrorAction Stop

            Assert-MockCalled -CommandName Get-JiraUser -Exactly -Times 0 -Scope It
        }

        It "can change an User with a Hashtable" {
            Set-JiraUser -User $user -Property @{ invalidProperty = "value" } -ErrorAction Stop

            Assert-MockCalled -CommandName Invoke-JiraMethod -Exactly -Times 1 -Scope It -ParameterFilter { $Body -like '*invalidProperty*' }
        }

        It "returns an User when using PassThru" {
            $r1 = Set-JiraUser -User $user -DisplayName "newName" -ErrorAction Stop
            $r2 = Set-JiraUser -User $user -DisplayName "newName" -ErrorAction Stop -PassThru

            $r1 | Should -BeNullOrEmpty
            $r2 | Should -Not -BeNullOrEmpty
        }

        It "validates the Email Address input" {
            { Set-JiraUser -User $user -EmailAddress "invalidEmail" -ErrorAction Stop } | Should -Throw -ExpectedMessage "Invalid Argument"
        }

        It "does not call the api when no parameters are changed" {
            Set-JiraUser -User $user -ErrorAction Stop

            Assert-MockCalled -CommandName Invoke-JiraMethod -Exactly -Times 0 -Scope It
        }
    }

    Describe "Input testing" {
        It "Can change the display name of an User" {
            Set-JiraUser -User $user -DisplayName "newName" -ErrorAction Stop
        }

        It "Can change the email address of an User" {
            Set-JiraUser -User $user -EmailAddress "new@email.com" -ErrorAction Stop
        }

        It "Can change the active status of an User" {
            Set-JiraUser -User $user -Active $true -ErrorAction Stop
            Set-JiraUser -User $user -Active $false -ErrorAction Stop
        }

        It "Can change an User with a property map" {
            Set-JiraUser -User $user -Property @{ active = $true } -ErrorAction Stop
        }
    }
}
