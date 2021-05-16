#requires -modules @{ ModuleName = "Pester"; ModuleVersion = "5.0" }

Import-Module "$PSScriptRoot/../../JiraPS" -Force
Import-Module "$PSScriptRoot/../../Tools/TestTools.psm1" -Force

Describe 'Add-JiraFilterPermission' -Tag 'Unit' {
    BeforeAll {
        #region Definitions
        $permissionJSON = @'
[
    {
    "id": 10000,
    "type": "global"
    },
    {
    "id": 10010,
    "type": "project",
    "project": {
        "self": "https://jira.example.com/jira/rest/api/2/project/EX",
        "id": "10000",
        "key": "EX",
        "name": "Example",
        "avatarUrls": {
        },
        "projectCategory": {
        "self": "https://jira.example.com/jira/rest/api/2/projectCategory/10000",
        "id": "10000",
        "name": "FIRST",
        "description": "First Project Category"
        },
        "simplified": false
    }
    },
    {
    "id": 10010,
    "type": "project",
    "project": {
        "self": "https://jira.example.com/jira/rest/api/2/project/MKY",
        "id": "10002",
        "key": "MKY",
        "name": "Example",
        "avatarUrls": {
        },
        "projectCategory": {
        "self": "https://jira.example.com/jira/rest/api/2/projectCategory/10000",
        "id": "10000",
        "name": "FIRST",
        "description": "First Project Category"
        },
        "simplified": false
    },
    "role": {
        "self": "https://jira.example.com/jira/rest/api/2/project/MKY/role/10360",
        "name": "Developers",
        "id": 10360,
        "description": "A project role that represents developers in a project",
        "actors": [
        {
            "id": 10240,
            "displayName": "jira-developers",
            "type": "atlassian-group-role-actor",
            "name": "jira-developers"
        },
        {
            "id": 10241,
            "displayName": "Fred F. User",
            "type": "atlassian-user-role-actor",
            "name": "fred"
        }
        ]
    }
    },
    {
    "id": 10010,
    "type": "group",
    "group": {
        "name": "jira-administrators",
        "self": "https://jira.example.com/jira/rest/api/2/group?groupname=jira-administrators"
    }
    }
]
'@
        #endregion Definitions

        #region Mocks
        Add-CommonMocks
        Add-MockGetJiraConfigServer
        Add-MockGetJiraFilter
        Add-MockGetJiraProject
        Add-MockGetJiraRole

        Mock ConvertTo-JiraFilter -ModuleName "JiraPS" { $mockedJiraFilter }

        Mock Invoke-JiraMethod -ParameterFilter {
            $Method -eq 'Post' -and
            $URI -like '*/filter/*/permission'
        } {
            Write-MockInfo 'Invoke-JiraMethod' @{ Method = $Method; Uri = $Uri; Body = $Body }
        }
        #endregion Mocks
    }

    Describe 'Behavior testing' {
        BeforeAll {
            $filter = $mockedJiraFilter

            $assertMockCalledSplat = @{
                CommandName     = 'Invoke-JiraMethod'
                ModuleName      = 'JiraPS'
                Exactly         = $true
                Times           = 1
                Scope           = 'It'
                ParameterFilter = {
                    $Method -eq 'Post' -and
                    $URI -like '*/rest/api/*/filter/*/permission'
                }
            }
        }

        It 'Adds global share permission to Filter Object' {
            Add-JiraFilterPermission -Filter $filter -Global -ErrorAction Stop

            Assert-MockCalled @assertMockCalledSplat
        }

        It 'Adds authenticated share permission to Filter Object' {
            Add-JiraFilterPermission -Filter $filter -Authenticated -ErrorAction Stop

            Assert-MockCalled @assertMockCalledSplat
        }

        It 'Adds project share permission to Filter Object' {
            Add-JiraFilterPermission -Filter $filter -Project 'TV' -ErrorAction Stop

            Assert-MockCalled @assertMockCalledSplat
        }

        It 'Adds project and role share permission to Filter Object' {
            Add-JiraFilterPermission -Filter $filter -Project 'TV' -Role 'Administrators'  -ErrorAction Stop

            Assert-MockCalled @assertMockCalledSplat
        }

        It 'Adds group share permission to Filter Object' {
            Add-JiraFilterPermission -Filter $filter -Group 'Administrators' -ErrorAction Stop

            Assert-MockCalled @assertMockCalledSplat
        }
    }

    Describe 'Input testing' {
        BeforeAll {
            $filter = $mockedJiraFilter
        }

        It "can find a filter by it's Id" {
            Add-JiraFilterPermission -Filter 12844 -Global -ErrorAction Stop
        }

        It 'fetches the Filter if an incomplete object was provided' {
            Add-JiraFilterPermission -Filter 'My Filter' -Global -ErrorAction Stop

            Assert-MockCalled -CommandName Get-JiraFilter -ModuleName 'JiraPS' -Exactly -Times 1 -Scope It
        }

        It 'uses the provided Filter when a complete object was provided' {
            Add-JiraFilterPermission -Filter $filter -Global -ErrorAction Stop

            Assert-MockCalled -CommandName Get-JiraFilter -ModuleName 'JiraPS' -Exactly -Times 0 -Scope It
        }

        It 'fetches the Project if an incomplete object was provided' {
            Add-JiraFilterPermission -Filter $filter -Project 'TV' -ErrorAction Stop
            Add-JiraFilterPermission -Filter $filter -Project 10001 -ErrorAction Stop

            Assert-MockCalled -CommandName Get-JiraProject -ModuleName 'JiraPS' -Exactly -Times 2 -Scope It
        }

        It 'uses the provided Project when a complete object was provided' {
            Add-JiraFilterPermission -Filter $filter -Project $mockedJiraProject -ErrorAction Stop

            Assert-MockCalled -CommandName Get-JiraProject -ModuleName 'JiraPS' -Exactly -Times 0 -Scope It
        }

        It 'fetches the Role if an incomplete object was provided' {
            Add-JiraFilterPermission -Filter $filter -Project 'TV' -Role 'Administrators' -ErrorAction Stop

            Assert-MockCalled -CommandName Get-JiraRole -ModuleName 'JiraPS' -Exactly -Times 1 -Scope It
        }

        It 'uses the provided Role when a complete object was provided' {
            Add-JiraFilterPermission -Filter $filter -Project $mockedJiraProject -Role $mockedJiraRole -ErrorAction Stop

            Assert-MockCalled -CommandName Get-JiraFilter -ModuleName 'JiraPS' -Exactly -Times 0 -Scope It
        }

        It "allows for the filter's Id to be passed over the pipeline" {
            $filter | Add-JiraFilterPermission -Global -ErrorAction Stop
        }

        It 'accepts the 5 known permission types' {
            Add-JiraFilterPermission -Filter $filter -Global -ErrorAction Stop
            Add-JiraFilterPermission -Filter $filter -Group 'Administrators' -ErrorAction Stop
            Add-JiraFilterPermission -Filter $filter -Project 'TV' -ErrorAction Stop
            Add-JiraFilterPermission -Filter $filter -Project 'TV' -Role 'Administrators' -ErrorAction Stop
            Add-JiraFilterPermission -Filter $filter -Authenticated -ErrorAction Stop
        }
    }

    Describe 'Forming of thr request' {
        BeforeAll {
            $filter = $mockedJiraFilter

            $assertMockCalledSplat = @{
                CommandName = 'Invoke-JiraMethod'
                ModuleName  = 'JiraPS'
                Exactly     = $true
                Times       = 1
                Scope       = 'It'
            }
        }

        It "constructs a valid request Body for type 'Global'" {
            Add-JiraFilterPermission -Filter $filter -Global -ErrorAction Stop

            Assert-MockCalled @assertMockCalledSplat -ParameterFilter {
                $Body -match '"type":"global"' -and
                $Body -notmatch ','
            }
        }

        It "constructs a valid request Body for type 'Authenticated'" {
            Add-JiraFilterPermission -Filter $filter -Authenticated -ErrorAction Stop

            Assert-MockCalled @assertMockCalledSplat -ParameterFilter {
                $Body -match '"type":"authenticated"' -and
                $Body -notmatch ','
            }
        }

        It "constructs a valid request Body for type 'Group'" {
            Add-JiraFilterPermission -Filter $filter -Group 'Administrators' -ErrorAction Stop

            Assert-MockCalled @assertMockCalledSplat -ParameterFilter {
                $Body -match '"type":"group"' -and
                $Body -match '"groupname":"Administrators"'
            }
        }

        It "constructs a valid request Body for type 'Project'" {
            Add-JiraFilterPermission -Filter $filter -Project $mockedJiraProject -ErrorAction Stop

            Assert-MockCalled @assertMockCalledSplat -ParameterFilter {
                $Body -match '"type":"project"' -and
                $Body -match '"projectId":20001'
            }
        }

        It "constructs a valid request Body for type 'ProjectRole'" {
            Add-JiraFilterPermission -Filter $filter -Project $mockedJiraProject -Role $mockedJiraRole -ErrorAction Stop

            Assert-MockCalled @assertMockCalledSplat -ParameterFilter {
                $Body -match '"type":"projectRole"' -and
                $Body -match '"projectId":20001' -and
                $Body -match '"projectRoleId":30001'
            }
        }
    }
}
