#requires -modules @{ ModuleName = "Pester"; ModuleVersion = "5.0" }

Describe 'Get-JiraIssueLinkType' -Tag 'Unit' {

    BeforeAll {
        Import-Module "$PSScriptRoot/../../Tools/TestTools.psm1" -Force
        Invoke-InitTest $PSScriptRoot

        Import-Module "$PSScriptRoot/../../JiraPS" -Force
    }
    AfterAll {
        Invoke-TestCleanup
    }

    $jiraServer = 'http://jiraserver.example.com'


    Mock Get-JiraConfigServer -ModuleName JiraPS {
        Write-Output $jiraServer
    }

    Describe "Sanity checking" {
        $command = Get-Command -Name Get-JiraIssueLinkType

        It "has a parameter 'LinkType' of type [AtlassianPS.JiraPS.IssueLinkType]" {
            $command | Should -HaveParameter "LinkType" -Type [AtlassianPS.JiraPS.IssueLinkType]
        }

        It "has a parameter 'Credential' of type [PSCredential]" {
            $command | Should -HaveParameter "Credential" -Type [PSCredential]
        }
    }

    $filterAll = { $Method -eq 'Get' -and $Uri -ceq "$jiraServer/rest/api/latest/issueLinkType" }
    $filterOne = { $Method -eq 'Get' -and $Uri -ceq "$jiraServer/rest/api/latest/issueLinkType/10000" }

    Mock ConvertTo-JiraIssueLinkType {
        Write-MockInfo 'ConvertTo-JiraIssueLinkType'

        # We also don't care what comes out of here - this function has its own tests
        [PSCustomObject] @{
            PSTypeName = 'JiraPS.IssueLinkType'
            foo        = 'bar'
        }
    }

    # Generic catch-all. This will throw an exception if we forgot to mock something.
    Mock Invoke-JiraMethod -ModuleName JiraPS {
        Write-MockInfo 'Invoke-JiraMethod' @{ Method = $Method; Uri = $Uri }
        throw "Unidentified call to Invoke-JiraMethod"
    }

    Mock Invoke-JiraMethod -ParameterFilter $filterAll {
        Write-MockInfo 'Invoke-JiraMethod' @{ Method = $Method; Uri = $Uri }
        [PSCustomObject] @{
            issueLinkTypes = @(
                # We don't care what data actually comes back here
                'foo'
            )
        }
    }

    Mock Invoke-JiraMethod -ParameterFilter $filterOne {
        Write-MockInfo 'Invoke-JiraMethod' @{ Method = $Method; Uri = $Uri }
        [PSCustomObject] @{
            issueLinkTypes = @(
                'bar'
            )
        }
    }

    Describe "Behavior testing - returning all link types" {

        $output = Get-JiraIssueLinkType

        It 'Uses Invoke-JiraMethod to communicate with JIRA' {
            Assert-MockCalled -CommandName Invoke-JiraMethod -ParameterFilter $filterAll -Exactly -Times 1 -Scope Context
        }

        It 'Returns all link types if no value is passed to the -LinkType parameter' {
            $output | Should -Not -BeNullOrEmpty
        }

        It 'Uses the helper method ConvertTo-JiraIssueLinkType to process output' {
            Assert-MockCalled -CommandName ConvertTo-JiraIssueLinkType -ParameterFilter { $InputObject -contains 'foo' } -Exactly -Times 1 -Scope Context
        }
    }

    Describe "Behavior testing - returning one link type" {
        Mock ConvertTo-JiraIssueLinkType {
            Write-MockInfo 'ConvertTo-JiraIssueLinkType'

            # We also don't care what comes out of here - this function has its own tests
            [PSCustomObject] @{
                PSTypeName = 'JiraPS.IssueLinkType'
                Name       = 'myLink'
                ID         = 5
            }
        }

        It 'Returns a single link type if an ID number is passed to the -LinkType parameter' {
            $output = Get-JiraIssueLinkType -LinkType 10000
            Assert-MockCalled -CommandName Invoke-JiraMethod -ParameterFilter $filterOne -Exactly -Times 1 -Scope It
            $output | Should -Not -BeNullOrEmpty
            @($output).Count | Should -Be 1
        }

        It 'Returns the correct link type it a type name is passed to the -LinkType parameter' {
            $output = Get-JiraIssueLinkType -LinkType 'myLink'
            Assert-MockCalled -CommandName Invoke-JiraMethod -ParameterFilter $filterAll -Exactly -Times 1 -Scope It
            $output | Should -Not -BeNullOrEmpty
            @($output).Count | Should -Be 1
            $output.ID | Should -Be 5
        }
    }
}
