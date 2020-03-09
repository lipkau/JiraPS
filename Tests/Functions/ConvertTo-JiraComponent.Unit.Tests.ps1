#requires -modules BuildHelpers
#requires -modules @{ ModuleName = "Pester"; ModuleVersion = "4.4.0" }

Describe "ConvertTo-JiraComponent" -Tag 'Unit' {

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
    "self": "$jiraServer/rest/api/2/component/11000",
    "id": "11000",
    "name": "test component"
}
"@
        $sampleObject = ConvertFrom-Json -InputObject $sampleJson

        $r = ConvertTo-JiraComponent -InputObject $sampleObject

        It "Creates a PSObject out of JSON input" {
            $r | Should Not BeNullOrEmpty
        }

        It "Sets the type name to JiraPS.Project" {
            # (Get-Member -InputObject $r).TypeName | Should Be 'JiraPS.Component'
            checkType $r "JiraPS.Component"
        }

        defProp $r 'Id' '11000'
        defProp $r 'Name' 'test component'
        defProp $r 'RestUrl' "$jiraServer/rest/api/2/component/11000"
    }
}
