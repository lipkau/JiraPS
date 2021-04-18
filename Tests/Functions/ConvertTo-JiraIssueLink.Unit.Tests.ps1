#requires -modules @{ ModuleName = "Pester"; ModuleVersion = "5.0" }

Import-Module "$PSScriptRoot/../../JiraPS" -Force
Import-Module "$PSScriptRoot/../../Tools/TestTools.psm1" -Force

Describe "ConvertTo-JiraIssueLink" -Tag 'Unit' {
    BeforeAll {
        $sampleObject = ConvertFrom-Json -InputObject @"
{
    "id": "41313",
    "type": {
        "id": "10500",
        "name": "Composition",
        "inward": "is part of",
        "outward": "composes"
    },
    "inwardIssue": {
        "key": "TEST-01"
    },
    "outwardIssue": {
        "key": "TEST-10"
    },
    "self": "https://powershell.atlassian.net/rest/api/2/issueLink/10103"
}
"@

        #region Mocks
        Mock ConvertTo-JiraIssue -ModuleName 'JiraPS' { [AtlassianPS.JiraPS.Issue]@{} }

        Mock ConvertTo-JiraIssueLinkType -ModuleName 'JiraPS' { [AtlassianPS.JiraPS.IssueLinkType]@{} }
        #endregion Mocks
    }

    Describe "Instanciating an object" {
        It "Creates a new instance via typed input" { }

        It "Creates a new instance via hashtable" {
            [AtlassianPS.JiraPS.IssueLink]@{
                Id = 1001
            } | Should -BeOfType [AtlassianPS.JiraPS.IssueLink]
        }
    }

    Describe "Conversion of InputObject" {
        BeforeAll {
            $issueLink = InModuleScope JiraPS {
                param($sampleObject)
                ConvertTo-JiraIssueLink -InputObject $sampleObject
            } -Parameters @{ sampleObject = $sampleObject }
        }

        It "can convert to IssueLink object" {
            $issueLink | Should -HaveCount 1
        }

        It "returns an object of type [AtlassianPS.JiraPS.IssueLink]" {
            $issueLink | Should -BeOfType [AtlassianPS.JiraPS.IssueLink]
        }

        It 'converts nested types' {
            Assert-MockCalled -CommandName 'ConvertTo-JiraIssue' -ModuleName 'JiraPS' -Scope 'Describe' -Exactly -Times 2
            Assert-MockCalled -CommandName 'ConvertTo-JiraIssueLinkType' -ModuleName 'JiraPS' -Scope 'Describe' -Exactly -Times 1
        }
    }

    Describe "Return the expected format" {
        BeforeEach {
            $issueLink = InModuleScope JiraPS {
                param($sampleObject)
                ConvertTo-JiraIssueLink -InputObject $sampleObject
            } -Parameters @{ sampleObject = $sampleObject }
        }

        It "has a property '<property>' with value '<value>' of type '<type>'" -ForEach @(
            @{ property = 'id'; value = '41313' }
            @{ property = 'type'; type = 'AtlassianPS.JiraPS.IssueLinkType' }
            @{ property = 'inwardIssue'; type = 'AtlassianPS.JiraPS.Issue' }
            @{ property = 'outwardIssue'; type = 'AtlassianPS.JiraPS.Issue' }
            @{ property = 'RestUrl'; value = 'https://powershell.atlassian.net/rest/api/2/issueLink/10103' }
        ) {
            $issueLink.PSObject.Properties.Name | Should -Contain $property
            if ($value) {
                $issueLink.$property | Should -Be $value
            }
            if ($type) {
                , ($issueLink.$property) | Should -BeOfType $type
            }
        }

        It "prints nicely to string" {
            $issueLink.ToString() | Should -Be 'id: 41313'
        }
    }
}
