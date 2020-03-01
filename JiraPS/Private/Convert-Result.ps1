function Convert-Result {
    [CmdletBinding()]
    param(
        [Parameter( ValueFromPipeline )]
        $InputObject,

        $OutputType
    )

    process {
        foreach ($item in $InputObject){
            if ($OutputType) {
                $converter = "ConvertTo-$OutputType"
            }

            if ($converter -and (Test-Path function:\$converter)) {
                Write-DebugMessage "[$($MyInvocation.MyCommand.Name)] Outputting `$result as $OutputType"
                $item | & $converter
            }
            else {
                Write-DebugMessage "[$($MyInvocation.MyCommand.Name)] Outputting `$result"
                $item
            }
        }
    }
}
