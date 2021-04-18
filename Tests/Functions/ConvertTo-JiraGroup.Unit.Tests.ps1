#requires -modules @{ ModuleName = "Pester"; ModuleVersion = "5.0" }

Import-Module "$PSScriptRoot/../../JiraPS" -Force
Import-Module "$PSScriptRoot/../../Tools/TestTools.psm1" -Force

Describe "ConvertTo-JiraGroup" -Tag 'Unit' {
    BeforeAll {
        $sampleObject = ConvertFrom-Json -InputObject @"
{
    "self": "http://jiraserver.example.com/rest/api/2/group?groupname=powershell-testgroup&expand=users",
    "name": "powershell-testgroup",
    "users": {
        "size": 1,
        "items": [
            {
                "self": "https://powershell.atlassian.net/rest/api/3/user?accountId=",
                "accountId": "0000",
                "avatarUrls": {
                    "48x48": "https://avatar-management--avatars.us-west-2.prod.public.atl-paas.net/0000/6e94ef09-3d54-42e0-959b-4519283d6949/48",
                    "24x24": "https://avatar-management--avatars.us-west-2.prod.public.atl-paas.net/0000/6e94ef09-3d54-42e0-959b-4519283d6949/24",
                    "16x16": "https://avatar-management--avatars.us-west-2.prod.public.atl-paas.net/0000/6e94ef09-3d54-42e0-959b-4519283d6949/16",
                    "32x32": "https://avatar-management--avatars.us-west-2.prod.public.atl-paas.net/0000/6e94ef09-3d54-42e0-959b-4519283d6949/32"
                },
                "displayName": "Frank Zappa",
                "active": true,
                "timeZone": "Europe/Berlin",
                "accountType": "atlassian"
            },
        ],
        "max-results": 50,
        "start-index": 0,
        "end-index": 0
    },
    "expand": "users"
}
"@

        #region Mocks
        Add-MockConvertToJiraUser
        #endregion Mocks
    }

    Describe "Instanciating an object" {
        It "Creates a new instance via typed input" {
            [AtlassianPS.JiraPS.Group]"Admins" | Should -BeOfType [AtlassianPS.JiraPS.Group]
        }

        It "Creates a new instance via hashtable" {
            [AtlassianPS.JiraPS.Group]@{
                Name   = "Admins"
                Member = @($mockedJiraCloudUser)
            } | Should -BeOfType [AtlassianPS.JiraPS.Group]
        }
    }

    Describe "Conversion of InputObject" {
        BeforeAll {
            $group = InModuleScope JiraPS {
                param($sampleObject)
                ConvertTo-JiraGroup -InputObject $sampleObject
            } -Parameters @{ sampleObject = $sampleObject }
        }

        It "can convert to Group object" {
            $group | Should -HaveCount 1
        }

        It "returns an object of type [AtlassianPS.JiraPS.Group]" {
            $group | Should -BeOfType [AtlassianPS.JiraPS.Group]
        }

        It 'converts nested types' {
            Assert-MockCalled -CommandName 'ConvertTo-JiraUser' -ModuleName 'JiraPS' -Scope 'Describe' -Exactly -Times 1
        }
    }

    Describe "Return the expected format" {
        BeforeEach {
            $group = InModuleScope JiraPS {
                param($sampleObject)
                ConvertTo-JiraGroup -InputObject $sampleObject
            } -Parameters @{ sampleObject = $sampleObject }
        }

        It "has a property '<property>' with value '<value>' of type '<type>'" -ForEach @(
            @{ property = 'Name'; value = 'powershell-testgroup' }
            @{ property = 'Member'; type = 'AtlassianPS.JiraPS.User[]' }
            @{ property = 'Size'; value = 1 }
            @{ property = 'RestUrl'; value = 'http://jiraserver.example.com/rest/api/2/group?groupname=powershell-testgroup&expand=users' }
        ) {
            $group.PSObject.Properties.Name | Should -Contain $property
            if ($value) {
                $group.$property | Should -Be $value
            }
            if ($type) {
                , ($group.$property) | Should -BeOfType $type
            }
        }

        It "prints nicely to string" {
            $group.ToString() | Should -Be 'powershell-testgroup'
        }
    }
}
