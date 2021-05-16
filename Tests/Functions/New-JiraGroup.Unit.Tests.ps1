#requires -modules @{ ModuleName = "Pester"; ModuleVersion = "5.0" }

Describe "New-JiraGroup" -Tag 'Unit' {

    BeforeAll {
        Import-Module "$PSScriptRoot/../../Tools/TestTools.psm1" -Force
        Invoke-InitTest $PSScriptRoot

        Import-Module "$PSScriptRoot/../../JiraPS" -Force
    }
    AfterAll {
        Invoke-TestCleanup
    }

    $jiraServer = 'http://jiraserver.example.com'

    $testGroupName = 'testGroup'

    $testJson = @"
{
    "name": "$testGroupName",
    "self": "$jiraServer/rest/api/2/group?groupname=$testGroupName",
    "users": {
        "size": 0,
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

    Mock Invoke-JiraMethod -ModuleName JiraPS -ParameterFilter { $Method -eq 'POST' -and $URI -eq "$jiraServer/rest/api/latest/group" } {
        Write-MockInfo 'Invoke-JiraMethod' @{ Method = $Method; Uri = $Uri }
        ConvertFrom-Json $testJson
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

    # TODO: test inputs and outputs

    It "Creates a group in JIRA and returns a result" {
        $newResult = New-JiraGroup -GroupName $testGroupName
        $newResult | Should -Not -BeNullOrEmpty
    }

    It "Uses ConvertTo-JiraGroup to beautify output" {
        Assert-MockCalled 'ConvertTo-JiraGroup'
    }

    # It "Outputs a JiraPS.Group object" {
    #     $newResult = New-JiraGroup -GroupName $testGroupName
    #     (Get-Member -InputObject $newResult).TypeName | Should -Be 'JiraPS.Group'
    #     $newResult.Name | Should -Be $testGroupName
    #     $newResult.RestUrl | Should -Be "$jiraServer/rest/api/2/group?groupname=$testGroupName"
    # }
}
