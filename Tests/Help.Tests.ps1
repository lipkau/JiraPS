#requires -modules @{ ModuleName = "Pester"; ModuleVersion = "5.0" }

Describe "Help tests" -Tag Documentation {

    BeforeAll {
        Import-Module "$PSScriptRoot/../Tools/TestTools.psm1" -force
        Invoke-InitTest $PSScriptRoot

        Import-Module "$PSScriptRoot/../JiraPS" -Force

        # $module = Get-Module JiraPS
        $defaultParams = @(
            'Verbose'
            'Debug'
            'ErrorAction'
            'WarningAction'
            'InformationAction'
            'ErrorVariable'
            'WarningVariable'
            'InformationVariable'
            'OutVariable'
            'OutBuffer'
            'PipelineVariable'
            'WhatIf'
            'Confirm'
        )
    }
    AfterAll {
        Invoke-TestCleanup
    }

    Describe "Help of public functions for <commandName>" -ForEach (Get-Command -Module JiraPS -CommandType Cmdlet, Function | Foreach-Object {
            @{
                Definition    = $_.Definition
                HelpUri       = $_.HelpUri
                Parameters    = $_.Parameters
                ParameterSets = $_.ParameterSets
                Help          = (Get-Help $_.Name -ErrorAction Stop)
                # commandName   = ($_.Name -replace $module.Prefix, '')
                commandName   = $_.Name
                markdownFile  = (Resolve-Path "$env:BHProjectPath/docs/en-US/commands/$($_.Name).md" -ErrorAction Stop)
            }
        }) {

        Describe "PlatyPS markdown files" {
            It "is described in a markdown file for" {
                Test-Path $markdownFile | Should -Be $true
            }

            It "has no platyPS template artifacts for" {
                $markdownFile | Should -Not -FileContentMatch '{{.*}}'
            }

            It "defines the frontmatter for the homepage for" {
                $markdownFile | Should -FileContentMatch "Module Name: JiraPS"
                $markdownFile | Should -FileContentMatchExactly "layout: documentation"
                $markdownFile | Should -FileContentMatch "permalink: /docs/JiraPS/commands/$commandName/"
            }
        }

        Describe "Documentation in code" {
            It "does not have Comment-Based Help" {
                # We use .EXAMPLE, as we test this extensivly and it is never auto-generated
                $Definition | Should -Not -BeNullOrEmpty
                $Pattern = [regex]::Escape(".EXAMPLE")

                $Definition | Should -Not -Match "^\s*$Pattern"
            }
        }

        # TODO: make this work again!
        Describe "Documentation from ExternalHelp" -Skip {
            It "has a link to the 'Online Version'" {
                # The module-qualified command fails on Microsoft.PowerShell.Archive cmdlets
                [Uri]$onlineLink = ($Help.relatedLinks.navigationLink | Where-Object linkText -eq "Online Version:").Uri

                $onlineLink.Authority | Should -Be "atlassianps.org"
                $onlineLink.Scheme | Should -Be "https"
                $onlineLink.PathAndQuery | Should -Be "/docs/JiraPS/commands/$commandName/"
            }

            It "has a valid HelpUri" {
                $HelpUri | Should -Not -BeNullOrEmpty
                $Pattern = [regex]::Escape("https://atlassianps.org/docs/JiraPS/commands/$commandName")

                $HelpUri | Should -Match $Pattern
            }

            It "has a synopsis" {
                $Help.Synopsis | Should -Not -BeNullOrEmpty
            }

            It "has a syntax" {
                $Help.syntax | Should -Not -BeNullOrEmpty
            }

            It "has a description" {
                $Help.Description.Text -join '' | Should -Not -BeNullOrEmpty
            }

            It "has examples" {
                ($Help.Examples.Example | Select-Object -First 1).Code | Should -Not -BeNullOrEmpty
            }

            # Should -Be at least one example description
            It "has desciptions for all examples" {
                foreach ($example in ($Help.Examples.Example)) {
                    $example.remarks.Text | Should -Not -BeNullOrEmpty
                }
            }

            It "has at least as many examples as ParameterSets" {
                ($Help.Examples.Example | Measure-Object).Count | Should -BeGreaterOrEqual $ParameterSets.Count
            }

            # It "does not define parameter position for functions with only one ParameterSet" {
            #     if ($command.ParameterSets.Count -eq 1) {
            #         $command.Parameters.Keys | Foreach-Object {
            #             $command.Parameters[$_].ParameterSets.Values.Position | Should -BeLessThan 0
            #         }
            #     }
            # }

            It "has each parameter documented property" {
                foreach ($parameterName in $Parameters.Keys) {
                    $parameterCode = $command.Parameters[$parameterName]

                    if ($help.Parameters | Get-Member -Name Parameter) {
                        $parameterHelp = $help.Parameters.Parameter | Where-Object Name -eq $parameterName

                        if ($parameterName -notin $defaultParams) {
                            #It "has a description for parameter [-$parameterName] in $commandName" {
                            $parameterHelp.Description.Text | Should -Not -BeNullOrEmpty
                            #}

                            #It "has a mandatory flag for parameter [-$parameterName] in $commandName" {
                            $isMandatory = $parameterCode.ParameterSets.Values.IsMandatory -contains "True"
                            $parameterHelp.Required | Should -BeLike $isMandatory.ToString()
                            #}

                            #It "matches the type of the parameter in code and help" {
                            $codeType = $parameterCode.ParameterType.Name
                            if ($codeType -eq "Object") {
                                if (($parameterCode.Attributes) -and ($parameterCode.Attributes | Get-Member -Name PSTypeName)) {
                                    $codeType = $parameterCode.Attributes[0].PSTypeName
                                }
                            }
                            # To avoid calling Trim method on a null object.
                            $helpType = if ($parameterHelp.parameterValue) { $parameterHelp.parameterValue.Trim() }
                            if ($helpType -eq "PSCustomObject") { $helpType = "PSObject" }

                            $helpType | Should -Be $codeType
                            #}
                        }
                    }
                }
            }

            It "does not have parameters that are not in the code" {
                $parameter = @()
                if ($Help.Parameters | Get-Member -Name Parameter) {
                    $parameter = $Help.Parameters.Parameter.Name | Sort-Object -Unique
                }
                foreach ($helpParm in $parameter) {
                    $Parameters.Keys | Should -Contain $helpParm
                }
            }
        }
    }

    Describe "Help of classes" {
        <# foreach ($class in $classes) {
            Describe "Classes $($class.BaseName) Help" {

                It "is described in a markdown file" {
                    $class.FullName | Should -Not -BeNullOrEmpty
                    Test-Path $class.FullName | Should -Be $true
                }

                It "has no platyPS template artifacts" {
                    $class.FullName | Should -Not -BeNullOrEmpty
                    $class.FullName | Should -Not -FileContentMatch '{{.*}}'
                }

                It "defines the frontmatter for the homepage" {
                    $class.FullName | Should -Not -BeNullOrEmpty
                    $class.FullName | Should -FileContentMatch "Module Name: JiraPS"
                    $class.FullName | Should -FileContentMatchExactly "layout: documentation"
                    $class.FullName | Should -FileContentMatch "permalink: /docs/JiraPS/classes/$($class.BaseName)/"
                }
            }
        }


        Describe "Missing classes" {
            It "has a documentation file for every class" {
                foreach ($class in ([AtlassianPS.ServerData].Assembly.GetTypes() | Where-Object IsClass)) {
                    $classes.BaseName | Should -Contain $class.FullName
                }
            }
        } #>
    }

    Describe "Help of enumerations" {
        <# foreach ($enum in $enums) {
            Describe "Enumeration $($enum.BaseName) Help" {

                It "is described in a markdown file" {
                    $enum.FullName | Should -Not -BeNullOrEmpty
                    Test-Path $enum.FullName | Should -Be $true
                }

                It "has no platyPS template artifacts" {
                    $enum.FullName | Should -Not -BeNullOrEmpty
                    $enum.FullName | Should -Not -FileContentMatch '{{.*}}'
                }

                It "defines the frontmatter for the homepage" {
                    $enum.FullName | Should -Not -BeNullOrEmpty
                    $enum.FullName | Should -FileContentMatch "Module Name: JiraPS"
                    $enum.FullName | Should -FileContentMatchExactly "layout: documentation"
                    $enum.FullName | Should -FileContentMatch "permalink: /docs/JiraPS/enumerations/$($enum.BaseName)/"
                }
            }
        }

        Describe "Missing enumerations" {
            It "has a documentation file for every enumeration" {
                foreach ($enum in ([AtlassianPS.ServerData].Assembly.GetTypes() | Where-Object IsEnum)) {
                    $enums.BaseName | Should -Contain $enum.FullName
                }
            }
        } #>
    }
}
