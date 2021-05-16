#requires -modules @{ ModuleName = "Pester"; ModuleVersion = "5.0" }

Describe "Get-JiraGroupMember" -Tag 'Unit' {

    BeforeAll {
        Import-Module "$PSScriptRoot/../../Tools/TestTools.psm1" -Force
        Invoke-InitTest $PSScriptRoot

        Import-Module "$PSScriptRoot/../../JiraPS" -Force
    }
    AfterAll {
        Invoke-TestCleanup
    }

    #region Mocks
    Mock Get-JiraConfigServer -ModuleName JiraPS {
        'https://jira.example.com'
    }

    Mock Get-JiraUser -ModuleName JiraPS {
        $object = [PSCustomObject] @{
            'Name' = 'username'
        }
        $object.PSObject.TypeNames.Insert(0, 'JiraPS.User')
        return $object
    }

    Mock Get-JiraGroup -ModuleName JiraPS {
        $obj = [PSCustomObject] @{
            'Name'    = 'testgroup'
            'RestUrl' = 'https://jira.example.com/rest/api/2/group?groupname=testgroup'
            'Size'    = 2
        }
        $obj.PSObject.TypeNames.Insert(0, 'JiraPS.Group')
        Write-Output $obj
    }

    Mock Invoke-JiraMethod -ModuleName JiraPS -ParameterFilter { $Method -eq 'Get' -and $URI -like '*/rest/api/*/group/member' -and $GetParameter["groupname"] -eq "testgroup" } {
        Write-MockInfo 'Invoke-JiraMethod' @{ Method = $Method; Uri = $Uri }
        ConvertFrom-Json @'
{
"Name":  "testgroup",
"RestUrl":  "https://jira.example.com/rest/api/2/group?groupname=testgroup",
"Size":  2
}
'@
    }

    # If we don't override this in a context or test, we don't want it to
    # actually try to query a JIRA instance
    Mock Invoke-JiraMethod {
        Write-MockInfo 'Invoke-JiraMethod' @{ Method = $Method; Uri = $Uri }
        throw "Unidentified call to Invoke-JiraMethod"
    }
    #endregion Mocks

    Describe "Sanity checking" {
        $command = Get-Command -Name Get-JiraGroupMember

        It "has a parameter 'Group' of type [AtlassianPS.JiraPS.Group[]]" {
            $command | Should -HaveParameter "Group" -Type [AtlassianPS.JiraPS.Group[]]
        }

        It "has a parameter 'IncludeInactive' of type [Switch]" {
            $command | Should -HaveParameter "IncludeInactive" -Type [Switch]
        }

        It "has a parameter 'PageSize' of type [UInt32]" {
            $command | Should -HaveParameter "PageSize" -Type [UInt32]
        }

        It "has a parameter 'Credential' of type [PSCredential]" {
            $command | Should -HaveParameter "Credential" -Type [PSCredential]
        }
    }

    Describe "Behavior testing" {

        It "Obtains members about a provided group in JIRA" {
            { Get-JiraGroupMember -Group testgroup } | Should -Not -Throw

            $assertMockCalledSplat = @{
                CommandName     = 'Invoke-JiraMethod'
                ModuleName      = 'JiraPS'
                ParameterFilter = {
                    $Method -eq 'Get' -and
                    $URI -like '*/rest/api/*/group/member'
                }
                Scope           = 'It'
                Exactly         = $true
                Times           = 1
            }
            Assert-MockCalled @assertMockCalledSplat
        }

        It "Supports the -StartIndex parameters to page through search results" {
            { Get-JiraGroupMember -Group testgroup -StartIndex 10 } | Should -Not -Throw

            $assertMockCalledSplat = @{
                CommandName     = 'Invoke-JiraMethod'
                ModuleName      = 'JiraPS'
                ParameterFilter = {
                    $Method -eq 'Get' -and
                    $URI -like '*/rest/api/*/group/member' -and
                    $PSCmdlet.PagingParameters.Skip -eq 10
                }
                Scope           = 'It'
                Exactly         = $true
                Times           = 1
            }
            Assert-MockCalled @assertMockCalledSplat
        }

        It "Supports the -MaxResults parameters to page through search results" {
            { Get-JiraGroupMember -Group testgroup -MaxResults 50 } | Should -Not -Throw

            $assertMockCalledSplat = @{
                CommandName     = 'Invoke-JiraMethod'
                ModuleName      = 'JiraPS'
                ParameterFilter = {
                    $Method -eq 'Get' -and
                    $URI -like '*/rest/api/*/group/member' -and
                    $PSCmdlet.PagingParameters.First -eq 50
                }
                Scope           = 'It'
                Exactly         = $true
                Times           = 1
            }
            Assert-MockCalled @assertMockCalledSplat
        }
    }

    Describe "Input testing" {
        It "Accepts a group name for the -Group parameter" {
            { Get-JiraGroupMember -Group testgroup } | Should -Not -Throw

            $assertMockCalledSplat = @{
                CommandName     = 'Invoke-JiraMethod'
                ModuleName      = 'JiraPS'
                ParameterFilter = {
                    $Method -eq 'Get' -and
                    $URI -like '*/rest/api/*/group/member' -and
                    $GetParameter["groupname"] -eq "testgroup"
                }
                Scope           = 'It'
                Exactly         = $true
                Times           = 1
            }
            Assert-MockCalled @assertMockCalledSplat
        }

        It "Accepts a group object for the -InputObject parameter" {
            $group = Get-JiraGroup -GroupName testgroup

            { Get-JiraGroupMember -Group $group } | Should -Not -Throw

            $assertMockCalledSplat = @{
                CommandName     = 'Invoke-JiraMethod'
                ModuleName      = 'JiraPS'
                ParameterFilter = {
                    $Method -eq 'Get' -and
                    $URI -like '*/rest/api/*/group/member' -and
                    $GetParameter["groupname"] -eq "testgroup"
                }
                Scope           = 'It'
                Exactly         = $true
                Times           = 1
            }
            Assert-MockCalled @assertMockCalledSplat

            # We called Get-JiraGroup once manually, and it Should -Be
            # called once by Get-JiraGroupMember.
            Assert-MockCalled -CommandName Get-JiraGroup -Exactly -Times 2 -Scope It
        }
    }
}
