#requires -modules @{ ModuleName = "Pester"; ModuleVersion = "5.0" }

Import-Module "$PSScriptRoot/../../JiraPS" -Force
Import-Module "$PSScriptRoot/../../Tools/TestTools.psm1" -Force

Describe "ConvertTo-JiraEditMetaField" -Tag 'Unit' {
    BeforeAll {
        $sampleObject = ConvertFrom-Json -InputObject @'
{
    "fields": {
        "summary": {
            "required": true,
            "schema": {
                "type": "string",
                "system": "summary"
            },
            "name": "Summary",
            "hasDefaultValue": false,
            "operations": [
                "set"
            ]
        },
        "priority": {
            "required": false,
            "schema": {
                "type": "priority",
                "system": "priority"
            },
            "name": "Priority",
            "hasDefaultValue": true,
            "operations": [
                "set"
            ],
            "allowedValues": [
                {
                    "self": "http://jiraserver.example.com/rest/api/2/priority/1",
                    "iconUrl": "http://jiraserver.example.com/images/icons/priorities/blocker.png",
                    "name": "Block",
                    "id": "1"
                },
                {
                    "self": "http://jiraserver.example.com/rest/api/2/priority/2",
                    "iconUrl": "http://jiraserver.example.com/images/icons/priorities/critical.png",
                    "name": "Critical",
                    "id": "2"
                },
                {
                    "self": "http://jiraserver.example.com/rest/api/2/priority/3",
                    "iconUrl": "http://jiraserver.example.com/images/icons/priorities/major.png",
                    "name": "Major",
                    "id": "3"
                },
                {
                    "self": "http://jiraserver.example.com/rest/api/2/priority/4",
                    "iconUrl": "http://jiraserver.example.com/images/icons/priorities/minor.png",
                    "name": "Minor",
                    "id": "4"
                },
                {
                    "self": "http://jiraserver.example.com/rest/api/2/priority/5",
                    "iconUrl": "http://jiraserver.example.com/images/icons/priorities/trivial.png",
                    "name": "Trivial",
                    "id": "5"
                }
            ]
        }
    }
}
'@
    }

    Describe "old tests" {
        BeforeAll {
            $r = InModuleScope JiraPS {
                param($sampleObject)
                ConvertTo-JiraEditMetaField -InputObject $sampleObject
            } -Parameters @{ sampleObject = $sampleObject }
        }

        It "Creates PSObjects out of JSON input" {
            $r | Should -Not -BeNullOrEmpty
            $r.Count | Should -Be 2
        }

        It "is of the expected type" {
            (Get-Member -InputObject $r[0]).TypeName | Should -Contain 'JiraPS.EditMetaField'
        }

        Describe "Data validation" {
            BeforeAll {
                # Our sample JSON includes two fields: summary and priority.
                $summary = $r | Where-Object -FilterScript { $_.Name -eq 'Summary' }
                $priority = $r | Where-Object -FilterScript { $_.Name -eq 'Priority' }
            }

            It "<property> has value <value>" -TestCases @(
                @{property = "Id"; value = 'summary' }
                @{property = "Name"; value = 'Summary' }
                @{property = "HasDefaultValue"; value = $false }
                @{property = "Required"; value = $true }
                @{property = "Operations"; value = @('set') }
            ) {
                param($property, $value)
                $summary.$property | Should -Be $value
            }

            It "Defines the 'Schema' property if available" {
                $summary.Schema | Should -Not -BeNullOrEmpty
                $priority.Schema | Should -Not -BeNullOrEmpty
            }

            It "Defines the 'AllowedValues' property if available" {
                $summary.AllowedValues | Should -BeNullOrEmpty
                $priority.AllowedValues | Should -Not -BeNullOrEmpty
            }
        }
    }
}
