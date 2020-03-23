#requires -modules BuildHelpers
#requires -modules @{ ModuleName = "Pester"; ModuleVersion = "4.10.1" }

Describe "Get-JiraProject" -Tag 'Unit' {

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

        $projectKey = 'IT'
        $projectId = '10003'
        $projectName = 'Information Technology'

        $projectKey2 = 'TEST'
        $projectId2 = '10004'
        $projectName2 = 'Test Project'

        $restResultAll = @"
[
    {
        "self": "$jiraServer/rest/api/2/project/10003",
        "id": "$projectId",
        "key": "$projectKey",
        "name": "$projectName",
        "projectCategory": {
            "self": "$jiraServer/rest/api/2/projectCategory/10000",
            "id": "10000",
            "description": "All Project Catagories",
            "name": "All Project"
        }
    },
    {
        "self": "$jiraServer/rest/api/2/project/10121",
        "id": "$projectId2",
        "key": "$projectKey2",
        "name": "$projectName2",
        "projectCategory": {
            "self": "$jiraServer/rest/api/2/projectCategory/10000",
            "id": "10000",
            "description": "All Project Catagories",
            "name": "All Project"
        }
    }
]
"@

        $restResultOne = @"
[
    {
        "self": "$jiraServer/rest/api/2/project/10003",
        "id": "$projectId",
        "key": "$projectKey",
        "name": "$projectName",
        "projectCategory": {
            "self": "$jiraServer/rest/api/2/projectCategory/10000",
            "id": "10000",
            "description": "All Project Catagories",
            "name": "All Project"
        }
    }
]
"@
        Mock Get-JiraConfigServer -ModuleName JiraPS {
            Write-Output $jiraServer
        }

        Mock Invoke-JiraMethod -ModuleName JiraPS -ParameterFilter { $Method -eq 'Get' -and $URI -like "$jiraServer/rest/api/*/project*" } {
            ShowMockInfo 'Invoke-JiraMethod' @{ Method = $Method; Uri = $Uri }
            ConvertFrom-Json $restResultAll
        }

        Mock Invoke-JiraMethod -ModuleName JiraPS -ParameterFilter { $Method -eq 'Get' -and $URI -like "$jiraServer/rest/api/*/project/$projectKey?*" } {
            ShowMockInfo 'Invoke-JiraMethod' @{ Method = $Method; Uri = $Uri }
            ConvertFrom-Json $restResultOne
        }

        # Generic catch-all. This will throw an exception if we forgot to mock something.
        Mock Invoke-JiraMethod -ModuleName JiraPS {
            ShowMockInfo 'Invoke-JiraMethod' @{ Method = $Method; Uri = $Uri }
            throw "Unidentified call to Invoke-JiraMethod"
        }

        #############
        # Tests
        #############

        It "Returns all projects if called with no parameters" {
            $allResults = Get-JiraProject
            $allResults | Should Not BeNullOrEmpty
            @($allResults).Count | Should Be (ConvertFrom-Json -InputObject $restResultAll).Count
        }

        It "Returns details about specific projects if the project key is supplied" {
            $oneResult = Get-JiraProject -Project $projectKey
            $oneResult | Should Not BeNullOrEmpty
            @($oneResult).Count | Should Be 1
        }

        It "Returns details about specific projects if the project ID is supplied" {
            $oneResult = Get-JiraProject -Project $projectId
            $oneResult | Should Not BeNullOrEmpty
            @($oneResult).Count | Should Be 1
        }

        It "Provides the key of the project" {
            $oneResult = Get-JiraProject -Project $projectKey
            $oneResult.Key | Should Be $projectKey
        }

        It "Provides the ID of the project" {
            $oneResult = Get-JiraProject -Project $projectKey
            $oneResult.Id | Should Be $projectId
        }
    }
}
