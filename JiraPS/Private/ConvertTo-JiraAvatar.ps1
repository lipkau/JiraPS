function ConvertTo-JiraAvatar {
    [OutputType( )]
    [OutputType([AtlassianPS.JiraPS.Avatar])]
    param(
        [Parameter( ValueFromPipeline )]
        [PSObject[]]
        $InputObject
    )

    process {
        foreach ($i in $InputObject) {
            Write-Debug "[$($MyInvocation.MyCommand.Name)] Converting `$i to custom object"

            [AtlassianPS.JiraPS.Avatar](ConvertTo-Hashtable -InputObject ( $i | Select-Object `
                    @{ Name = "x16"; Expression = { $_."16x16" } },
                    @{ Name = "x24"; Expression = { $_."24x24" } },
                    @{ Name = "x32"; Expression = { $_."32x32" } },
                    @{ Name = "x48"; Expression = { $_."48x48" } }
                )
            )
        }
    }
}
