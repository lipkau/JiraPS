function Write-DebugMessage {
    [CmdletBinding( )]
    [OutputType( [void] )]
    param(
        [Parameter( ValueFromPipeline )]
        [String]
        $Message
    )

    begin {
        $oldDebugPreference = $DebugPreference
        if (-not ($DebugPreference -eq "SilentlyContinue")) {
            $DebugPreference = 'Continue'
        }
    }

    process {
        Write-Debug $Message
    }

    end {
        $DebugPreference = $oldDebugPreference
    }
}
