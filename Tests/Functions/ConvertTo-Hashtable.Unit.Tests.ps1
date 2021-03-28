#requires -modules @{ ModuleName = "Pester"; ModuleVersion = "5.0" }

Import-Module "$PSScriptRoot/../../JiraPS" -Force
Import-Module "$PSScriptRoot/../../Tools/TestTools.psm1" -Force

Describe "ConvertTo-Hashtable" -Tag 'Unit' {
    Describe 'Behavior checking' {
        It "Creates a [Hashtable] out of a [PSCustomObject]" {
            $hashtable = InModuleScope JiraPS {
                $hero = [PSCustomObject]@{
                    Name  = "Tony Stark"
                    Alias = "Ironman"
                }
                ConvertTo-Hashtable -InputObject $hero
            }

            $hashtable | Should -BeOfType [Hashtable]
            $hashtable.Keys | Should -HaveCount 2
            $hashtable['Name'] = "Tony Stark"
            $hashtable['Alias'] = "Ironman"
        }

        It "accepts pipeline input" {
            $hashtable = InModuleScope JiraPS {
                $hero = [PSCustomObject]@{
                    Name  = "Tony Stark"
                    Alias = "Ironman"
                }
                $hero | ConvertTo-Hashtable
            }

            $hashtable | Should -BeOfType [Hashtable]
            $hashtable.Keys | Should -HaveCount 2
            $hashtable['Name'] = "Tony Stark"
            $hashtable['Alias'] = "Ironman"
        }
    }
}
