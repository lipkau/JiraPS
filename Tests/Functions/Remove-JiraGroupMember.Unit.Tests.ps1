#requires -modules @{ ModuleName = "Pester"; ModuleVersion = "5.0" }

Describe "Remove-JiraGroupMember" -Tag 'Unit' {

    BeforeAll {
        Import-Module "$PSScriptRoot/../../Tools/TestTools.psm1" -Force
        Invoke-InitTest $PSScriptRoot

        Import-Module "$PSScriptRoot/../../JiraPS" -Force
    }
    AfterAll {
        Invoke-TestCleanup
    }

    #region Definitions
    $jiraServer = 'http://jiraserver.example.com'

    $testGroupName = 'testGroup'
    $testUsername1 = 'testUsername1'
    $testUsername2 = 'testUsername2'
    #endregion Definitions

    #region Mocks
    Mock Get-JiraConfigServer -ModuleName JiraPS {
        Write-Output $jiraServer
    }

    Mock Get-JiraGroup -ModuleName JiraPS {
        [PSCustomObject]@{
            PSTypeName = "JiraPS.Group"
            Name       = $testGroupName
            Size       = 2
        }
    }

    Mock Get-JiraUser -ModuleName JiraPS {
        if ($InputObject) {
            $obj = [PSCustomObject]@{
                PSTypeName = "JiraPS.User"
                Name       = "$InputObject"
            }
        }
        else {
            $obj = [PSCustomObject]@{
                PSTypeName = "JiraPS.User"
                Name       = "$UserName"
            }
        }
        $obj | Add-Member -MemberType ScriptMethod -Name "ToString" -Force -Value {
            Write-Output "$($this.Name)"
        }
        $obj
    }

    Mock Get-JiraGroupMember -ModuleName JiraPS {
        [PSCustomObject]@{
            PSTypeName = "JiraPS.Group"
            Name       = $testUsername1
        }
    }

    Mock Invoke-JiraMethod -ModuleName JiraPS {
        Write-MockInfo 'Invoke-JiraMethod' @{ Method = $Method; Uri = $Uri }
    }
    #endregion Mocks

    #############
    # Tests
    #############
    Describe "Sanity checking" {
        $command = Get-Command -Name Remove-JiraGroupMember

        It "has a parameter 'Group' of type [AtlassianPS.JiraPS.Group[]]" {
            $command | Should -HaveParameter "Group" -Type [AtlassianPS.JiraPS.Group[]]
        }

        It "has an alias 'GroupName' for parameter 'Group" {
            $command | Should -HaveParameter "Group" -Alias "GroupName"
        }

        It "has a parameter 'User' of type [AtlassianPS.JiraPS.User[]]" {
            $command | Should -HaveParameter "User" -Type [AtlassianPS.JiraPS.User[]]
        }

        It "has an alias 'UserName' for parameter 'User" {
            $command | Should -HaveParameter "User" -Alias "UserName"
        }

        It "has a parameter 'Credential' of type [PSCredential]" {
            $command | Should -HaveParameter "Credential" -Type [PSCredential]
        }

        It "has a parameter 'PassThru' of type [Switch]" {
            $command | Should -HaveParameter "PassThru" -Type [Switch]
        }

        It "has a parameter 'Force' of type [Switch]" {
            $command | Should -HaveParameter "Force" -Type [Switch]
        }
    }

    Describe "Behavior testing" {
        It "Tests to see if a provided user is currently a member of the provided JIRA group before attempting to remove them" {
            { Remove-JiraGroupMember -Group $testGroupName -User $testUsername1 -Force } | Should -Not -Throw

            Assert-MockCalled -CommandName Get-JiraGroup -ModuleName "JiraPS" -Exactly -Times 1 -Scope It
        }

        It "Removes a user from a JIRA group if the user is a member" {
            { Remove-JiraGroupMember -Group $testGroupName -User $testUsername1 -Force } | Should -Not -Throw

            $assertMockCalledSplat = @{
                CommandName     = 'Invoke-JiraMethod'
                ModuleName      = "JiraPS"
                ParameterFilter = {
                    $Method -eq 'Delete' -and
                    $URI -like "$jiraServer/rest/api/*/group/user?groupname=$testGroupName&username=$testUsername1"
                }
                Exactly         = $true
                Times           = 1
                Scope           = 'It'
            }
            Assert-MockCalled @assertMockCalledSplat
        }

        It "Removes multiple users to a JIRA group if they are passed to the -User parameter" {
            # Override our previous mock so we have two group members
            Mock Get-JiraGroupMember -ModuleName JiraPS {
                @(
                    [PSCustomObject] @{
                        'Name' = $testUsername1
                    },
                    [PSCustomObject] @{
                        'Name' = $testUsername2
                    }
                )
            }

            # Should use the REST method twice, since at present, you can only delete one group member per API call
            { Remove-JiraGroupMember -Group $testGroupName -User $testUsername1, $testUsername2 -Force } | Should -Not -Throw

            $assertMockCalledSplat = @{
                CommandName     = 'Invoke-JiraMethod'
                ModuleName      = "JiraPS"
                ParameterFilter = {
                    $Method -eq 'Delete' -and
                    $URI -like "$jiraServer/rest/api/*/group/user?groupname=$testGroupName&username=*"
                }
                Exactly         = $true
                Times           = 2
                Scope           = 'It'
            }
            Assert-MockCalled @assertMockCalledSplat
        }
    }

    Describe "Input testing" {
        It "Accepts a group name as a String to the -Group parameter" {
            { Remove-JiraGroupMember -Group $testGroupName -User $testUsername1 -Force } | Should -Not -Throw

            $assertMockCalledSplat = @{
                CommandName     = 'Invoke-JiraMethod'
                ModuleName      = "JiraPS"
                ParameterFilter = {
                    $Method -eq "Delete" -and
                    $URI -like "*/rest/api/*/group/user*" -and
                    $URI -match "groupname=$testGroupName" -and
                    $URI -match "username=$testUsername1"
                }
                Exactly         = $true
                Times           = 1
                Scope           = 'It'
            }
            Assert-MockCalled @assertMockCalledSplat
        }

        It "Accepts a JiraPS.Group object to the -Group parameter" {
            {
                $group = Get-JiraGroup -GroupName $testGroupName
                Remove-JiraGroupMember -Group $group -User $testUsername1 -Force
            } | Should -Not -Throw

            $assertMockCalledSplat = @{
                CommandName     = 'Invoke-JiraMethod'
                ModuleName      = "JiraPS"
                ParameterFilter = {
                    $Method -eq "Delete" -and
                    $URI -like "*/rest/api/*/group/user*" -and
                    $URI -match "groupname=$testGroupName" -and
                    $URI -match "username=$testUsername1"
                }
                Exactly         = $true
                Times           = 1
                Scope           = 'It'
            }
            Assert-MockCalled @assertMockCalledSplat
        }

        It "Accepts pipeline input from Get-JiraGroup" {
            { Get-JiraGroup -GroupName $testGroupName | Remove-JiraGroupMember -User $testUsername1 -Force } | Should -Not -Throw

            $assertMockCalledSplat = @{
                CommandName     = 'Invoke-JiraMethod'
                ModuleName      = "JiraPS"
                ParameterFilter = {
                    $Method -eq "Delete" -and
                    $URI -like "*/rest/api/*/group/user*" -and
                    $URI -match "groupname=$testGroupName" -and
                    $URI -match "username=$testUsername1"
                }
                Exactly         = $true
                Times           = 1
                Scope           = 'It'
            }
            Assert-MockCalled @assertMockCalledSplat
        }

        It "Accepts a JiraPS.User as input for -User parameter" {
            {
                $user = Get-JiraUser -UserName $testUsername1
                Remove-JiraGroupMember -Group $testGroupName -User $user -Force
            } | Should -Not -Throw

            $assertMockCalledSplat = @{
                CommandName     = 'Invoke-JiraMethod'
                ModuleName      = "JiraPS"
                ParameterFilter = {
                    $Method -eq "Delete" -and
                    $URI -like "*/rest/api/*/group/user*" -and
                    $URI -match "groupname=$testGroupName" -and
                    $URI -match "username=$testUsername1"
                }
                Exactly         = $true
                Times           = 1
                Scope           = 'It'
            }
            Assert-MockCalled @assertMockCalledSplat
        }
    }
}
