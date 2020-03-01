$script:DebugMode = $false

#region ExposedFunctions
function Invoke-InitTest {
    param(
        [Parameter(Mandatory)]
        $Path
    )

    Remove-Item -Path Env:\BH*
    $projectRoot = (Resolve-Path "$Path/../..").Path
    if ($projectRoot -like "*Release") {
        $projectRoot = (Resolve-Path "$projectRoot/..").Path
    }

    Import-Module BuildHelpers
    Set-BuildEnvironment -BuildOutput '$ProjectPath/Release' -Path $projectRoot -ErrorAction SilentlyContinue

    $env:BHManifestToTest = $env:BHPSModuleManifest
    $env:BHisBuild = $PSScriptRoot -like "$env:BHBuildOutput*"
    if ($env:BHisBuild) {
        $Pattern = [regex]::Escape($env:BHProjectPath)

        $env:BHBuildModuleManifest = $env:BHPSModuleManifest -replace $Pattern, $env:BHBuildOutput
        $env:BHManifestToTest = $env:BHBuildModuleManifest
    }

    Import-Module "$env:BHProjectPath/Tools/BuildTools.psm1"
    Remove-Module $env:BHProjectName -ErrorAction SilentlyContinue
}

function Invoke-TestCleanup {
    param()
    Remove-Module $env:BHProjectName -ErrorAction SilentlyContinue
    Remove-Module BuildHelpers -ErrorAction SilentlyContinue
    Remove-Item -Path Env:\BH*
}

function Set-DebugMode {
    [System.Diagnostics.CodeAnalysis.SuppressMessage('PSUseShouldProcessForStateChangingFunctions', '')]
    param([Bool]$Enabled)
    $script:DebugMode = $Enabled
}

function ShowMockInfo {
    [CmdletBinding()]
    [System.Diagnostics.CodeAnalysis.SuppressMessage('PSAvoidUsingWriteHost', '')]
    param(
        $functionName,
        [Hashtable]$parameter
    )
    if ($script:DebugMode) {
        Write-Host "       Mocked $functionName" -ForegroundColor Cyan
        foreach ($p in $parameter.Keys) {
            Write-Host "         [$p]  $($parameter[$p])" -ForegroundColor Cyan
        }
    }
}

Mock "Write-Debug" {
    MockedDebug $Message
}

function MockedDebug {
    [System.Diagnostics.CodeAnalysis.SuppressMessage('PSAvoidUsingWriteHost', '')]
    [CmdletBinding()]
    param(
        $Message
    )
    if ($script:ShowDebugText) {
        Write-Host "       [DEBUG] $Message" -ForegroundColor Yellow
    }
}
#endregion ExposedFunctions
