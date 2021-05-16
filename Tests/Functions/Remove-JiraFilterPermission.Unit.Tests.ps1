#requires -modules @{ ModuleName = "Pester"; ModuleVersion = "5.0" }

Describe 'Remove-JiraFilterPermission' -Tag 'Unit' {

    BeforeAll {
        Import-Module "$PSScriptRoot/../../Tools/TestTools.psm1" -Force
        Invoke-InitTest $PSScriptRoot

        Import-Module "$PSScriptRoot/../../JiraPS" -Force
    }
    AfterAll {
        Invoke-TestCleanup
    }

    #region Definitions
    $jiraServer = "https://jira.example.com"

    $filterPermission1 = New-Object -TypeName PSCustomObject -Property @{ Id = 1111 }
    $filterPermission1.PSObject.TypeNames.Insert(0, 'JiraPS.FilterPermission')
    $filterPermission2 = New-Object -TypeName PSCustomObject -Property @{ Id = 2222 }
    $filterPermission2.Id = 2222
    $fullFilter = New-Object -TypeName PSCustomObject -Property @{
        Id                = 12345
        RestUrl           = "$jiraServer/rest/api/2/filter/12345"
        FilterPermissions = @(
            $filterPermission1
            $filterPermission2
        )
    }
    $fullFilter.PSObject.TypeNames.Insert(0, 'JiraPS.Filter')
    $basicFilter = New-Object -TypeName PSCustomObject -Property @{
        Id      = 23456
        RestUrl = "$jiraServer/rest/api/2/filter/23456"
    }
    $basicFilter.PSObject.TypeNames.Insert(0, 'JiraPS.Filter')

    #endregion Definitions

    #region Mocks
    Mock Get-JiraConfigServer -ModuleName JiraPS {
        $jiraServer
    }

    Mock Get-JiraFilter -ModuleName JiraPS {
        $basicFilter
    }

    Mock Get-JiraFilterPermission -ModuleName JiraPS {
        $fullFilter
    }

    Mock Invoke-JiraMethod -ModuleName JiraPS -ParameterFilter { $Method -eq 'Delete' -and $URI -like "$jiraServer/rest/api/*/filter/*/permission*" } {
        Write-MockInfo 'Invoke-JiraMethod' @{ Method = $Method; Uri = $Uri }
    }

    Mock Invoke-JiraMethod -ModuleName JiraPS {
        Write-MockInfo 'Invoke-JiraMethod' @{ Method = $Method; Uri = $Uri }
        throw "Unidentified call to Invoke-JiraMethod"
    }
    #endregion Mocks

    Describe "Sanity checking" {
        $command = Get-Command -Name Remove-JiraFilterPermission

        It "has a parameter 'Filter' of type [AtlassianPS.JiraPS.Filter]" {
            $command | Should -HaveParameter "Filter" -Type [AtlassianPS.JiraPS.Filter]
        }

        It "has an alias 'Id' for parameter 'Filter" {
            $command | Should -HaveParameter "Filter" -Alias "Id"
        }

        It "has a parameter 'Permission' of type [AtlassianPS.JiraPS.FilterPermission[]]" {
            $command | Should -HaveParameter "Permission" -Type [AtlassianPS.JiraPS.FilterPermission[]]
        }

        It "has a parameter 'Credential' of type [PSCredential]" {
            $command | Should -HaveParameter "Credential" -Type [PSCredential]
        }

    }

    Describe "Behavior testing" {
        It "Deletes Permission from Filter Object" {
            {
                Get-JiraFilterPermission -Id 1 | Remove-JiraFilterPermission
            } | Should -Not -Throw

            Assert-MockCalled -CommandName Invoke-JiraMethod -ModuleName JiraPS -Exactly -Times 1 -Scope It -ParameterFilter {
                $Method -eq 'Delete' -and
                $URI -like '*/rest/api/*/filter/12345/permission/1111'
            }
            Assert-MockCalled -CommandName Invoke-JiraMethod -ModuleName JiraPS -Exactly -Times 1 -Scope It -ParameterFilter {
                $Method -eq 'Delete' -and
                $URI -like '*/rest/api/*/filter/12345/permission/2222'
            }
        }

        It "Deletes Permission from FilterId + PermissionId" {
            {
                Remove-JiraFilterPermission -FilterId 1 -PermissionId 3333, 4444
            } | Should -Not -Throw

            Assert-MockCalled -CommandName Invoke-JiraMethod -ModuleName JiraPS -Exactly -Times 1 -Scope It -ParameterFilter {
                $Method -eq 'Delete' -and
                $URI -like '*/rest/api/*/filter/23456/permission/3333'
            }
            Assert-MockCalled -CommandName Invoke-JiraMethod -ModuleName JiraPS -Exactly -Times 1 -Scope It -ParameterFilter {
                $Method -eq 'Delete' -and
                $URI -like '*/rest/api/*/filter/23456/permission/4444'
            }
        }
    }

    Describe "Input testing" {
        It "validates the -Filter to ensure FilterPermissions" {
            { Remove-JiraFilterPermission -Filter (Get-JiraFilter -Id 1) } | Should -Throw
            { Remove-JiraFilterPermission -Filter (Get-JiraFilterPermission -Id 1) } | Should -Not -Throw
        }

        It "finds the filter by FilterId" {
            { Remove-JiraFilterPermission -FilterId 1 -PermissionId 1111 } | Should -Not -Throw

            Assert-MockCalled -CommandName Get-JiraFilter -ModuleName JiraPS -Exactly -Times 1 -Scope It
        }

        It "does not accept negative FilterIds" {
            { Remove-JiraFilterPermission -FilterId -1 -PermissionId 1111 } | Should -Throw
        }

        It "does not accept negative PermissionIds" {
            { Remove-JiraFilterPermission -FilterId 1 -PermissionId -1111 } | Should -Throw
        }

        It "can only process one FilterId" {
            { Remove-JiraFilterPermission -FilterId 1, 2 -PermissionId 1111 } | Should -Throw
        }

        It "can process multiple PermissionIds" {
            { Remove-JiraFilterPermission -FilterId 1 -PermissionId 1111, 2222 } | Should -Not -Throw
        }

        It "allows for the filter to be passed over the pipeline" {
            { Get-JiraFilterPermission -Id 1 | Remove-JiraFilterPermission } | Should -Not -Throw
        }

        It "can ony process one Filter objects" {
            $filter = @()
            $filter += Get-JiraFilterPermission -Id 1
            $filter += Get-JiraFilterPermission -Id 1

            { Remove-JiraFilterPermission -Filter $filter } | Should -Throw
        }

        It "resolves positional parameters" {
            { Remove-JiraFilterPermission 12345 1111 } | Should -Not -Throw

            Assert-MockCalled -CommandName Invoke-JiraMethod -ModuleName JiraPS -Exactly -Times 1 -Scope It

            $filter = Get-JiraFilterPermission -Id 1
            { Remove-JiraFilterPermission $filter } | Should -Not -Throw

            Assert-MockCalled -CommandName Invoke-JiraMethod -ModuleName JiraPS -Exactly -Times 3 -Scope It
        }
    }
}
