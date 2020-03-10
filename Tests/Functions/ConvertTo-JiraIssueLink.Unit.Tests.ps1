#requires -modules BuildHelpers
#requires -modules @{ ModuleName = "Pester"; ModuleVersion = "4.10.1" }

Describe "ConvertTo-JiraIssueLink" -Tag 'Unit' {

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

        $issueLinkId = 41313
        $issueKeyInward = "TEST-01"
        $issueKeyOutward = "TEST-10"
        $linkTypeName = "Composition"

        $sampleJson = @"
{
    "id": "$issueLinkId",
    "type": {
        "id": "10500",
        "name": "$linkTypeName",
        "inward": "is part of",
        "outward": "composes"
    },
    "inwardIssue": {
        "key": "$issueKeyInward"
    },
    "outwardIssue": {
        "key": "$issueKeyOutward"
    }
}
"@

        $sampleObject = ConvertFrom-Json -InputObject $sampleJson

        $r = ConvertTo-JiraIssueLink -InputObject $sampleObject
        It "Creates a PSObject out of JSON input" {
            $r | Should Not BeNullOrEmpty
        }

        checkPsType $r 'JiraPS.IssueLink'

        defProp $r 'Id' $issueLinkId
        defProp $r 'Type' "Composition"
        defProp $r 'InwardIssue' "[$issueKeyInward] "
        defProp $r 'OutwardIssue' "[$issueKeyOutward] "

        It "Handles pipeline input" {
            $r = $sampleObject | ConvertTo-JiraIssueLink
            @($r).Count | Should Be 1
        }
    }
}
