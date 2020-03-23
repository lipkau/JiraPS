#requires -modules BuildHelpers
#requires -modules @{ ModuleName = "Pester"; ModuleVersion = "4.10.1" }

Describe "New-JiraUser" -Tag 'Unit' {

    BeforeAll {
        Import-Module "$PSScriptRoot/../../../Tools/TestTools.psm1" -force
        Invoke-InitTest $PSScriptRoot

        Import-Module $env:BHManifestToTest -Force
    }
    AfterAll {
        Invoke-TestCleanup
    }

    InModuleScope JiraPS {

        . "$PSScriptRoot/../Shared.ps1"

        $jiraServer = 'http://jiraserver.example.com'

        $testUsername = 'powershell-test'
        $testEmail = "$testUsername@example.com"
        $testDisplayName = 'Test User'

        # Trimmed from this example JSON: expand, groups, avatarURL
        $testJson = @"
{
    "self": "$jiraServer/rest/api/2/user?username=testUser",
    "key": "$testUsername",
    "name": "$testUsername",
    "emailAddress": "$testEmail",
    "displayName": "$testDisplayName",
    "active": true
}
"@

        Mock Get-JiraConfigServer -ModuleName JiraPS {
            Write-Output $jiraServer
        }

        Mock Invoke-JiraMethod -ModuleName JiraPS -ParameterFilter { $Method -eq 'POST' -and $URI -eq "$jiraServer/rest/api/latest/user" } {
            ShowMockInfo 'Invoke-JiraMethod' @{ Method = $Method; Uri = $Uri }
            ConvertFrom-Json $testJson
        }

        # Generic catch-all. This will throw an exception if we forgot to mock something.
        Mock Invoke-JiraMethod -ModuleName JiraPS {
            ShowMockInfo 'Invoke-JiraMethod' @{ Method = $Method; Uri = $Uri }
            throw "Unidentified call to Invoke-JiraMethod"
        }

        #############
        # Tests
        #############

        It "Creates a user in JIRA and returns a result" {
            $newResult = New-JiraUser -UserName $testUsername -EmailAddress $testEmail -DisplayName $testDisplayName
            $newResult | Should Not BeNullOrEmpty
        }

        Describe "Output checking" {
            Mock ConvertTo-JiraUser { }
            New-JiraUser -UserName $testUsername -EmailAddress $testEmail -DisplayName $testDisplayName

            It "Uses ConvertTo-JiraUser to beautify output" {
                Assert-MockCalled 'ConvertTo-JiraUser'
            }
        }
    }
}
