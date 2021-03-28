#requires -modules @{ ModuleName = "Pester"; ModuleVersion = "5.0" }

Import-Module "$PSScriptRoot/../../JiraPS" -Force
Import-Module "$PSScriptRoot/../../Tools/TestTools.psm1" -Force

Describe "Join-Hashtable" -Tag 'Unit' {
    Describe 'Behavior checking' {
        It "Joins to [Hashtable]s together" {
            $hashtable = InModuleScope JiraPS {
                $h1 = @{ Name = "Tony Stark" }
                $h2 = @{ Alias = "Ironman" }
                Join-Hashtable -InputObject $h1, $h2
            }

            $hashtable | Should -BeOfType [Hashtable]
            $hashtable | Should -HaveCount 1
            $hashtable.Name | Should -Be 'Tony Stark'
            $hashtable.Alias | Should -Be 'Ironman'
        }

        It "works with other IDictionary types" {
            $hashtable = InModuleScope JiraPS {
                $Dictionary = [System.Collections.Generic.Dictionary[String, String]]::New()
                $Dictionary['key1'] = 'Value1'
                $Dictionary['key2'] = 'Value2'
                $hash = @{ key3 = "Value3" }
                Join-Hashtable -InputObject $Dictionary, $hash
            }

            $hashtable | Should -BeOfType [Hashtable]
            $hashtable | Should -HaveCount 1
            $hashtable.key1 | Should -Be 'Value1'
            $hashtable.key2 | Should -Be 'Value2'
            $hashtable.key3 | Should -Be 'Value3'
        }

        It "accepts input over the pipeline" {
            $hashtable = InModuleScope JiraPS {
                $Dictionary = [System.Collections.Generic.Dictionary[String, String]]::New()
                $Dictionary['key1'] = 'Value1'
                $Dictionary['key2'] = 'Value2'
                $hash = @{ key3 = "Value3" }
                $Dictionary, $hash | Join-Hashtable
            }

            $hashtable | Should -BeOfType [Hashtable]
            $hashtable | Should -HaveCount 1
            $hashtable.key1 | Should -Be 'Value1'
            $hashtable.key2 | Should -Be 'Value2'
            $hashtable.key3 | Should -Be 'Value3'
        }
    }
}
