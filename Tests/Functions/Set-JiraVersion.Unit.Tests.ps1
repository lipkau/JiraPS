#requires -modules BuildHelpers
#requires -modules @{ ModuleName = "Pester"; ModuleVersion = "4.10.1" }

Describe "Set-JiraVersion" -Tag 'Unit' {

    BeforeAll {
        Import-Module "$PSScriptRoot/../../../Tools/TestTools.psm1" -force
        Invoke-InitTest $PSScriptRoot

        Import-Module $env:BHManifestToTest -Force
    }
    AfterAll {
        Invoke-TestCleanup
    }

    #Sample response from the server
    <# {
        "self" : "http://jiraserver.example.com/rest/api/2/version/$versionID",
        "id" : 16840,
        "description" : "version 1.0",
        "name" : "1.0",
        "archived" : "False",
        "released" : "False",
        "projectId" : "12101"
    } #>

    #region Mocking
    Mock Get-JiraConfigServer -ModuleName $env:BHProjectName {
        'http://jiraserver.example.com'
    }

    $jiraServer = 'http://jiraserver.example.com'
    $versionName = '1.0.0.0'
    $versionID = '16840'
    $projectKey = 'LDD'
    $projectId = '12101'

    Mock Get-JiraProject -ModuleName $env:BHProjectName {
        $Projects = ConvertFrom-Json '{ "Key" : "LDD", "Id": "12101" }'
        $Projects.PSObject.TypeNames.Insert(0, 'JiraPS.Project')
        $Projects
    }

    Mock Get-JiraVersion -ModuleName $env:BHProjectName {
        ConvertFrom-Json '{ "restUrl" : "http://jiraserver.example.com/rest/api/2/version/12345", "name" : "v1.0" }'
    }

    Mock Invoke-JiraMethod -ModuleName $env:BHProjectName -ParameterFilter { $Method -eq 'Put' -and $URI -like "*/rest/api/*/version/12345" } {
        ShowMockInfo 'Invoke-JiraMethod' @{Method = $Method; Uri = $Uri }
        ConvertFrom-Json $testJsonOne
    }

    # Generic catch-all. This will throw an exception if we forgot to mock something.
    Mock Invoke-JiraMethod -ModuleName $env:BHProjectName {
        ShowMockInfo 'Invoke-JiraMethod' @{Method = $Method; Uri = $Uri }
        throw "Unidentified call to Invoke-JiraMethod"
    }
    #endregion Mocking

    Describe "Sanity checking" {
        $command = Get-Command -Name Set-JiraVersion

        It "has a parameter 'Version' of type [Object[]]" {
            $command | Should -HaveParameter "Version" -Type [Object[]]
        }

        It "has a parameter 'Name' of type [String]" {
            $command | Should -HaveParameter "Name" -Type [String]
        }

        It "has a parameter 'Description' of type [String]" {
            $command | Should -HaveParameter "Description" -Type [String]
        }

        It "has a parameter 'Archived' of type [Bool]" {
            $command | Should -HaveParameter "Archived" -Type [Bool]
        }

        It "has a parameter 'Released' of type [Bool]" {
            $command | Should -HaveParameter "Released" -Type [Bool]
        }

        It "has a parameter 'ReleaseDate' of type [DateTime]" {
            $command | Should -HaveParameter "ReleaseDate" -Type [DateTime]
        }

        It "has a parameter 'StartDate' of type [DateTime]" {
            $command | Should -HaveParameter "StartDate" -Type [DateTime]
        }

        It "has a parameter 'Project' of type [Object]" {
            $command | Should -HaveParameter "Project" -Type [Object]
        }

        It "has a parameter 'Credential' of type [PSCredential]" {
            $command | Should -HaveParameter "Credential" -Type [PSCredential]
        }
    }

    Describe "Behavior checking" {
        It "sets an Issue's Version Name" {
            $version = Get-JiraVersion -Project $projectKey -Name $versionName
            $results = Set-JiraVersion -Version $version -Name "NewName" -ErrorAction Stop
            $results | Should Not BeNullOrEmpty
            checkType $results "JiraPS.Version"
            Assert-MockCalled 'Get-JiraVersion' -Times 2 -Scope It -ModuleName JiraPS -Exactly
            Assert-MockCalled 'Get-JiraProject' -Times 0 -Scope It -ModuleName JiraPS -Exactly
            Assert-MockCalled 'ConvertTo-JiraVersion' -Times 3 -Scope It -ModuleName JiraPS -Exactly
            Assert-MockCalled 'Invoke-JiraMethod' -Times 1 -Scope It -ModuleName JiraPS -Exactly -ParameterFilter { $Method -eq 'Put' -and $URI -like "$jiraServer/rest/api/*/version/$versionID" }
        }
        It "sets an Issue's Version Name using the pipeline" {
            $results = Get-JiraVersion -Project $projectKey | Set-JiraVersion -Name "NewName" -ErrorAction Stop
            $results | Should Not BeNullOrEmpty
            checkType $results "JiraPS.Version"
            Assert-MockCalled 'Get-JiraVersion' -Times 2 -Scope It -ModuleName JiraPS -Exactly
            Assert-MockCalled 'Get-JiraProject' -Times 0 -Scope It -ModuleName JiraPS -Exactly
            Assert-MockCalled 'ConvertTo-JiraVersion' -Times 3 -Scope It -ModuleName JiraPS -Exactly
            Assert-MockCalled 'Invoke-JiraMethod' -Times 1 -Scope It -ModuleName JiraPS -Exactly -ParameterFilter { $Method -eq 'Put' -and $URI -like "$jiraServer/rest/api/*/version/$versionID" }
        }
        It "assert VerifiableMock" {
            Assert-VerifiableMock
        }
    }
}
