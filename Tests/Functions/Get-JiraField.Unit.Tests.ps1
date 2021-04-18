#requires -modules @{ ModuleName = "Pester"; ModuleVersion = "5.0" }

Import-Module "$PSScriptRoot/../../JiraPS" -Force
Import-Module "$PSScriptRoot/../../Tools/TestTools.psm1" -Force

Describe "Get-JiraField" -Tag 'Unit' {
    BeforeAll {
        $fieldResponse = ConvertFrom-Json -InputObject @"
[
    {
        "id": "issuetype",
        "name": "Issue Type",
        "custom": false,
        "orderable": true,
        "navigable": true,
        "searchable": true,
        "clauseNames": [
            "issuetype",
            "type"
        ],
        "schema": {
            "type": "issuetype",
            "system": "issuetype"
        }
    },
    {
        "id": "project",
        "name": "Project",
        "custom": false,
        "orderable": false,
        "navigable": true,
        "searchable": true,
        "clauseNames": [
            "project"
        ],
        "schema": {
            "type": "project",
            "system": "project"
        }
    }
]
"@

        #region Mock
        Add-CommonMocks

        Add-MockGetJiraConfigServer

        Mock Invoke-JiraMethod -ParameterFilter {
            $Method -eq 'Get' -and
            $Uri -like "https://powershell.atlassian.net/rest/api/*/field"
        } {
            Write-MockInfo 'Invoke-JiraMethod' @{ Method = $Method; Uri = $Uri }
            $fieldResponse
        }
        #endregion Mock
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

        It 'Gets all Fields' {
            Get-JiraField | Should -HaveCount 2

            Assert-MockCalled @assertMockCalledSplat
        }

        It 'Only makes one request to the server when using the pipeline' {
            'issuetype', 'project' | Get-JiraField

            Assert-MockCalled @assertMockCalledSplat
        }

        It 'Gets the Field by Id' {
            Get-JiraField -Id "issuetype" | Should -HaveCount 1
        }

        It 'Gets the Field by Name' {
            Get-JiraField -Name "Issue Type" | Should -HaveCount 1
        }

        It 'accepts wilcards when filtering by Name' {
            Get-JiraField -Name "*e*" | Should -HaveCount 2
        }

        It 'Converts results to [AtlassianPS.JiraPS.Field]' {
            Get-JiraField
            Get-JiraField -Id "issuetype"
            Get-JiraField -Name "Issue Type"

            Assert-MockCalled @assertMockCalledSplat -ParameterFilter {
                $OutputType -eq 'JiraField'
            } -Times 3
        }
    }

    Describe 'Input testing' {
        It 'accepts Issues over the pipeline' {
            'Issue Type', 'project' | Get-JiraField
        }
    }

    Describe 'Forming of the request' { }
}
