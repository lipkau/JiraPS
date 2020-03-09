#requires -modules BuildHelpers
#requires -modules @{ ModuleName = "Pester"; ModuleVersion = "4.4.0" }

Describe "ConvertTo-JiraTransition" -Tag 'Unit' {

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

        $tId = 11
        $tName = 'Start Progress'

        # Transition result status
        $tRId = 3
        $tRName = 'In Progress'
        $tRDesc = 'This issue is being actively worked on at the moment by the assignee.'

        $sampleJson = @"
{
    "id": "$tId",
    "name": "$tName",
    "to": {
        "self": "$jiraServer/rest/api/2/status/$tRId",
        "description": "$tRDesc",
        "iconUrl": "$jiraServer/images/icons/statuses/inprogress.png",
        "name": "$tRName",
        "id": "$tRId",
        "statusCategory": {
            "self": "$jiraServer/rest/api/2/statuscategory/4",
            "id": 4,
            "key": "indeterminate",
            "colorName": "yellow",
            "name": "In Progress"
        }
    }
}
"@
        $sampleObject = ConvertFrom-Json -InputObject $sampleJson

        $r = ConvertTo-JiraTransition -InputObject $sampleObject

        It "Creates a PSObject out of JSON input" {
            $r | Should Not BeNullOrEmpty
        }

        checkPsType $r 'JiraPS.Transition'

        defProp $r 'Id' $tId
        defProp $r 'Name' $tName

        It "Defines the 'ResultStatus' property as a JiraPS.Status object" {
            $r.ResultStatus.Id | Should Be $tRId
            $r.ResultStatus.Name | Should Be $tRName
        }
    }
}
