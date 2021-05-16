#requires -modules @{ ModuleName = "Pester"; ModuleVersion = "5.0" }

Describe "New-JiraSession" -Tag 'Unit' {

    BeforeAll {
        Import-Module "$PSScriptRoot/../../Tools/TestTools.psm1" -Force
        Invoke-InitTest $PSScriptRoot

        Import-Module "$PSScriptRoot/../../JiraPS" -Force
    }
    AfterAll {
        Invoke-TestCleanup
    }
    AfterEach {
        try {
            (Get-Module JiraPS).PrivateData.Remove("Session")
        }
        catch { $null }
    }

    #region Definitions
    $jiraServer = 'http://jiraserver.example.com'

    $testCredential = [System.Management.Automation.PSCredential]::Empty
    #endregion Definitions

    #region Mocks
    Mock Get-JiraConfigServer -ModuleName JiraPS {
        Write-Output $jiraServer
    }

    Mock ConvertTo-JiraSession -ModuleName JiraPS { }

    Mock Invoke-JiraMethod -ModuleName JiraPS -ParameterFilter { $Method -eq 'Get' -and $Uri -like "*/rest/api/*/myself" } {
        Write-MockInfo 'Invoke-JiraMethod' @{ Method = $Method; Uri = $Uri }
        New-Object -TypeName Microsoft.PowerShell.Commands.WebRequestSession
    }

    Mock Invoke-JiraMethod -ModuleName JiraPS {
        Write-MockInfo 'Invoke-JiraMethod' @{ Method = $Method; Uri = $Uri }
        throw "Unidentified call to Invoke-JiraMethod"
    }
    #endregion Mocks

    Describe "Sanity checking" {
        $command = Get-Command -Name New-JiraSession

        It "has a parameter 'Headers' of type [Hashtable]" {
            $command | Should -HaveParameter "Headers" -Type [Hashtable]
        }

        It "has a parameter 'Credential' of type [PSCredential]" {
            $command | Should -HaveParameter "Credential" -Type [PSCredential]
        }
    }

    Describe "Behavior testing" {
        It "uses Basic Authentication to generate a session" {
            { New-JiraSession -Credential $testCredential } | Should -Not -Throw

            $assertMockCalledSplat = @{
                CommandName     = 'Invoke-JiraMethod'
                ModuleName      = 'JiraPS'
                ParameterFilter = {
                    $Credential -eq $testCredential
                }
                Exactly         = $true
                Times           = 1
                Scope           = 'It'
            }
            Assert-MockCalled @assertMockCalledSplat
        }

        It "can influence the Headers used in the request" {
            { New-JiraSession -Credential $testCredential -Headers @{ "X-Header" = $true } } | Should -Not -Throw

            $assertMockCalledSplat = @{
                CommandName     = 'Invoke-JiraMethod'
                ModuleName      = 'JiraPS'
                ParameterFilter = {
                    $Headers.ContainsKey("X-Header")
                }
                Exactly         = $true
                Times           = 1
                Scope           = 'It'
            }
            Assert-MockCalled @assertMockCalledSplat
        }

        It "stores the session variable in the module's PrivateData" {
            (Get-Module JiraPS).PrivateData.Session | Should -BeNullOrEmpty

            New-JiraSession -Credential $testCredential

            (Get-Module JiraPS).PrivateData.Session | Should -Not -BeNullOrEmpty
        }
    }

    Describe "Input testing" { }
}
