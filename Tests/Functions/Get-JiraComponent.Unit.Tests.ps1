#requires -modules @{ ModuleName = "Pester"; ModuleVersion = "5.0" }

Describe "Get-JiraComponent" -Tag 'Unit' {

    BeforeAll {
        Import-Module "$PSScriptRoot/../../Tools/TestTools.psm1" -Force
        Invoke-InitTest $PSScriptRoot

        Import-Module "$PSScriptRoot/../../JiraPS" -Force
    }
    AfterAll {
        Invoke-TestCleanup
    }

    $jiraServer = 'http://jiraserver.example.com'

    $projectKey = 'TEST'
    $projectId = '10004'

    $componentId = '10001'
    $componentName = 'Component 1'

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

    Mock Invoke-JiraMethod -ModuleName JiraPS -ParameterFilter { $Method -eq 'Get' -and $URI -eq "$jiraServer/rest/api/latest/component/$componentId" } {
        Write-MockInfo 'Invoke-JiraMethod' @{ Method = $Method; Uri = $Uri }
        ConvertFrom-Json $restResultOne
    }

    # Generic catch-all. This will throw an exception if we forgot to mock something.
    Mock Invoke-JiraMethod -ModuleName JiraPS {
        Write-MockInfo 'Invoke-JiraMethod' @{ Method = $Method; Uri = $Uri }
        throw "Unidentified call to Invoke-JiraMethod"
    }

    #############
    # Tests
    #############

    It "Returns details about specific components if the component ID is supplied" {
        $oneResult = Get-JiraComponent -Id $componentId
        $oneResult | Should -Not -BeNullOrEmpty
        @($oneResult).Count | Should -Be 1
        $oneResult.Id | Should -Be $componentId
    }

    It "Provides the Id of the component" {
        $oneResult = Get-JiraComponent -Id $componentId
        $oneResult.Id | Should -Be $componentId
    }
}
