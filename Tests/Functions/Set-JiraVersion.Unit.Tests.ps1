#requires -modules @{ ModuleName = "Pester"; ModuleVersion = "5.0" }

Describe "Set-JiraVersion" -Tag 'Unit' {

    BeforeAll {
        Import-Module "$PSScriptRoot/../../Tools/TestTools.psm1" -Force
        Invoke-InitTest $PSScriptRoot

        Import-Module "$PSScriptRoot/../../JiraPS" -Force

        #Sample response from the server
        $versionResponse = @{
            "RestUrl"     = "http://jiraserver.example.com/rest/api/2/version/12345"
            "id"          = 16840
            "description" = "version 1.0"
            "name"        = "1.0"
            "archived"    = $false
            "released"    = $false
            "projectId"   = 12101
        }

        #region Mocking
        Invoke-CommonMocking

        Mock Get-JiraProject {
            [AtlassianPS.JiraPS.Project]@{ Key = "LDD"; Id = "12101" }
        }

        Mock Get-JiraVersion {
            [AtlassianPS.JiraPS.Version]@{
                "restUrl" = "http://jiraserver.example.com/rest/api/2/version/12345"
                "name"    = "v1.0"
            }
        }

        Mock Invoke-JiraMethod -ParameterFilter {
            $Method -eq 'Put' -and
            $URI -like "*/version/12345"
        } {
            Write-MockInfo 'Invoke-JiraMethod' @{ Method = $Method; Uri = $Uri; Body = $Body }
            [PSCustomObject]$versionResponse
        }
        #endregion Mocking
    }
    AfterAll {
        Invoke-TestCleanup
    }

    Describe "Behavior checking" {
        BeforeAll {
            $version = Get-JiraVersion -Project "TEST" -Name "v1" -ErrorAction Stop
            $project = Get-JiraProject -Project "TEST" -ErrorAction Stop
        }

        It "Changes a Version" {
            Set-JiraVersion -Version $version -Name "NewName" -ErrorAction Stop

            Assert-MockCalled -CommandName Invoke-JiraMethod -Exactly -Times 1 -Scope It -ParameterFilter {
                $Method -eq 'Put' -and
                $URI -like "*/version/12345" -and
                $OutputType -eq "JiraVersion"
            }
        }

        It "Changes a Version using the pipeline" {
            $version | Set-JiraVersion -Name "NewName" -ErrorAction Stop

            Assert-MockCalled -CommandName Invoke-JiraMethod -Exactly -Times 1 -Scope It -ParameterFilter {
                $Method -eq 'Put' -and
                $URI -like "*/version/12345" -and
                $OutputType -eq "JiraVersion"
            }
        }

        It "fetches the version if an incomplete object was provided" {
            Set-JiraVersion -Version "12345" -Name "NewName" -ErrorAction Stop

            Assert-MockCalled -CommandName Get-JiraVersion -Exactly -Times 1 -Scope It
        }

        It "uses the provided version when a complete object was provided" {
            $version | Set-JiraVersion -Name "NewName" -ErrorAction Stop

            Assert-MockCalled -CommandName Get-JiraVersion -Exactly -Times 0 -Scope It
        }

        It "fetches the project when an incomplete project was provided" {
            Set-JiraVersion -Version $version -Project "TEST" -ErrorAction Stop

            Assert-MockCalled -CommandName Get-JiraProject -Exactly -Times 1 -Scope It
        }

        It "uses the provided project when a complete project was provided" {
            $version | Set-JiraVersion -Project $project -ErrorAction Stop

            Assert-MockCalled -CommandName Get-JiraProject -Exactly -Times 0 -Scope It
        }

        It "returns a Version when using PassThru" {
            $r1 = Set-JiraVersion -Version $version -Project "TEST" -ErrorAction Stop
            $r2 = Set-JiraVersion -Version $version -Project "TEST" -ErrorAction Stop -PassThru

            $r1 | Should -BeNullOrEmpty
            $r2 | Should -Not -BeNullOrEmpty
        }
    }

    Describe "Input testing" {
        BeforeAll {
            $version = Get-JiraVersion -Project "TEST" -Name "v1" -ErrorAction Stop
        }

        It "Can change the name of a version" {
            Set-JiraVersion -Version $version -Name "new Name" -ErrorAction Stop
        }

        It "Can change the description of a version" {
            Set-JiraVersion -Version $version -Description "new description" -ErrorAction Stop
        }

        It "Can mark a version as archivied" {
            Set-JiraVersion -Version $version -Archived $true -ErrorAction Stop
            Set-JiraVersion -Version $version -Archived $false -ErrorAction Stop
        }

        It "Can mark a version as released" {
            Set-JiraVersion -Version $version -Released $true -ErrorAction Stop
            Set-JiraVersion -Version $version -Released $false -ErrorAction Stop
        }

        It "Can change the project of a version" {
            Set-JiraVersion -Version $version -Project TEST -ErrorAction Stop
        }

        It "Can set the release date of a version" {
            Set-JiraVersion -Version $version -ReleaseDate (Get-Date) -ErrorAction Stop
        }

        It "Can set the start date of a version" {
            Set-JiraVersion -Version $version -StartDate (Get-Date) -ErrorAction Stop
        }
    }
}
