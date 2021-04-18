#requires -modules @{ ModuleName = "Pester"; ModuleVersion = "5.0" }

Import-Module "$PSScriptRoot/../../JiraPS" -Force
Import-Module "$PSScriptRoot/../../Tools/TestTools.psm1" -Force

Describe "ConvertTo-JiraRole" -Tag 'Unit' {
    BeforeAll {
        $sampleObject = ConvertFrom-Json -InputObject  @"
{
    "self":"https://powershell.atlassian.net/rest/api/3/project/10102/role/10002",
    "name":"Administrators",
    "id":10002,
    "description":"A project role that represents administrators in a project",
    "actors":[
        {
            "id":10205,
            "displayName":"Admin User",
            "type":"atlassian-user-role-actor",
            "actorUser":{
                "accountId":"000000:00000-000-000-000-0000000"
            }
        },
        {
            "id": 10240,
            "displayName": "jira-developers",
            "type": "atlassian-group-role-actor",
            "name": "jira-developers"
        }
    ]
}
"@

        #region Mocks
        Mock ConvertTo-JiraRoleActor -ModuleName 'JiraPS' { [AtlassianPS.JiraPS.RoleActor]@{} }
        #endregion Mocks
    }

    Describe "Instanciating an object" {
        It "Creates a new instance via typed input" {
            [AtlassianPS.JiraPS.Role]"Admins" | Should -BeOfType [AtlassianPS.JiraPS.Role]
        }

        It "Creates a new instance via hashtable" {
            [AtlassianPS.JiraPS.Role]@{
                name        = "jira-developers"
                description = "A project role that represents administrators in a project"
            } | Should -BeOfType [AtlassianPS.JiraPS.Role]
        }
    }

    Describe "Conversion of InputObject" {
        BeforeAll {
            $role = InModuleScope JiraPS {
                param($sampleObject)
                ConvertTo-JiraRole -InputObject $sampleObject
            } -Parameters @{ sampleObject = $sampleObject }
        }

        It "can convert to Role object" {
            $role | Should -HaveCount 1
        }

        It "returns an object of type [AtlassianPS.JiraPS.Role]" {
            $role | Should -BeOfType [AtlassianPS.JiraPS.Role]
        }

        It 'converts nested types' {
            Assert-MockCalled -CommandName 'ConvertTo-JiraRoleActor' -ModuleName 'JiraPS' -Scope 'Describe' -Exactly -Times 1
        }
    }

    Describe "Return the expected format" {
        BeforeEach {
            $role = InModuleScope JiraPS {
                param($sampleObject)
                ConvertTo-JiraRole -InputObject $sampleObject
            } -Parameters @{ sampleObject = $sampleObject }
        }

        It "has a property '<property>' with value '<value>' of type '<type>'" -ForEach @(
            @{ property = 'Id'; value = '10002' }
            @{ property = 'name'; value = 'Administrators' }
            @{ property = 'description'; value = 'A project role that represents administrators in a project' }
            @{ property = 'actors'; type = 'AtlassianPS.JiraPS.RoleActor[]' }
            @{ property = 'RestUrl'; value = 'https://powershell.atlassian.net/rest/api/3/project/10102/role/10002' }
        ) {
            $role.PSObject.Properties.Name | Should -Contain $property
            if ($value) {
                $role.$property | Should -Be $value
            }
            if ($type) {
                , ($role.$property) | Should -BeOfType $type
            }
        }

        It "prints nicely to string" {
            $role.ToString() | Should -Be 'Administrators'
        }
    }
}
