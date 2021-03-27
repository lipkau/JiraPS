#requires -modules @{ ModuleName = "Pester"; ModuleVersion = "5.0" }

Import-Module "$PSScriptRoot/../../JiraPS" -Force
Import-Module "$PSScriptRoot/../../Tools/TestTools.psm1" -Force

Describe "ConvertTo-JiraRoleActor" -Tag 'Unit' {
    BeforeAll {
        $sampleObject = ConvertFrom-Json -InputObject  @"
[
    {
        "id":188847,
        "displayName":"A Server User",
        "type":"atlassian-user-role-actor",
        "name":"a.user",
        "avatarUrl":"https://issuetracking.bsh-sdd.com/secure/useravatar?size=xsmall&avatarId=10122"
    },
    {
        "id":10205,
        "displayName":"A Cloud user",
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
"@
    }

    Describe "Instanciating an object" {
        It "Creates a new instance via typed input" { }

        It "Creates a new instance via hashtable" {
            [AtlassianPS.JiraPS.RoleActor]@{
                type = "AtlassianGroupRoleActor"
                name = "jira-developers"
            } | Should -BeOfType [AtlassianPS.JiraPS.RoleActor]
        }
    }

    Describe "Conversion of InputObject" {
        BeforeAll {
            $roleActor = InModuleScope JiraPS { param($sampleObject) ConvertTo-JiraRoleActor -InputObject $sampleObject } -Parameters @{ sampleObject = $sampleObject }
        }

        It "can convert to RoleActor object" {
            $roleActor | Should -HaveCount 3
        }

        It "returns an object of type [AtlassianPS.JiraPS.RoleActor]" {
            $roleActor | Should -BeOfType [AtlassianPS.JiraPS.RoleActor]
        }

        It 'converts nested types' { }
    }

    Describe "Return the expected format" {
        BeforeEach {
            $roleActor = InModuleScope JiraPS { param($sampleObject) ConvertTo-JiraRoleActor -InputObject $sampleObject } -Parameters @{ sampleObject = $sampleObject }
        }

        It "has a property '<property>' with value '<value>' of type '<type>'" -ForEach @(
            @{ property = 'Id'; value = '188847' }
            @{ property = 'displayName'; value = 'A Server User' }
            @{ property = 'type'; value = 'AtlassianUserRoleActor'; type = 'AtlassianPS.JiraPS.ActorType' }
            @{ property = 'name'; value = 'a.user' }
        ) {
            $roleActor[0].PSObject.Properties.Name | Should -Contain $property
            if ($value) {
                $roleActor[0].$property | Should -Be $value
            }
            if ($type) {
                , ($roleActor[0].$property) | Should -BeOfType $type
            }
        }

        It "set the 'name' property for cloud users" {
            $roleActor = InModuleScope JiraPS { param($sampleObject) ConvertTo-JiraRoleActor -InputObject $sampleObject } -Parameters @{ sampleObject = $sampleObject } | Select-Object

            $roleActor[1].name | Should -Be '000000:00000-000-000-000-0000000'
        }

        It "prints nicely to string" { }
    }
}
