#requires -modules @{ ModuleName = "Pester"; ModuleVersion = "5.0" }

Import-Module "$PSScriptRoot/../../JiraPS" -Force
Import-Module "$PSScriptRoot/../../Tools/TestTools.psm1" -Force

Describe "ConvertTo-JiraRemoteLink" -Tag 'Unit' {
    BeforeAll {
        $sampleObject = ConvertFrom-Json -InputObject @"
{
    "id": 10000,
    "self": "http://jiraserver.example.com/rest/api/issue/MKY-1/remotelink/10000",
    "globalId": "system=http://www.mycompany.com/support&id=1",
    "application": {
        "type": "com.acme.tracker",
        "name": "My Acme Tracker"
    },
    "relationship": "causes",
    "object": {
        "url": "http://www.mycompany.com/support?id=1",
        "title": "TSTSUP-111",
        "summary": "Crazy customer support issue"
    }
}
"@

        #region Mocks
        Mock ConvertTo-JiraRemoteObject -ModuleName 'JiraPS' { [AtlassianPS.JiraPS.RemoteObject]@{ } }
        #endregion Mocks
    }

    Describe "Instanciating an object" {
        It "Creates a new instance via typed input" { }

        It "Creates a new instance via hashtable" {
            [AtlassianPS.JiraPS.RemoteIssueLink]@{
                Id       = 10001
                GlobalId = 'system=http://www.mycompany.com/support&id=1'
            } | Should -BeOfType [AtlassianPS.JiraPS.RemoteIssueLink]
        }
    }

    Describe "Conversion of InputObject" {
        BeforeAll {
            $remoteIssueLink = InModuleScope JiraPS {
                param($sampleObject)
                ConvertTo-JiraRemoteLink -InputObject $sampleObject
            } -Parameters @{ sampleObject = $sampleObject }
        }

        It "can convert to Project object" {
            $remoteIssueLink | Should -HaveCount 1
        }

        It "returns an object of type [AtlassianPS.JiraPS.RemoteIssueLink]" {
            $remoteIssueLink | Should -BeOfType [AtlassianPS.JiraPS.RemoteIssueLink]
        }

        It 'converts nested types' {
            Assert-MockCalled -CommandName 'ConvertTo-JiraRemoteObject' -ModuleName 'JiraPS' -Exactly -Times 1 -Scope 'Describe'
        }
    }

    Describe "Return the expected format" {
        BeforeEach {
            $remoteIssueLink = InModuleScope JiraPS {
                param($sampleObject)
                ConvertTo-JiraRemoteLink -InputObject $sampleObject
            } -Parameters @{ sampleObject = $sampleObject }
        }

        It "has a property '<property>' with value '<value>' of type '<type>'" -ForEach @(
            @{ property = 'Id'; value = '10000' }
            @{ property = 'globalId'; value = 'system=http://www.mycompany.com/support&id=1' }
            @{ property = 'application'; type = 'Hashtable' }
            @{ property = 'relationship'; value = 'causes' }
            @{ property = 'Object'; type = 'AtlassianPS.JiraPS.RemoteObject' }
            @{ property = 'restUrl'; value = 'http://jiraserver.example.com/rest/api/issue/MKY-1/remotelink/10000' }
        ) {
            $remoteIssueLink.PSObject.Properties.Name | Should -Contain $property
            if ($value) {
                $remoteIssueLink.$property | Should -Be $value
            }
            if ($type) {
                , ($remoteIssueLink.$property) | Should -BeOfType $type
            }
        }

        It "prints nicely to string" { }
    }
}
