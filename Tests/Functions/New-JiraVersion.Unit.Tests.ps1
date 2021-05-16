#requires -modules @{ ModuleName = "Pester"; ModuleVersion = "5.0" }

Describe "New-JiraVersion" -Tag 'Unit' {

    BeforeAll {
        Import-Module "$PSScriptRoot/../../Tools/TestTools.psm1" -Force
        Invoke-InitTest $PSScriptRoot

        Import-Module "$PSScriptRoot/../../JiraPS" -Force
    }
    AfterAll {
        Invoke-TestCleanup
    }

    $jiraServer = 'http://jiraserver.example.com'
    $versionName = '1.0.0.0'
    $versionID = '16840'
    $projectKey = 'LDD'
    $projectId = '12101'

    $JiraProjectData = @"
[
    {
        "Key" : "$projectKey",
        "Id": "$projectId"
    },
    {
        "Key" : "foo",
        "Id": "99"
    }
]
"@
    $testJsonOne = @"
{
    "self" : "$jiraServer/rest/api/2/version/$versionID",
    "id" : $versionID,
    "description" : "$versionName",
    "name" : "$versionName",
    "archived" : "False",
    "released" : "False",
    "projectId" : "12101"
}
"@

    #region Mock
    Mock Get-JiraConfigServer -ModuleName JiraPS {
        Write-Output $jiraServer
    }

    Mock Get-JiraProject -ModuleName JiraPS {
        $Projects = ConvertFrom-Json $JiraProjectData
        $Projects | ForEach-Object { $_.PSObject.TypeNames.Insert(0, 'JiraPS.Project') }
        $Projects | Where-Object { $_.Key -in $projectKey }
    }

    Mock Get-JiraVersion -ModuleName JiraPS {
        $Version = [PSCustomObject]@{
            Name        = "v1"
            Description = "My Desccription"
            Project     = (Get-JiraProject -Project $projectKey)
            ReleaseDate = (Get-Date "2017-12-01")
            StartDate   = (Get-Date "2017-01-01")
            RestUrl     = "$jiraServer/rest/api/2/version/$versionID"
        }
        $Version.PSObject.TypeNames.Insert(0, 'JiraPS.Version')
        $Version
    }

    Mock ConvertTo-JiraVersion -ModuleName JiraPS {
        $result = New-Object -TypeName PSObject -Property @{
            Id      = $InputObject.Id
            Name    = $InputObject.name
            Project = $InputObject.projectId
            self    = "$jiraServer/rest/api/2/version/$($InputObject.self)"
        }
        $result.PSObject.TypeNames.Insert(0, 'JiraPS.Version')
        $result
    }

    Mock Invoke-JiraMethod -ModuleName JiraPS -ParameterFilter { $Method -eq 'Post' -and $URI -like "$jiraServer/rest/api/*/version" } {
        Write-MockInfo 'Invoke-JiraMethod' @{ Method = $Method; Uri = $Uri }
        ConvertFrom-Json $testJsonOne
    }

    # Generic catch-all. This will throw an exception if we forgot to mock something.
    Mock Invoke-JiraMethod -ModuleName JiraPS {
        Write-MockInfo 'Invoke-JiraMethod' @{ Method = $Method; Uri = $Uri }
        throw "Unidentified call to Invoke-JiraMethod"
    }
    #endregion Mock

    Describe "Sanity checking" {
        $command = Get-Command -Name New-JiraVersion

        It "has a parameter 'InputObject' of type [Object]" {
            $command | Should -HaveParameter "InputObject" -Type [Object]
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
        It "creates a Version from a Version Object" {
            $version = Get-JiraVersion -Project $projectKey
            $results = $version | New-JiraVersion -ErrorAction Stop
            $results | Should -Not -BeNullOrEmpty
            checkType $results "JiraPS.Version"
            Assert-MockCalled 'Invoke-JiraMethod' -Times 1 -Scope It -ModuleName JiraPS -Exactly -ParameterFilter { $Method -eq 'Post' -and $URI -like "$jiraServer/rest/api/latest/version" }
            Assert-MockCalled 'ConvertTo-JiraVersion' -Times 1 -Scope It -ModuleName JiraPS -Exactly
        }
        It "creates a Version using parameters" {
            $results = New-JiraVersion -Name $versionName -Project $projectKey -ErrorAction Stop
            $results | Should -Not -BeNullOrEmpty
            checkType $results "JiraPS.Version"
            Assert-MockCalled 'Invoke-JiraMethod' -Times 1 -Scope It -ModuleName JiraPS -Exactly -ParameterFilter { $Method -eq 'Post' -and $URI -like "$jiraServer/rest/api/latest/version" }
            Assert-MockCalled 'ConvertTo-JiraVersion' -Times 1 -Scope It -ModuleName JiraPS -Exactly
        }
        It "creates a Version using splatting" {
            $password = (ConvertTo-SecureString -AsPlainText -Force -String "password")
            $credentials = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList ("username", $password)
            $splat = @{
                Name        = "v1"
                Description = "A Description"
                Archived    = $false
                Released    = $true
                ReleaseDate = "2017-12-01"
                StartDate   = "2017-01-01"
                Project     = (Get-JiraProject -Project $projectKey)
                Credential  = $credentials
            }
            $results = New-JiraVersion @splat -ErrorAction Stop
            $results | Should -Not -BeNullOrEmpty
            checkType $results "JiraPS.Version"
            Assert-MockCalled 'Invoke-JiraMethod' -Times 1 -Scope It -ModuleName JiraPS -Exactly -ParameterFilter { $Method -eq 'Post' -and $URI -like "$jiraServer/rest/api/latest/version" }
            Assert-MockCalled 'ConvertTo-JiraVersion' -Times 1 -Scope It -ModuleName JiraPS -Exactly
        }

        It "assert VerifiableMock" {
            Assert-VerifiableMock
        }
    }
}
