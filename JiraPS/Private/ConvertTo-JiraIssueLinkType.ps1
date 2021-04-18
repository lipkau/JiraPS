function ConvertTo-JiraIssueLinkType {
    [CmdletBinding( )]
    [OutputType( [AtlassianPS.JiraPS.IssueLinkType] )]
    param(
        [Parameter( ValueFromPipeline )]
        [PSObject[]]
        $InputObject
    )

    process {
        foreach ($object in $InputObject) {
            Write-Debug "[$($MyInvocation.MyCommand.Name)] Converting `$InputObject to custom object"

            [AtlassianPS.JiraPS.IssueLinkType](ConvertTo-Hashtable -InputObject ( $object | Select-Object `
                        id,
                    name,
                    @{ Name = "InwardText"; Expression = { $object.inward } },
                    @{ Name = "OutwardText"; Expression = { $object.outward } }
                )
            )
        }
    }
}
