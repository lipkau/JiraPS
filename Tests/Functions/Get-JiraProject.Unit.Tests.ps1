#requires -modules @{ ModuleName = "Pester"; ModuleVersion = "5.0" }

Import-Module "$PSScriptRoot/../../JiraPS" -Force
Import-Module "$PSScriptRoot/../../Tools/TestTools.psm1" -Force

Describe "Get-JiraProject" -Tag 'Unit' {
    BeforeAll {
        #region Mocks
        Add-CommonMocks

        Add-MockGetJiraConfigServer

        Mock Invoke-JiraMethod -ParameterFilter {
            $Method -eq 'Get' -and
            $Uri -like "https://powershell.atlassian.net/rest/api/latest/project*"
        } {
            Write-MockInfo 'Invoke-JiraMethod' @{ Method = $Method; Uri = $Uri }
        }
        #endregion Mocks
    }

    Describe 'Behavior checking' {
        BeforeAll {
            $assertMockCalledSplat = @{
                CommandName = 'Invoke-JiraMethod'
                Exactly     = $true
                Times       = 1
                Scope       = 'It'
            }
        }

        It 'gets all projects' {
            Get-JiraProject

            Assert-MockCalled @assertMockCalledSplat
        }

        It 'gets a project by Key' {
            Get-JiraProject -Project 'TST'

            Assert-MockCalled @assertMockCalledSplat -ParameterFilter {
                $Uri -like "*/rest/api/*/project/TST"
            }
        }

        It 'gets a project by Id' {
            Get-JiraProject -Project '10001'

            Assert-MockCalled @assertMockCalledSplat -ParameterFilter {
                $Uri -like "*/rest/api/*/project/10001"
            }
        }

        It 'Converts results to [AtlassianPS.JiraPS.Project]' {
            Get-JiraProject
            Get-JiraProject -Project 'TST'
            Get-JiraProject -Project '10001'

            Assert-MockCalled @assertMockCalledSplat -ParameterFilter {
                $OutputType -like 'JiraProject'
            } -Times 3
        }
    }

    Describe 'Input testing' {
        BeforeAll {
            $assertMockCalledSplat = @{
                CommandName = 'Invoke-JiraMethod'
                Exactly     = $true
                Times       = 1
                Scope       = 'It'
            }
        }

        It 'accepts Project over the pipeline' {
            10001 | Get-JiraProject
            [AtlassianPS.JiraPS.Project]@{ Id = 10001 } | Get-JiraProject

            Assert-MockCalled @assertMockCalledSplat -ParameterFilter {
                $Uri -like "*/rest/api/*/project/10001"
            } -Times 2
        }
    }

    Describe 'Forming of the request' {
        BeforeAll {
            $assertMockCalledSplat = @{
                CommandName = 'Invoke-JiraMethod'
                Exactly     = $true
                Times       = 1
                Scope       = 'It'
            }
        }

        It 'uses query parameters to expand the right parameters' {
            Get-JiraProject

            Assert-MockCalled @assertMockCalledSplat -ParameterFilter {
                $GetParameter['expand'] -eq "description,lead,issueTypes,url"
            }
        }
    }
}
