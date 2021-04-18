#requires -modules @{ ModuleName = "Pester"; ModuleVersion = "5.0" }

Import-Module "$PSScriptRoot/../../JiraPS" -Force
Import-Module "$PSScriptRoot/../../Tools/TestTools.psm1" -Force

Describe "ConvertTo-JiraAttachment" -Tag 'Unit' {
    BeforeAll {
        $sampleObject = ConvertFrom-Json -InputObject  @"
{
    "self": "http://jiraserver.example.com/rest/api/2/attachment/270709",
    "id": "270709",
    "filename": "Nav2-HCF.PNG",
    "author": {
        "self": "http://jiraserver.example.com/rest/api/2/user?username=JonDoe",
        "name": "JonDoe",
        "key": "JonDoe",
        "emailAddress": "JonDoe@server.com",
        "AttachmentUrls": {},
        "displayName": "Doe, Jon",
        "active": true,
        "timeZone": "Europe/Berlin"
    },
    "created": "2017-05-30T11:20:34.000+0000",
    "size": 366272,
    "mimeType": "image/png",
    "content": "http://jiraserver.example.com/secure/attachment/270709/Nav2-HCF.PNG",
    "thumbnail": "http://jiraserver.example.com/secure/thumbnail/270709/_thumb_270709.png"
}
"@

        #region Mocks
        Add-MockConvertToJiraUser
        #endregion Mocks
    }

    Describe "Instanciating an object" {
        It "Creates a new instance via typed input" { }

        It "Creates a new instance via hashtable" {
            [AtlassianPS.JiraPS.Attachment]@{
                filename = "access.log"
                author   = $mockedJiraCloudUser
            } | Should -BeOfType [AtlassianPS.JiraPS.Attachment]
        }
    }

    Describe "Conversion of InputObject" {
        BeforeAll {
            $attachment = InModuleScope JiraPS {
                param($sampleObject)
                ConvertTo-JiraAttachment -InputObject $sampleObject
            } -Parameters @{ sampleObject = $sampleObject }
        }

        It "can convert to Attachment object" {
            $attachment | Should -HaveCount 1
        }

        It "returns an object of type [AtlassianPS.JiraPS.Attachment]" {
            $attachment | Should -BeOfType [AtlassianPS.JiraPS.Attachment]
        }

        It 'converts nested types' {
            Assert-MockCalled -CommandName 'ConvertTo-JiraUser' -ModuleName 'JiraPS' -Scope 'Describe' -Exactly -Times 1
        }
    }

    Describe "Return the expected format" {
        BeforeEach {
            $attachment = InModuleScope JiraPS {
                param($sampleObject)
                ConvertTo-JiraAttachment -InputObject $sampleObject
            } -Parameters @{ sampleObject = $sampleObject }
        }

        It "has a property '<property>' with value '<value>' of type '<type>'" -ForEach @(
            @{ property = 'Id'; value = '270709' }
            @{ property = 'FileName'; value = 'Nav2-HCF.PNG' }
            @{ property = 'mimeType'; value = 'image/png' }
            @{ property = 'created'; type = 'System.DateTime' }
            @{ property = 'author'; }
            @{ property = 'restUrl' }
            @{ property = 'size'; type = 'System.Int32' }
            @{ property = 'content' }
            @{ property = 'thumbnail' }
        ) {
            $attachment.PSObject.Properties.Name | Should -Contain $property
            if ($value) {
                $attachment.$property | Should -Be $value
            }
            if ($type) {
                , ($attachment.$property) | Should -BeOfType $type
            }
        }

        It "prints nicely to string" {
            $attachment.ToString() | Should -Be 'Nav2-HCF.PNG'
        }
    }
}
