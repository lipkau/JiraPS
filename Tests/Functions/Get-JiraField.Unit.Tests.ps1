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

        Mock Invoke-JiraMethod -ParameterFilter {
            $Method -eq 'Get' -and
            $Uri -like "*/rest/api/*/field"
        } {
            Write-MockInfo 'Invoke-JiraMethod' @{ Method = $Method; Uri = $Uri }
            $fieldResponse
        }
        #endregion Mock
    }

    Describe 'Behavior checking' {
        It 'Gets all Fields' {
            $fields = Get-JiraField | Should -HaveCount 2

            $assertMockCalledSplat = @{
                CommandName = 'Invoke-JiraMethod'
                Exactly     = $true
                Times       = 1
                Scope       = 'It'
            }
            Assert-MockCalled @assertMockCalledSplat
        }

        It 'Only makes one request to the server when using the pipeline' {
            'Issue Type', 'project' | Get-JiraField

            $assertMockCalledSplat = @{
                CommandName = 'Invoke-JiraMethod'
                Exactly     = $true
                Times       = 1
                Scope       = 'It'
            }
            Assert-MockCalled @assertMockCalledSplat
        }

        It 'Gets the Field by Id' {
            Get-JiraField -Field "issuetype" | Should -HaveCount 1
        }

        It 'Gets the Field by Name' {
            Get-JiraField -Field "Issue Type" | Should -HaveCount 1
        }
    }

    Describe 'Input testing' {
        It 'accepts Issues over the pipeline' {
            'Issue Type', 'project' | Get-JiraField -ErrorAction Stop
        }
    }

    Describe 'Forming of the request' {
    }

    Describe 'Return the expected type' {
        It 'converts the output to AtlassianPS.JiraPS.Field' {
            Get-JiraField

            $assertMockCalledSplat = @{
                CommandName     = 'Invoke-JiraMethod'
                Exactly         = $true
                Times           = 1
                Scope           = 'It'
                ParameterFilter = { $OutputType -eq 'JiraField' }
            }
            Assert-MockCalled @assertMockCalledSplat
        }
    }
}
