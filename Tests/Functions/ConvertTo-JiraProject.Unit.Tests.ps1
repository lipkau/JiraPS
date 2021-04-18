#requires -modules @{ ModuleName = "Pester"; ModuleVersion = "5.0" }

Import-Module "$PSScriptRoot/../../JiraPS" -Force
Import-Module "$PSScriptRoot/../../Tools/TestTools.psm1" -Force

Describe "ConvertTo-JiraProject" -Tag 'Unit' {
    BeforeAll {
        $sampleObject = ConvertFrom-Json -InputObject @"
{
    "expand": "description,lead,url,projectKeys",
    "self": "http://jiraserver.example.com/rest/api/2/project/10003",
    "id": "10003",
    "key": "IT",
    "name": "Information Technology",
    "description": "some description",
    "lead": {
        "self":  "http://jiraserver.example.com/rest/api/2/user?username=admin",
        "key": "admin",
        "name": "admin",
    },
    "url": "http://jiraserver.example.com/browse/HCC/",
    "avatarUrls": {
        "48x48": "http://jiraserver.example.com/secure/projectavatar?pid=16802\u0026avatarId=10011",
        "24x24": "http://jiraserver.example.com/secure/projectavatar?size=small\u0026pid=16802\u0026avatarId=10011",
        "16x16": "http://jiraserver.example.com/secure/projectavatar?size=xsmall\u0026pid=16802\u0026avatarId=10011",
        "32x32": "http://jiraserver.example.com/secure/projectavatar?size=medium\u0026pid=16802\u0026avatarId=10011"
    },
    "projectKeys": "HCC",
    "projectCategory": {
        "self": "http://jiraserver.example.com/rest/api/latest/projectCategory/10000",
        "id":  "10000",
        "name":  "Home Connect",
        "description":  "Home Connect Projects"
    },
    "projectTypeKey": "software",
    "components": {
        "self": "http://jiraserver.example.com/rest/api/2/component/11000",
        "id": "11000",
        "description": "A test component",
        "name": "test component"
    }
}
"@

        #region Mocks
        Add-MockConvertToJiraComponent

        Add-MockConvertToJiraIssueType

        Add-MockConvertToJiraProjectCategory

        Add-MockConvertToJiraRole

        Add-MockConvertToJiraUser
        #endregion Mocks
    }

    Describe "Instanciating an object" {
        It "Creates a new instance via typed input" {
            [AtlassianPS.JiraPS.Project]10001 | Should -BeOfType [AtlassianPS.JiraPS.Project]
            [AtlassianPS.JiraPS.Project]"10001" | Should -BeOfType [AtlassianPS.JiraPS.Project]
            [AtlassianPS.JiraPS.Project]"TV" | Should -BeOfType [AtlassianPS.JiraPS.Project]
        }

        It "Creates a new instance via hashtable" {
            [AtlassianPS.JiraPS.Project]@{
                Id  = 10001
                Key = 'TV'
            } | Should -BeOfType [AtlassianPS.JiraPS.Project]
        }
    }

    Describe "Conversion of InputObject" {
        BeforeAll {
            $assertMockCalledSplat = @{
                ModuleName = 'JiraPS'
                Exactly    = $true
                Times      = 1
                Scope      = 'Describe'
            }

            $project = InModuleScope JiraPS {
                param($sampleObject)
                ConvertTo-JiraProject -InputObject $sampleObject
            } -Parameters @{ sampleObject = $sampleObject }
        }

        It "can convert to Project object" {
            $project | Should -HaveCount 1
        }

        It "returns an object of type [AtlassianPS.JiraPS.Project]" {
            $project | Should -BeOfType [AtlassianPS.JiraPS.Project]
        }

        It 'converts nested types' {
            Assert-MockCalled @assertMockCalledSplat -CommandName 'ConvertTo-JiraComponent'
            Assert-MockCalled @assertMockCalledSplat -CommandName 'ConvertTo-JiraIssueType' -Times 1
            Assert-MockCalled @assertMockCalledSplat -CommandName 'ConvertTo-JiraProjectCategory'
            Assert-MockCalled @assertMockCalledSplat -CommandName 'ConvertTo-JiraRole' -Times 1
            Assert-MockCalled @assertMockCalledSplat -CommandName 'ConvertTo-JiraUser'
        }
    }

    Describe "Return the expected format" {
        BeforeEach {
            $project = InModuleScope JiraPS {
                param($sampleObject)
                ConvertTo-JiraProject -InputObject $sampleObject
            } -Parameters @{ sampleObject = $sampleObject }
        }

        It "has a property '<property>' with value '<value>' of type '<type>'" -ForEach @(
            @{ property = 'Id'; value = '10003' }
            @{ property = 'key'; value = 'IT' }
            @{ property = 'name'; value = 'Information Technology' }
            @{ property = 'description' }
            @{ property = 'lead'; type = 'AtlassianPS.JiraPS.User' }
            @{ property = 'Category'; type = 'AtlassianPS.JiraPS.ProjectCategory' }
            @{ property = 'Components'; type = 'AtlassianPS.JiraPS.Component[]' }
            @{ property = 'restUrl'; value = 'http://jiraserver.example.com/rest/api/2/project/10003' }
        ) {
            $project.PSObject.Properties.Name | Should -Contain $property
            if ($value) {
                $project.$property | Should -Be $value
            }
            if ($type) {
                , ($project.$property) | Should -BeOfType $type
            }
        }

        It "prints nicely to string" {
            $project1 = [AtlassianPS.JiraPS.Project]10001
            $project2 = [AtlassianPS.JiraPS.Project]"10001"
            $project3 = [AtlassianPS.JiraPS.Project]"TV"
            $project4 = [AtlassianPS.JiraPS.Project]@{
                Id  = 10001
                Key = 'TV'
            }
            $project5 = [AtlassianPS.JiraPS.Project]@{
                Id   = 10001
                Key  = 'TV'
                Name = 'T Virus'
            }

            $project1.ToString() | Should -Be 'id: 10001'
            $project2.ToString() | Should -Be 'id: 10001'
            $project3.ToString() | Should -Be 'key: TV'
            $project4.ToString() | Should -Be 'key: TV'
            $project5.ToString() | Should -Be 'T Virus'
        }
    }
}
