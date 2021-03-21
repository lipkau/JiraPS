#requires -modules Configuration
#requires -modules @{ ModuleName = "Pester"; ModuleVersion = "5.0" }

Describe "Validation of build environment" -Tag Unit {

    BeforeAll {
        Import-Module "$PSScriptRoot/../Tools/TestTools.psm1" -force
        Invoke-InitTest $PSScriptRoot

        Import-Module "$PSScriptRoot/../JiraPS" -Force
    }
    AfterAll {
        Invoke-TestCleanup
    }

    Describe "CHANGELOG" {
        BeforeAll {
            $changelogFile = "$PSScriptRoot/../CHANGELOG.md"
            if (-not (Test-Path $changelogFile)) {
                $changelogFile = "$PSScriptRoot/../JiraPS/CHANGELOG.md"
            }

            foreach ($line in (Get-Content $changelogFile -ErrorAction Stop)) {
                if ($line -match "(?:##|\<h2.*?\>)\s*\[(?<Version>(\d+\.?){1,2})\]") {
                    $changelogVersion = $matches.Version
                    break
                }
            }
        }

        It "has a changelog file" {
            $changelogFile | Should -Exist
        }

        It "has a valid version in the changelog" {
            $changelogVersion | Should -Not -BeNullOrEmpty
            [Version]($changelogVersion) | Should -BeOfType [Version]
        }

        It "has a version changelog that matches the manifest version" {
            $module = Get-Module JiraPS

            Configuration\Get-Metadata -Path "$($module.ModuleBase)/JiraPS.psd1" -PropertyName ModuleVersion | Should -BeLike "$changelogVersion*"
        }
    }
}
