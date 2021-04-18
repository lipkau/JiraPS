#requires -modules @{ ModuleName = "Pester"; ModuleVersion = "5.0" }

Import-Module "$PSScriptRoot/../../JiraPS" -Force
Import-Module "$PSScriptRoot/../../Tools/TestTools.psm1" -Force

Describe "ConvertTo-JiraFilter" -Tag 'Unit' {
    BeforeAll {
        $sampleObject = ConvertFrom-Json -InputObject @'
{
    "self": "https://jira.atlassian.com/rest/api/latest/filter/12844",
    "id": "12844",
    "name": "All JIRA Bugs",
    "owner": {
        "self": "https://jira.atlassian.com/rest/api/2/user?username=scott@atlassian.com",
        "key": "scott@atlassian.com",
        "name": "scott@atlassian.com",
        "avatarUrls": {
            "16x16": "https://jira.atlassian.com/secure/useravatar?size=xsmall&avatarId=10612",
            "24x24": "https://jira.atlassian.com/secure/useravatar?size=small&avatarId=10612",
            "32x32": "https://jira.atlassian.com/secure/useravatar?size=medium&avatarId=10612",
            "48x48": "https://jira.atlassian.com/secure/useravatar?avatarId=10612"
        },
        "displayName": "Scott Farquhar [Atlassian]",
        "active": true
    },
    "jql": "project = 10240 AND issuetype = 1 ORDER BY key DESC",
    "viewUrl": "https://jira.atlassian.com/secure/IssueNavigator.jspa?mode=hide&requestId=12844",
    "searchUrl": "https://jira.atlassian.com/rest/api/latest/search?jql=project+%3D+10240+AND+issuetype+%3D+1+ORDER+BY+key+DESC",
    "favourite": false,
    "sharePermissions": [
        {
            "id": 10049,
            "type": "global"
        }
    ],
    "sharedUsers": {
        "size": 0,
        "items": [],
        "max-results": 1000,
        "start-index": 0,
        "end-index": 0
    },
    "subscriptions": {
        "size": 0,
        "items": [],
        "max-results": 1000,
        "start-index": 0,
        "end-index": 0
    }
}
'@

        #region Mocks
        Add-MockConvertToJiraUser
        #endregion Mocks
    }

    Describe "Instanciating an object" {
        It "Creates a new instance via typed input" {
            $filter1 = [AtlassianPS.JiraPS.Filter]"1001"
            $filter2 = [AtlassianPS.JiraPS.Filter]100100
            $filter3 = [AtlassianPS.JiraPS.Filter]"My Filter"

            $filter1, $filter2, $filter3 | Should -BeOfType [AtlassianPS.JiraPS.Filter]

            $filter1.Id | Should -Be 1001
            $filter1.Name | Should -Be $null

            $filter2.Id | Should -Be 100100
            $filter2.Name | Should -Be $null

            $filter3.Id | Should -Be 0
            $filter3.Name | Should -Be 'My Filter'

        }

        It "Creates a new instance via hashtable" {
            [AtlassianPS.JiraPS.Filter]@{
                Id    = '10001'
                Name  = 'My Filter'
                Owner = $mockedJiraCloudUser
            } | Should -BeOfType [AtlassianPS.JiraPS.Filter]
        }
    }

    Describe "Conversion of InputObject" {
        BeforeAll {
            $filter = InModuleScope JiraPS {
                param($sampleObject)
                ConvertTo-JiraFilter -InputObject $sampleObject
            } -Parameters @{ sampleObject = $sampleObject }
        }

        It "can convert to Filter object" {
            $filter | Should -HaveCount 1
        }

        It "returns an object of type [AtlassianPS.JiraPS.Filter]" {
            $filter | Should -BeOfType [AtlassianPS.JiraPS.Filter]
        }

        It 'converts nested types' {
            Assert-MockCalled -CommandName 'ConvertTo-JiraUser' -ModuleName 'JiraPS' -Scope 'Describe' -Exactly -Times 1
        }
    }

    Describe "Return the expected format" {
        BeforeEach {
            $filter = InModuleScope JiraPS {
                param($sampleObject)
                ConvertTo-JiraFilter -InputObject $sampleObject
            } -Parameters @{ sampleObject = $sampleObject }
        }

        It "has a property '<property>' with value '<value>' of type '<type>'" -ForEach @(
            @{ property = 'Id'; value = '12844' }
            @{ property = 'Name'; value = 'All JIRA Bugs' }
            @{ property = 'Owner'; type = 'AtlassianPS.JiraPS.User' }
            @{ property = 'JQL'; value = 'project = 10240 AND issuetype = 1 ORDER BY key DESC' }
            @{ property = 'Favorite'; value = $false; type = 'Boolean' }
            @{ property = 'Favourite'; value = $false; type = 'Boolean' }
            @{ property = 'SharePermissions'; type = 'AtlassianPS.JiraPS.FilterPermission[]' }
            @{ property = 'ViewUrl'; value = 'https://jira.atlassian.com/secure/IssueNavigator.jspa?mode=hide&requestId=12844' }
            @{ property = 'SearchUrl'; value = 'https://jira.atlassian.com/rest/api/latest/search?jql=project+%3D+10240+AND+issuetype+%3D+1+ORDER+BY+key+DESC' }
            @{ property = 'RestUrl'; value = 'https://jira.atlassian.com/rest/api/latest/filter/12844' }
        ) {
            $filter.PSObject.Properties.Name | Should -Contain $property
            if ($value) {
                $filter.$property | Should -Be $value
            }
            if ($type) {
                , ($filter.$property) | Should -BeOfType $type
            }
        }

        It "prints nicely to string" {
            $filter1 = [AtlassianPS.JiraPS.Filter]"1001"
            $filter2 = [AtlassianPS.JiraPS.Filter]100100
            $filter3 = [AtlassianPS.JiraPS.Filter]"My Filter"
            $filter4 = [AtlassianPS.JiraPS.Filter]@{
                Id   = 1000
                Name = 'My Filter'
            }

            $filter1.ToString() | Should -Be 'id: 1001'
            $filter2.ToString() | Should -Be 'id: 100100'
            $filter3.ToString() | Should -Be 'My Filter'
            $filter4.ToString() | Should -Be 'My Filter'
        }
    }
}
