#requires -modules @{ ModuleName = "Pester"; ModuleVersion = "5.0" }

Import-Module "$PSScriptRoot/../../JiraPS" -Force
Import-Module "$PSScriptRoot/../../Tools/TestTools.psm1" -Force

Describe "ConvertTo-JiraServerInfo" -Tag 'Unit' {
    BeforeAll {
        $sampleObject = ConvertFrom-Json -InputObject @"
{
    "baseUrl": "https://powershell.atlassian.net",
    "version": "1001.0.0-SNAPSHOT",
    "versionNumbers": [
        1001,
        0,
        0
    ],
    "deploymentType": "Cloud",
    "buildNumber": 100156,
    "buildDate": "2021-04-08T13:31:02.000+0200",
    "serverTime": "2021-04-11T12:47:54.115+0200",
    "scmInfo": "ef0510686cf40db0fbe60fe0292e60df05ead372",
    "serverTitle": "JIRA",
    "defaultLocale": {
        "locale": "en_US"
    }
}
"@
    }

    Describe "Instanciating an object" {
        It "Creates a new instance via typed input" { }

        It "Creates a new instance via hashtable" {
            [AtlassianPS.JiraPS.ServerInfo]@{
                BaseUrl        = "https://powershell.atlassian.net"
                Version        = "1001.0.0-SNAPSHOT"
                DeploymentType = "Cloud"
                ServerTitle    = "JIRA"
            } | Should -BeOfType [AtlassianPS.JiraPS.ServerInfo]
        }
    }

    Describe "Conversion of InputObject" {
        BeforeAll {
            $serverInfo = InModuleScope JiraPS {
                param($sampleObject)
                ConvertTo-JiraServerInfo -InputObject $sampleObject
            } -Parameters @{ sampleObject = $sampleObject }
        }

        It "can convert to ServerInfo object" {
            $serverInfo | Should -HaveCount 1
        }

        It "returns an object of type [AtlassianPS.JiraPS.ServerInfo]" {
            $serverInfo | Should -BeOfType [AtlassianPS.JiraPS.ServerInfo]
        }

        It 'converts nested types' { }
    }

    Describe "Return the expected format" {
        BeforeEach {
            $serverInfo = InModuleScope JiraPS {
                param($sampleObject)
                ConvertTo-JiraServerInfo -InputObject $sampleObject
            } -Parameters @{ sampleObject = $sampleObject }
        }

        It "has a property '<property>' with value '<value>' of type '<type>'" -ForEach @(
            @{ property = 'BaseURL'; value = 'https://powershell.atlassian.net/' }
            @{ property = 'Version'; value = '1001.0.0-SNAPSHOT' }
            @{ property = 'DeploymentType'; value = 'Cloud'; type = 'AtlassianPS.DeploymentType' }
            @{ property = 'BuildNumber'; value = '100156' }
            @{ property = 'BuildDate'; type = 'DateTime' }
            @{ property = 'ServerTime'; type = 'DateTime' }
            @{ property = 'ScmInfo'; value = 'ef0510686cf40db0fbe60fe0292e60df05ead372' }
            @{ property = 'ServerTitle'; value = 'JIRA' }
        ) {
            $serverInfo.PSObject.Properties.Name | Should -Contain $property
            if ($value) {
                $serverInfo.$property | Should -Be $value
            }
            if ($type) {
                , ($serverInfo.$property) | Should -BeOfType $type
            }
        }

        It "prints nicely to string" {
            $serverInfo.ToString() | Should -Be 'JIRA <https://powershell.atlassian.net/> v1001.0.0-SNAPSHOT [Cloud]'
        }
    }
}
