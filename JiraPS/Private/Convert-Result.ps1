function Convert-Result {
    [CmdletBinding( )]
    param(
        [Parameter( ValueFromPipeline )]
        [Object]
        $InputObject,

        [String] $OutputType
    )

    begin {
        if ($OutputType) {
            $converter = "ConvertTo-$OutputType"
        }
    }

    process {
        if ($converter -and (Test-Path function:\$converter)) {
            Write-DebugMessage "[$($MyInvocation.MyCommand.Name)] Outputting `$InputObject as $OutputType"
            $InputObject | & $converter
        }
        else {
            Write-DebugMessage "[$($MyInvocation.MyCommand.Name)] Outputting without converting type `$InputObject"
            $InputObject
        }
    }
}
