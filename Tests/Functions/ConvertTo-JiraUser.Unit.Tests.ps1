#requires -modules @{ ModuleName = "Pester"; ModuleVersion = "5.0" }

Import-Module "$PSScriptRoot/../../JiraPS" -Force
Import-Module "$PSScriptRoot/../../Tools/TestTools.psm1" -Force

Describe "ConvertTo-JiraUser" -Tag 'Unit' {
    BeforeAll {
        $sampleObject = ConvertFrom-Json -InputObject @"
{
    "self":"http://jiraserver.example.com/rest/api/2/user?username=powershell-test",
    "key":"powershell-test",
    "accountId":"500058:1500a9f1-0000-42b3-0000-ab8900008d00",
    "name":"powershell-test",
    "emailAddress":"noreply@example.com",
    "avatarUrls":{
        "16x16":"https://avatar-cdn.atlassian.com/a35295e666453af3d0adb689d8da7934?s=16&d=https%3A%2F%2Fsecure.gravatar.com%2Favatar%2Fa35295e666453af3d0adb689d8da7934%3Fd%3Dmm%26s%3D16%26noRedirect%3Dtrue"
    },
    "displayName":"PowerShell Test User",
    "active":true,
    "timeZone":"Europe/Berlin",
    "locale":"en_US",
    "groups":{
        "size":2,
        "items":[
            {
                "name":"administrators",
                "self":"http://jiraserver.example.com/rest/api/2/group?groupname=administrators"
            },
            {
                "name":"balsamiq-mockups-editors",
                "self":"http://jiraserver.example.com/rest/api/2/group?groupname=balsamiq-mockups-editors"
            }
        ]
    },
    "applicationRoles":{
        "size":0,
        "items":[]
    },
    "expand":"groups,applicationRoles"
}
"@

        #region Mocks
        Mock ConvertTo-JiraAvatar -ModuleName 'JiraPS' { [AtlassianPS.JiraPS.Avatar]@{ } }
        #endregion Mocks
    }

    Describe "Instanciating an object" {
        It "Creates a new instance via typed input" {
            [AtlassianPS.JiraPS.User]"Unassigned" | Should -BeOfType [AtlassianPS.JiraPS.User]
            [AtlassianPS.JiraPS.User]"Default" | Should -BeOfType [AtlassianPS.JiraPS.User]
            [AtlassianPS.JiraPS.User]"500058:1500a9f1-0000-42b3-0000-ab8900008d00" | Should -BeOfType [AtlassianPS.JiraPS.User]
            [AtlassianPS.JiraPS.User]"admin@domain.com" | Should -BeOfType [AtlassianPS.JiraPS.User]
            [AtlassianPS.JiraPS.User]"admin" | Should -BeOfType [AtlassianPS.JiraPS.User]
        }

        It "Creates a new instance via hashtable" {
            [AtlassianPS.JiraPS.User]@{
                key          = 'powershell-test'
                accountId    = '500058:1500a9f1-0000-42b3-0000-ab8900008d00'
                name         = 'powershell-test'
                emailAddress = 'noreply@example.com'
                displayName  = 'PowerShell Test User'
            } | Should -BeOfType [AtlassianPS.JiraPS.User]
        }
    }

    Describe "Conversion of InputObject" {
        BeforeAll {
            $status = InModuleScope JiraPS {
                param($sampleObject)
                ConvertTo-JiraUser -InputObject $sampleObject
            } -Parameters @{ sampleObject = $sampleObject }
        }

        It "can convert to Status object" {
            $status | Should -HaveCount 1
        }

        It "returns an object of type [AtlassianPS.JiraPS.User]" {
            $status | Should -BeOfType [AtlassianPS.JiraPS.User]
        }

        It 'converts nested types' {
            Assert-MockCalled -CommandName 'ConvertTo-JiraAvatar' -ModuleName 'JiraPS' -Scope 'Describe' -Exactly -Times 1
        }
    }

    Describe "Return the expected format" {
        BeforeEach {
            $status = InModuleScope JiraPS {
                param($sampleObject)
                ConvertTo-JiraUser -InputObject $sampleObject
            } -Parameters @{ sampleObject = $sampleObject }
        }

        It "has a property '<property>' with value '<value>' of type '<type>'" -ForEach @(
            @{ property = 'Key'; value = 'powershell-test' }
            @{ property = 'AccountId'; value = '500058:1500a9f1-0000-42b3-0000-ab8900008d00' }
            @{ property = 'Name'; value = 'powershell-test' }
            @{ property = 'EmailAddress'; value = 'noreply@example.com' }
            @{ property = 'DisplayName'; value = 'PowerShell Test User' }
            @{ property = 'Active'; value = $true }
            @{ property = 'TimeZone'; value = 'Europe/Berlin' }
            @{ property = 'Locale'; value = 'en_US' }
            @{ property = 'Groups'; type = 'String[]' }
            @{ property = 'AccountType' }
            @{ property = 'Avatar'; Type = 'AtlassianPS.JiraPS.Avatar' }
            @{ property = 'restUrl'; value = 'http://jiraserver.example.com/rest/api/2/user?username=powershell-test' }
        ) {
            $status.PSObject.Properties.Name | Should -Contain $property
            if ($value) {
                $status.$property | Should -Be $value
            }
            if ($type) {
                , ($status.$property) | Should -BeOfType $type
            }
        }

        It "prints nicely to string" {
            $user1 = [AtlassianPS.JiraPS.User]"Unassigned"
            $user2 = [AtlassianPS.JiraPS.User]"Default"
            $user3 = [AtlassianPS.JiraPS.User]"500058:1500a9f1-0000-42b3-0000-ab8900008d00"
            $user4 = [AtlassianPS.JiraPS.User]"admin@domain.com"
            $user5 = [AtlassianPS.JiraPS.User]"admin"
            $user6 = [AtlassianPS.JiraPS.User]@{
                key          = 'powershell-test'
                accountId    = '500058:1500a9f1-0000-42b3-0000-ab8900008d00'
                name         = 'powershell-test'
                emailAddress = 'noreply@example.com'
                displayName  = 'PowerShell Test User'
            }
            $user7 = [AtlassianPS.JiraPS.User]@{
                accountId = "500058:1500a9f1-0000-42b3-0000-ab8900008d00"
                Key       = "admin"
            }
            $user8 = [AtlassianPS.JiraPS.User]@{
                accountId    = "500058:1500a9f1-0000-42b3-0000-ab8900008d00"
                Key          = "admin"
                EmailAddress = 'noreply@example.com'
            }
            $user9 = [AtlassianPS.JiraPS.User]@{
                accountId    = "500058:1500a9f1-0000-42b3-0000-ab8900008d00"
                Key          = "admin"
                EmailAddress = 'noreply@example.com'
                Name         = 'powershell-test'
            }
            $user10 = [AtlassianPS.JiraPS.User]@{
                accountId    = "500058:1500a9f1-0000-42b3-0000-ab8900008d00"
                Key          = "admin"
                EmailAddress = 'noreply@example.com'
                Name         = 'powershell-test'
                DisplayName  = 'PowerShell Test User'
            }

            $user1.ToString() | Should -Be 'Unassigned'
            $user2.ToString() | Should -Be 'Default Assignee'
            $user3.ToString() | Should -Be '500058:1500a9f1-0000-42b3-0000-ab8900008d00'
            $user4.ToString() | Should -Be 'admin@domain.com'
            $user5.ToString() | Should -Be 'admin'
            $user6.ToString() | Should -Be 'PowerShell Test User'
            $user7.ToString() | Should -Be 'admin'
            $user8.ToString() | Should -Be 'noreply@example.com'
            $user9.ToString() | Should -Be 'powershell-test'
            $user10.ToString() | Should -Be 'PowerShell Test User'
        }
    }

    Describe 'Custom behavior' {
        It 'Uses the correct identifier' {
            # TODO:
        }
    }
}

