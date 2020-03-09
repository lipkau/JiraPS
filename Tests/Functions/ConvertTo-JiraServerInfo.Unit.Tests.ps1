#requires -modules BuildHelpers
#requires -modules @{ ModuleName = "Pester"; ModuleVersion = "4.10.1" }

Describe "ConvertTo-JiraServerInfo" -Tag 'Unit' {

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

        $sampleJson = @"
{
    "baseUrl":"$jiraServer",
    "version":"1000.1323.0",
    "versionNumbers":[1000,1323,0],
    "deploymentType":"Cloud",
    "buildNumber":100062,
    "buildDate":"2017-09-26T00:00:00.000+0200",
    "serverTime":"2017-09-27T09:59:25.520+0200",
    "scmInfo":"f3c60100df073e3576f9741fb7a3dc759b416fde",
    "serverTitle":"JIRA"
}
"@

        $sampleObject = ConvertFrom-Json -InputObject $sampleJson
        $r = ConvertTo-JiraServerInfo -InputObject $sampleObject

        It "Creates a PSObject out of JSON input" {
            $r | Should Not BeNullOrEmpty
        }

        checkPsType $r 'JiraPS.ServerInfo'


        defProp $r 'BaseURL' $jiraServer
        defProp $r 'Version' ([Version]"1000.1323.0")
        defProp $r 'DeploymentType' "Cloud"
        defProp $r 'BuildNumber' 100062
        defProp $r 'BuildDate' (Get-Date '2017-09-26T00:00:00.000+0200')
        defProp $r 'ServerTime' (Get-Date '2017-09-27T09:59:25.520+0200')
        defProp $r 'ScmInfo' "f3c60100df073e3576f9741fb7a3dc759b416fde"
        defProp $r 'ServerTitle' "JIRA"
    }
}
