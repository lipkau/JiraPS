#requires -modules @{ ModuleName = "Pester"; ModuleVersion = "5.0" }

Import-Module "$PSScriptRoot/../../JiraPS" -Force
Import-Module "$PSScriptRoot/../../Tools/TestTools.psm1" -Force

Describe "ConvertTo-JiraIssueType" -Tag 'Unit' {
    BeforeAll {
        $sampleObject = ConvertFrom-Json -InputObject @"
{
    "self": "http://jiraserver.example.com/rest/api/latest/issuetype/2",
    "id": 2,
    "description": "A test issue used for...well, testing",
    "iconUrl": "http://jiraserver.example.com/images/icons/issuetypes/newfeature.png",
    "name": "Test Issue Type",
    "subtask": false
}
"@
    }

    Describe "Instanciating an object" {
        It "Creates a new instance via typed input" {
            [AtlassianPS.JiraPS.IssueType]10001 | Should -BeOfType [AtlassianPS.JiraPS.IssueType]
            [AtlassianPS.JiraPS.IssueType]"10001" | Should -BeOfType [AtlassianPS.JiraPS.IssueType]
            [AtlassianPS.JiraPS.IssueType]"Bug" | Should -BeOfType [AtlassianPS.JiraPS.IssueType]
        }

        It "Creates a new instance via hashtable" {
            [AtlassianPS.JiraPS.IssueType]@{
                Id          = 10001
                Name        = 'Bug'
                Description = 'Buuuugs!'
            } | Should -BeOfType [AtlassianPS.JiraPS.IssueType]
        }
    }

    Describe "Conversion of InputObject" {
        BeforeAll {
            $issueType = InModuleScope JiraPS {
                param($sampleObject)
                ConvertTo-JiraIssueType -InputObject $sampleObject
            } -Parameters @{ sampleObject = $sampleObject }
        }

        It "can convert to IssueType object" {
            $issueType | Should -HaveCount 1
        }

        It "returns an object of type [AtlassianPS.JiraPS.IssueType]" {
            $issueType | Should -BeOfType [AtlassianPS.JiraPS.IssueType]
        }

        It 'converts nested types' { }
    }

    Describe "Return the expected format" {
        BeforeEach {
            $issueType = InModuleScope JiraPS {
                param($sampleObject)
                ConvertTo-JiraIssueType -InputObject $sampleObject
            } -Parameters @{ sampleObject = $sampleObject }
        }

        It "has a property '<property>' with value '<value>' of type '<type>'" -ForEach @(
            @{ property = 'Id'; value = '2' }
            @{ property = 'Name'; value = 'Test Issue Type' }
            @{ property = 'Description'; value = 'A test issue used for...well, testing' }
            @{ property = 'IconUrl'; value = 'http://jiraserver.example.com/images/icons/issuetypes/newfeature.png' }
            @{ property = 'Subtask'; value = $false }
            @{ property = 'restUrl'; value = 'http://jiraserver.example.com/rest/api/latest/issuetype/2' }
        ) {
            $issueType.PSObject.Properties.Name | Should -Contain $property
            if ($value) {
                $issueType.$property | Should -Be $value
            }
            if ($type) {
                , ($issueType.$property) | Should -BeOfType $type
            }
        }

        It "prints nicely to string" {
            $issueType1 = [AtlassianPS.JiraPS.IssueType]10001
            $issueType2 = [AtlassianPS.JiraPS.IssueType]"10001"
            $issueType3 = [AtlassianPS.JiraPS.IssueType]"Bug"
            $issueType4 = [AtlassianPS.JiraPS.IssueType]@{
                Id          = 10001
                Name        = 'Bug'
                Description = 'Buuuugs!'
            }

            $issueType1.ToString() | Should -Be 'id: 10001'
            $issueType2.ToString() | Should -Be 'id: 10001'
            $issueType3.ToString() | Should -Be 'Bug'
            $issueType4.ToString() | Should -Be 'Bug'
        }
    }
}
