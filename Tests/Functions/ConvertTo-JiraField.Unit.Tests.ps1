#requires -modules BuildHelpers
#requires -modules @{ ModuleName = "Pester"; ModuleVersion = "4.10.1" }

Describe "ConvertTo-JiraField" -Tag 'Unit' {

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

        $sampleJson = '{"id":"issuetype","name":"Issue Type","custom":false,"orderable":true,"navigable":true,"searchable":true,"clauseNames":["issuetype","type"],"schema":{"type":"issuetype","system":"issuetype"}}'
        $sampleObject = ConvertFrom-Json -InputObject $sampleJson

        $r = ConvertTo-JiraField $sampleObject
        It "Creates a PSObject out of JSON input" {
            $r | Should Not BeNullOrEmpty
        }

        checkPsType $r 'JiraPS.Field'

        defProp $r 'Id' 'issuetype'
        defProp $r 'Name' 'Issue Type'
        defProp $r 'Custom' $false
    }
}
