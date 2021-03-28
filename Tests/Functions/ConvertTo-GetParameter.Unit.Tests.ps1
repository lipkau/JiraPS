#requires -modules @{ ModuleName = "Pester"; ModuleVersion = "5.0" }

Import-Module "$PSScriptRoot/../../JiraPS" -Force
Import-Module "$PSScriptRoot/../../Tools/TestTools.psm1" -Force

Describe "ConvertTo-GetParameter" -Tag 'Unit' {
    Describe 'Behavior checking' {
        It "creates a query string from a hashtable" {
            $queryString = InModuleScope JiraPS { ConvertTo-GetParameter -InputObject ([ordered]@{
                        pagination = $true
                        page       = 1
                        expand     = "transitions"
                    }) -ErrorAction Stop }

            $queryString | Should -Be '?pagination=true&page=1&expand=transitions'
        }

        It "accepts pipeline input" {
            InModuleScope JiraPS { ConvertTo-GetParameter @{ cool = $true } } | Should -Be '?cool=true'
        }

        It "can handle empty inputs" {
            InModuleScope JiraPS { ConvertTo-GetParameter @{} } | Should -Be '?'
        }
    }
}
