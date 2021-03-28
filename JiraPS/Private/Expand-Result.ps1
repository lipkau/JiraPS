function Expand-Result {
    <#
    .SYNOPSIS
    Extract the data from a paginated envelope
    #>
    [CmdletBinding( )]
    param(
        [Parameter( Mandatory, ValueFromPipeline )]
        $InputObject
    )

    process {
        foreach ($container in $script:PagingContainers) {
            if (($InputObject) -and ($InputObject | Get-Member -Name $container)) {
                Write-DebugMessage "Extracting data from [$container] containter"
                $InputObject.$container
            }
        }
    }
}
