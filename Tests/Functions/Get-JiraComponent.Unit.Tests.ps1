#requires -modules BuildHelpers
#requires -modules @{ ModuleName = "Pester"; ModuleVersion = "4.10.1" }

Describe "Get-JiraComponent" -Tag 'Unit' {

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

        $projectKey = 'TEST'
        $projectId = '10004'

        $componentId = '10001'
        $componentName = 'Component 1'
        $componentId2 = '10002'
        $componentName2 = 'Component 2'


        $restResultAll = @"
[
    {
        "self": "$jiraServer/rest/api/2/component/$componentId",
        "id": "$componentId",
        "name": "$componentName",
        "project": "$projectKey",
        "projectId": "$projectId"
    },
    {
        "self": "$jiraServer/rest/api/2/component/$componentId2",
        "id": "$componentId2",
        "name": "$componentName2",
        "project": "$projectKey",
        "projectId": "$projectId"
    }
]
"@

        $restResultOne = @"
[
    {
        "self": "$jiraServer/rest/api/2/component/$componentId",
        "id": "$componentId",
        "name": "$componentName",
        "project": "$projectKey",
        "projectId": "$projectId"
    }
]
"@

        Mock Get-JiraConfigServer -ModuleName JiraPS {
            Write-Output $jiraServer
        }

        Mock Invoke-JiraMethod -ModuleName JiraPS -ParameterFilter {$Method -eq 'Get' -and $URI -eq "$jiraServer/rest/api/latest/component/$componentId"} {
            ShowMockInfo 'Invoke-JiraMethod' 'Method', 'Uri'
            ConvertFrom-Json $restResultOne
        }

        # Generic catch-all. This will throw an exception if we forgot to mock something.
        Mock Invoke-JiraMethod -ModuleName JiraPS {
            ShowMockInfo 'Invoke-JiraMethod' 'Method', 'Uri'
            throw "Unidentified call to Invoke-JiraMethod"
        }

        #############
        # Tests
        #############

        It "Returns details about specific components if the component ID is supplied" {
            $oneResult = Get-JiraComponent -Id $componentId
            $oneResult | Should Not BeNullOrEmpty
            @($oneResult).Count | Should Be 1
            $oneResult.Id | Should Be $componentId
        }

        It "Provides the Id of the component" {
            $oneResult = Get-JiraComponent -Id $componentId
            $oneResult.Id | Should Be $componentId
        }


    }
}
