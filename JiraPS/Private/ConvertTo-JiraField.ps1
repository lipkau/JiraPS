function ConvertTo-JiraField {
    [CmdletBinding( )]
    [OutputType( [AtlassianPS.JiraPS.Field] )]
    param(
        [Parameter( ValueFromPipeline )]
        [PSObject[]]
        $InputObject
    )

    process {
        foreach ($object in $InputObject) {
            Write-Debug "[$($MyInvocation.MyCommand.Name)] Converting `$InputObject to custom object"

            [AtlassianPS.JiraPS.Field](ConvertTo-Hashtable -InputObject ( $object | Select-Object `
                        id,
                    key,
                    name,
                    custom,
                    orderable,
                    navigable,
                    searchable,
                    clauseNames,
                    schema
                )
            )
        }
    }
}
