#requires -modules @{ ModuleName = "Pester"; ModuleVersion = "5.0" }
#requires -modules PSScriptAnalyzer

Describe "PSScriptAnalyzer Tests" -Tag Unit {

    BeforeAll {
        Import-Module "$PSScriptRoot/../Tools/TestTools.psm1" -force
        Invoke-InitTest $PSScriptRoot

        Import-Module "$PSScriptRoot/../JiraPS" -Force

        $settingsPath = "$PSScriptRoot/../PSScriptAnalyzerSettings.psd1"
        if (-not (Test-Path $settingsPath)) {
            $settingsPath = "$PSScriptRoot/../JiraPS/PSScriptAnalyzerSettings.psd1"
        }

        $isaSplatParameter = @{
            Path          = $env:BHModulePath
            Settings      = $settingsPath
            Severity      = @('Error', 'Warning')
            Recurse       = $true
            Verbose       = $false
            ErrorVariable = 'ErrorVariable'
            ErrorAction   = 'SilentlyContinue'
        }
        $ScriptWarnings = Invoke-ScriptAnalyzer @isaSplatParameter
    }
    AfterAll {
        Invoke-TestCleanup
    }

    Describe "on file <basename>" -ForEach (Get-ChildItem $env:BHModulePath -Include *.ps1, *.psm1 -Recurse | Foreach-Object {
            @{
                BaseName = $_.BaseName
                FullName = $_.FullName
            }
        } ) {
        It "passes all the rules" {
            $Rules = $ScriptWarnings |
            Where-Object { $_.ScriptPath -like $FullName } |
            Select-Object -ExpandProperty RuleName -Unique

            foreach ($rule in $Rules) {
                $BadLines = ($ScriptWarnings |
                    Where-Object { $_.ScriptPath -like $FullName -and $_.RuleName -like $rule }).Line
                $BadLines | Should -Be $null
            }
        }

        It "has no parse errors" {
            $Exceptions = $null
            if ($ErrorVariable) {
                $Exceptions = $ErrorVariable.Exception.Message |
                Where-Object { $_ -match [regex]::Escape($FullName) }
            }

            foreach ($Exception in $Exceptions) {
                $Exception | Should -BeNullOrEmpty
            }
        }
    }
}
