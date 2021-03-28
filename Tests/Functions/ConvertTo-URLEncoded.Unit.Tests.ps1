#requires -modules @{ ModuleName = "Pester"; ModuleVersion = "5.0" }

Import-Module "$PSScriptRoot/../../JiraPS" -Force
Import-Module "$PSScriptRoot/../../Tools/TestTools.psm1" -Force

Describe "ConvertTo-URLEncoded" -Tag 'Unit' {
    BeforeAll {
    }

    Describe 'Behavior checking' {
        It "does not not allow a null or empty input" {
            { InModuleScope JiraPS { ConvertTo-URLEncoded -InputString $null } } | Should -Throw
            { InModuleScope JiraPS { ConvertTo-URLEncoded -InputString "" } } | Should -Throw
        }
        It "accepts pipeline input" {
            InModuleScope JiraPS { "lorem ipsum" | ConvertTo-URLEncoded }
        }
        It "accepts multiple InputStrings" {
            InModuleScope JiraPS { ConvertTo-URLEncoded -InputString "lorem", "ipsum" }
            InModuleScope JiraPS { "lorem", "ipsum" | ConvertTo-URLEncoded }
        }
    }
    Describe "Handling of Outputs" {
        BeforeAll {
            $r1 = InModuleScope JiraPS { ConvertTo-URLEncoded -InputString "Hello World?" }
            $r2 = InModuleScope JiraPS { "Who are you?", "Hey Jude" | ConvertTo-URLEncoded }
            $r3 = InModuleScope JiraPS { ConvertTo-URLEncoded -InputString "The Matrix", "Matrix Reloaded", "Matrix Revolution" }
        }
        It "returns as many objects as inputs where provided" {
            @($r1).Count | Should -Be 1
            @($r2).Count | Should -Be 2
            @($r3).Count | Should -Be 3
        }
        It "decodes URL encoded strings" {
            $r1 | Should -Be "Hello+World%3F"
        }
    }
}
