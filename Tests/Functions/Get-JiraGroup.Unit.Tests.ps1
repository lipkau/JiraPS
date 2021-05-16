#requires -modules @{ ModuleName = "Pester"; ModuleVersion = "5.0" }

Describe "Get-JiraGroup" -Tag 'Unit' {

    BeforeAll {
        Import-Module "$PSScriptRoot/../../Tools/TestTools.psm1" -Force
        Invoke-InitTest $PSScriptRoot

        Import-Module "$PSScriptRoot/../../JiraPS" -Force
    }
    AfterAll {
        Invoke-TestCleanup
    }

    $jiraServer = 'http://jiraserver.example.com'

    $testGroupName = "Test Group"
    $testGroupNameEscaped = "Test%20Group"
    $testGroupSize = 1

    $restResult = @"
{
    "name": "$testGroupName",
    "self": "$jiraServer/rest/api/2/group?groupname=$testGroupName",
    "users": {
        "size": "$testGroupSize",
        "items": [],
        "max-results": 50,
        "start-index": 0,
        "end-index": 0
    },
    "expand": "users"
}
"@

    Mock Get-JiraConfigServer -ModuleName JiraPS {
        Write-Output $jiraServer
    }

    # Searching for a group.
    Mock Invoke-JiraMethod -ModuleName JiraPS -ParameterFilter { $Method -eq 'Get' -and $URI -eq "$jiraServer/rest/api/latest/group?groupname=$testGroupNameEscaped" } {
        Write-MockInfo 'Invoke-JiraMethod' @{ Method = $Method; Uri = $Uri }
        ConvertFrom-Json -InputObject $restResult
    }

    # Generic catch-all. This will throw an exception if we forgot to mock something.
    Mock Invoke-JiraMethod -ModuleName JiraPS {
        Write-MockInfo 'Invoke-JiraMethod' @{ Method = $Method; Uri = $Uri }
        throw "Unidentified call to Invoke-JiraMethod"
    }

    Mock ConvertTo-JiraGroup { $InputObject }

    #############
    # Tests
    #############

    It "Gets information about a provided Jira group" {
        $getResult = Get-JiraGroup -GroupName $testGroupName
        $getResult | Should -Not -BeNullOrEmpty
    }

    It "Uses ConvertTo-JiraGroup to beautify output" {
        Get-JiraGroup -GroupName $testGroupName

        Assert-MockCalled 'ConvertTo-JiraGroup'
    }
}
