#requires -modules @{ ModuleName = "Pester"; ModuleVersion = "5.0" }

Import-Module "$PSScriptRoot/../../JiraPS" -Force
Import-Module "$PSScriptRoot/../../Tools/TestTools.psm1" -Force

Describe "Get-JiraProject" -Tag 'Unit' {
    BeforeAll {
        $rolesResponse = ConvertFrom-Json -InputObject @"
{
    "atlassian-addons-project-access": "https://powershell.atlassian.net/rest/api/2/project/10000/role/10300",
    "Service Desk Team": "https://powershell.atlassian.net/rest/api/2/project/10000/role/10101",
    "Developers": "https://powershell.atlassian.net/rest/api/2/project/10000/role/10200",
    "Service Desk Customers": "https://powershell.atlassian.net/rest/api/2/project/10000/role/10100",
    "Administrators": "https://powershell.atlassian.net/rest/api/2/project/10000/role/10002"
}
"@

        #region Mock
        Add-CommonMocks

        Mock Invoke-JiraMethod -ParameterFilter {
            $Method -eq 'GET' -and
            $URI -like '*/role*'
        } {
            Write-MockInfo 'Invoke-JiraMethod' @{ Method = $Method; Uri = $Uri; Body = $Body }
            $rolesResponse
        }
        #endregion Mock
    }

    Describe 'Behavior checking' {
        BeforeAll {
            $assertMockCalledSplat = @{
                CommandName = 'Invoke-JiraMethod'
                Exactly     = $true
                Scope       = 'It'
            }
        }

        It 'Gets all roles from a Project' {
            Get-JiraRole -Project 'TV' -ErrorAction Stop

            $assertMockCalledSplat['Times'] = 1
            $assertMockCalledSplat['ParameterFilter'] = {
                $URI -like '*/rest/api/*/project/*/role'
            }
            Assert-MockCalled @assertMockCalledSplat

            $assertMockCalledSplat['Times'] = 5
            $assertMockCalledSplat['ParameterFilter'] = {
                $URI -like '*/rest/api/*/project/10000/role/*'
            }
            Assert-MockCalled @assertMockCalledSplat
        }

        It 'Gets a Role by Id' {
            Get-JiraRole -Role '1000' -ErrorAction Stop

            $assertMockCalledSplat['Times'] = 1
            $assertMockCalledSplat['ParameterFilter'] = {
                $URI -like '*/rest/api/*/role/1000'
            }
            Assert-MockCalled @assertMockCalledSplat
        }
    }

    Describe 'Input testing' {
        It 'takes a Project as parameter' {
            Get-JiraRole 'TV' -ErrorAction Stop
            Get-JiraRole -Project 'TV' -ErrorAction Stop
            Get-JiraRole -Project $mockedJiraProject -ErrorAction Stop
        }

        It 'taks a Role as parameter' {
            Get-JiraRole -Role 1000 -ErrorAction Stop
            Get-JiraRole -Role 1000, 1001 -ErrorAction Stop
            Get-JiraRole -Role $mockedJiraRole -ErrorAction Stop
        }

        It 'accepts Issues over the pipeline' {
            $mockedJiraProject | Get-JiraRole -ErrorAction Stop
            $mockedJiraRole | Get-JiraRole -ErrorAction Stop
        }
    }

    Describe 'Forming of the request' { }
}
