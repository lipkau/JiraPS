#requires -modules JiraPS
#requires -modules BuildHelpers
#requires -modules @{ ModuleName = "Pester"; ModuleVersion = "5.0" }

$script:DebugMode = $false

#region ExposedFunctions
function Invoke-InitTest {
    param(
        [Parameter(Mandatory)]
        $Path
    )

    Remove-Item -Path Env:\BH*
    $projectRoot = Get-ProjectPath -Path $Path

    Import-Module BuildHelpers
    Set-BuildEnvironment -BuildOutput '$ProjectPath/Release' -Path $projectRoot -ErrorAction SilentlyContinue

    # Import-Module "$env:BHProjectPath/Tools/BuildTools.psm1"
    Remove-Module JiraPS -ErrorAction SilentlyContinue
}

function Get-ProjectPath {
    param(
        [Parameter(Mandatory)][String]$Path
    )

    $_path = Resolve-Path $Path
    While ($_path) {
        $nextLevel = Split-Path -Path $_path

        if ((Get-ChildItem $_path -Force -Attributes D).Name -contains '.git') { return $_path }
        elseif ($_path -eq $nextLevel) { return $null }
        else { $_path = $nextLevel }
    }
}

function Invoke-TestCleanup {
    param()
    Remove-Module JiraPS -ErrorAction SilentlyContinue
    Remove-Module BuildHelpers -ErrorAction SilentlyContinue
    Remove-Item -Path Env:\BH*
}

function Set-DebugMode {
    [System.Diagnostics.CodeAnalysis.SuppressMessage('PSUseShouldProcessForStateChangingFunctions', '')]
    param([Bool]$Enabled)
    $script:DebugMode = $Enabled
}

function Write-MockInfo {
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

#region Mocked objects
#endregion Mocked objects

#region Mocked Cmdlets
function Add-CommonMocks {
    Mock Write-Debug { Write-MockDebug $Message }

    Mock Write-DebugMessage -ModuleName JiraPS { }

    Mock Invoke-JiraMethod {
        Write-MockInfo 'Invoke-JiraMethod' @{ Method = $Method; Uri = $Uri; Body = $Body }
        throw 'Unidentified call to Invoke-JiraMethod'
    }
}
}
#endregion Mocked Cmdlets

Export-ModuleMember -Function * -Variable *

function Write-MockDebug {
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
