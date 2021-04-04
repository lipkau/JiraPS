function ConvertTo-JiraProjectCategory {
    [OutputType( )]
    [OutputType([AtlassianPS.JiraPS.ProjectCategory])]
    param(
        [Parameter( ValueFromPipeline )]
        [PSObject[]]
        $InputObject
    )

    process {
        foreach ($object in $InputObject) {
            Write-Debug "[$($MyInvocation.MyCommand.Name)] Converting `$InputObject to custom object"

            [AtlassianPS.JiraPS.ProjectCategory](ConvertTo-Hashtable -InputObject ( $object | Select-Object `
                        id,
                    name,
                    description,
                    @{Name = "RestUrl"; Expression = { $object.self } }
                )
            )
        }
    }
}
