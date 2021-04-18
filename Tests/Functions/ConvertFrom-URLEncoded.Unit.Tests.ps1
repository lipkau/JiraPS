#requires -modules @{ ModuleName = "Pester"; ModuleVersion = "5.0" }

Import-Module "$PSScriptRoot/../../JiraPS" -Force
Import-Module "$PSScriptRoot/../../Tools/TestTools.psm1" -Force

Describe "ConvertFrom-URLEncoded" -Tag 'Unit' {
    Describe 'Behavior checking' {
        It "accepts pipeline input" {
            InModuleScope JiraPS { "lorem" | ConvertFrom-URLEncoded }
        }

        It "accepts multiple InputStrings" {
            InModuleScope JiraPS { ConvertFrom-URLEncoded -InputString "lorem", "ipsum" }
            InModuleScope JiraPS { "lorem", "ipsum" | ConvertFrom-URLEncoded }
        }
    }

    Describe "Handling of Outputs" {
        BeforeAll {
            $r1 = InModuleScope JiraPS { ConvertFrom-URLEncoded -InputString "Hello%20World%3F" }
            $r2 = InModuleScope JiraPS { "Who%20are%20you%3F", "Hey Jude" | ConvertFrom-URLEncoded }
            $r3 = InModuleScope JiraPS { ConvertFrom-URLEncoded -InputString "The%20Matrix", "Matrix%20Reloaded", "Matrix%20Revolution" }
        }

        It "returns as many objects as inputs where provided" {
            @($r1).Count | Should -Be 1
            @($r2).Count | Should -Be 2
            @($r3).Count | Should -Be 3
        }

        It "decodes URL encoded strings" {
            $r1 | Should -Be 'Hello World?'
        }
    }
}
