#requires -modules @{ ModuleName = "Pester"; ModuleVersion = "5.0" }

Describe 'New-JiraFilter' -Tag 'Unit' {

    BeforeAll {
        Import-Module "$PSScriptRoot/../../Tools/TestTools.psm1" -Force
        Invoke-InitTest $PSScriptRoot

        Import-Module "$PSScriptRoot/../../JiraPS" -Force
    }
    AfterAll {
        Invoke-TestCleanup
    }

    #region Definitions
    $jiraServer = "https://jira.example.com"

    $responseFilter = @"
{
    "self": "$jiraServer/rest/api/latest/filter/12844",
    "id": "12844",
    "name": "{0}",
    "jql": "{1}",
    "favourite": false
}
"@
    #endregion Definitions

    #region Mocks
    Mock Get-JiraConfigServer -ModuleName JiraPS {
        $jiraServer
    }

    Mock ConvertTo-JiraFilter -ModuleName JiraPS {
        $i = (ConvertFrom-Json $responseFilter)
        $i.PSObject.TypeNames.Insert(0, 'JiraPS.Filter')
        $i | Add-Member -MemberType AliasProperty -Name 'RestURL' -Value 'self'
        $i
    }

    Mock Get-JiraFilter -ModuleName JiraPS {
        ConvertTo-JiraFilter
    }

    Mock Invoke-JiraMethod -ModuleName JiraPS -ParameterFilter { $Method -eq 'Post' -and $URI -like "$jiraServer/rest/api/*/filter" } {
        Write-MockInfo 'Invoke-JiraMethod' @{ Method = $Method; Uri = $Uri; Body = $Body }
        ConvertFrom-Json $responseFilter
    }

    Mock Invoke-JiraMethod -ModuleName JiraPS {
        Write-MockInfo 'Invoke-JiraMethod' @{ Method = $Method; Uri = $Uri }
        throw "Unidentified call to Invoke-JiraMethod"
    }
    #endregion Mocks

    Describe "Sanity checking" {
        $command = Get-Command -Name New-JiraFilter

        It "has a parameter 'Name' of type [String]" {
            $command | Should -HaveParameter "Name" -Type [String]
        }

        It "has a parameter 'Description' of type [String]" {
            $command | Should -HaveParameter "Description" -Type [String]
        }

        It "has a parameter 'JQL' of type [String]" {
            $command | Should -HaveParameter "JQL" -Type [String]
        }

        It "has a parameter 'Favorite' of type [Switch]" {
            $command | Should -HaveParameter "Favorite" -Type [Switch]
        }

        It "has an alias 'Favourite' for parameter 'Favorite" {
            $command | Should -HaveParameter "Favorite" -Alias "Favourite"
        }

        It "has a parameter 'Credential' of type [PSCredential]" {
            $command | Should -HaveParameter "Credential" -Type [PSCredential]
        }
    }

    Describe "Behavior testing" {
        It "Invokes the Jira API to create a filter" {
            {
                $newData = @{
                    Name        = "myName"
                    Description = "myDescription"
                    JQL         = "myJQL"
                    Favorite    = $true
                }
                New-JiraFilter @newData
            } | Should -Not -Throw

            Assert-MockCalled -CommandName Invoke-JiraMethod -ModuleName JiraPS -Exactly -Times 1 -Scope It -ParameterFilter {
                $Method -eq 'Post' -and
                $URI -like '*/rest/api/*/filter' -and
                $Body -match "`"name`":\s*`"myName`"" -and
                $Body -match "`"description`":\s*`"myDescription`"" -and
                $Body -match "`"jql`":\s*`"myJQL`"" -and
                $Body -match "`"favourite`":\s*true"
            }
        }
    }

    Describe "Input testing" {
        It "-Name and -JQL" {
            {
                $parameter = @{
                    Name = "newName"
                    JQL  = "newJQL"
                }
                New-JiraFilter @parameter
            } | Should -Not -Throw

            Assert-MockCalled -CommandName Invoke-JiraMethod -ModuleName JiraPS -Exactly -Times 1 -Scope It
        }
        It "-Name and -Description and -JQL" {
            {
                $parameter = @{
                    Name        = "newName"
                    Description = "newDescription"
                    JQL         = "newJQL"
                }
                New-JiraFilter @parameter
            } | Should -Not -Throw

            Assert-MockCalled -CommandName Invoke-JiraMethod -ModuleName JiraPS -Exactly -Times 1 -Scope It
        }
        It "-Name and -Description and -JQL and -Favorite" {
            {
                $parameter = @{
                    Name        = "newName"
                    Description = "newDescription"
                    JQL         = "newJQL"
                    Favorite    = $true
                }
                New-JiraFilter @parameter
            } | Should -Not -Throw

            Assert-MockCalled -CommandName Invoke-JiraMethod -ModuleName JiraPS -Exactly -Times 1 -Scope It
        }
        It "maps the properties of an object to the parameters" {
            { Get-JiraFilter "12345" | New-JiraFilter } | Should -Not -Throw
        }
    }
}
