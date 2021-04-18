function ConvertTo-JiraRemoteObject {
    [CmdletBinding( )]
    [OutputType( [AtlassianPS.JiraPS.RemoteObject] )]
    param(
        [Parameter( ValueFromPipeline )]
        [PSObject[]]
        $InputObject
    )

    process {
        foreach ($object in $InputObject) {
            Write-Debug "[$($MyInvocation.MyCommand.Name)] Converting `$object to custom object"

            [AtlassianPS.JiraPS.RemoteObject](ConvertTo-Hashtable -InputObject ( $object | Select-Object `
                        Url,
                    Title,
                    Summary,
                    Icon,
                    Status
                )
            )
        }
    }
}
