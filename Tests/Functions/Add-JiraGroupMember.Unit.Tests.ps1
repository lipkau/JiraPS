#requires -modules BuildHelpers
#requires -modules @{ ModuleName = "Pester"; ModuleVersion = "4.10.1" }

Describe "Add-JiraGroupMember" -Tag 'Unit' {

    BeforeAll {
        Import-Module "$PSScriptRoot/../../Tools/TestTools.psm1" -force
        Invoke-InitTest $PSScriptRoot

        Import-Module $env:BHManifestToTest -force
    }
    AfterAll {
        Invoke-TestCleanup
    }

    InModuleScope JiraPS {

        . "$PSScriptRoot/../Shared.ps1"

        $jiraServer = 'http://jiraserver.example.com'

        # In most test cases, user 1 is a member of the group and user 2 is not
        $testGroupName = 'testGroup'
        $testUsername1 = 'testUsername1'
        $testUsername2 = 'testUsername2'

        Mock Get-JiraConfigServer -ModuleName JiraPS {
            Write-Output $jiraServer
        }

        Mock Get-JiraGroup -ModuleName JiraPS {
            $object = [PSCustomObject] @{
                'Name' = $testGroupName
                'Size' = 2
            }
            $object.PSObject.TypeNames.Insert(0, 'JiraPS.Group')
            return $object
        }

        Mock Get-JiraUser -ModuleName JiraPS {
            foreach ($user in $UserName) {
                $object = [PSCustomObject] @{
                    'Name' = "$user"
                }
                $object.PSObject.TypeNames.Insert(0, 'JiraPS.User')
                Write-Output $object
            }
        }

        Mock Get-JiraGroupMember -ModuleName JiraPS {
            @(
                [PSCustomObject] @{
                    'Name' = $testUsername1
                }
            )
        }

        Mock ConvertTo-JiraGroup -ModuleName JiraPS {
            $InputObject
        }

        Mock Invoke-JiraMethod -ModuleName JiraPS {
            ShowMockInfo 'Invoke-JiraMethod' 'Method', 'Uri', 'Body'
            return $true
        }

        #############
        # Tests
        #############
        Context "Sanity checking" {

            It "Accepts a group name as a String to the -Group parameter" {
                { Add-JiraGroupMember -Group $testGroupName -User $testUsername2 } | Should Not Throw
                { Add-JiraGroupMember -Group $testGroupName -User $testUsername2 -PassThru } | Should Not Throw
                Assert-MockCalled -CommandName Get-JiraGroup -Exactly -Times 2 -Scope It
                Assert-MockCalled -CommandName Get-JiraGroupMember -Exactly -Times 2 -Scope It
                Assert-MockCalled -CommandName Get-JiraUser -Exactly -Times 2 -Scope It
                Assert-MockCalled -CommandName Invoke-JiraMethod -ParameterFilter {$URI -match $testGroupName} -Exactly -Times 2 -Scope It
                Assert-MockCalled -CommandName ConvertTo-JiraGroup -Exactly -Times 1 -Scope It
            }

            It "Accepts a JiraPS.Group object to the -Group parameter" {
                $group = Get-JiraGroup -GroupName $testGroupName
                { Add-JiraGroupMember -Group $group -User $testUsername2 } | Should Not Throw
                Assert-MockCalled -CommandName Invoke-JiraMethod -ParameterFilter {$URI -match $testGroupName} -Exactly -Times 1 -Scope It
            }

            It "Accepts pipeline input from Get-JiraGroup" {
                { Get-JiraGroup -GroupName $testGroupName | Add-JiraGroupMember -User $testUsername2 } | Should Not Throw
                Assert-MockCalled -CommandName Invoke-JiraMethod -ParameterFilter {$URI -match $testGroupName} -Exactly -Times 1 -Scope It
            }
        }

        Context "Behavior testing" {

            It "Tests to see if a provided user is currently a member of the provided JIRA group before attempting to add them" {
                { Add-JiraGroupMember -Group $testGroupName -User $testUsername1 -ErrorAction Stop } | Should Throw
                Assert-MockCalled -CommandName Get-JiraGroupMember -Exactly -Times 1 -Scope It
            }

            It "Adds a user to a JIRA group if the user is not a member" {
                { Add-JiraGroupMember -Group $testGroupName -User $testUsername2 } | Should Not Throw
                Assert-MockCalled -CommandName Invoke-JiraMethod -ParameterFilter {$Method -eq 'POST' -and $URI -match $testGroupName -and $Body -match $testUsername2} -Exactly -Times 1 -Scope It
            }

            It "Adds multiple users to a JIRA group if they are passed to the -User parameter" {

                # Override our previous mock so we have no group members
                Mock Get-JiraGroupMember -ModuleName JiraPS { @() }

                # Should use the REST method twice, since at present, you can only add one group member per API call
                { Add-JiraGroupMember -Group $testGroupName -User $testUsername1, $testUsername2 } | Should Not Throw
                Assert-MockCalled -CommandName Invoke-JiraMethod -ParameterFilter {$Method -eq 'Post' -and $URI -match $testGroupName} -Exactly -Times 2 -Scope It
            }
        }

        Context "Error checking" {
            It "Gracefully handles cases where a provided user is already in the provided group" {
                { Add-JiraGroupMember -Group $testGroupName -User $testUsername1, $testUsername2 -ErrorAction SilentlyContinue } | Should Not Throw
                Assert-MockCalled -CommandName Invoke-JiraMethod -ParameterFilter {$Method -eq 'Post' -and $URI -match $testGroupName} -Exactly -Times 1 -Scope It
            }
        }
    }
}
