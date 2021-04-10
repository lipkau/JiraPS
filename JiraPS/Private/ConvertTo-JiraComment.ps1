function ConvertTo-JiraComment {
    [CmdletBinding( )]
    [OutputType( [AtlassianPS.JiraPS.Comment] )]
    param(
        [Parameter( ValueFromPipeline )]
        [PSObject[]]
        $InputObject
    )

    process {
        foreach ($object in $InputObject) {
            Write-Debug "[$($MyInvocation.MyCommand.Name)] Converting `$InputObject to custom object"

            [AtlassianPS.JiraPS.Comment](ConvertTo-Hashtable -InputObject ( $object | Select-Object `
                        Id,
                    body,
                    @{ Name = 'Visibility'; Expression = { ConvertTo-Hashtable -InputObject $object.visibility } },
                    @{ Name = 'Author'; Expression = { ConvertTo-JiraUser -InputObject $object.author } },
                    @{ Name = 'UpdateAuthor'; Expression = { ConvertTo-JiraUser -InputObject $object.updateAuthor } },
                    @{ Name = 'Created'; Expression = { Get-Date -Date $object.created } },
                    @{ Name = 'Updated'; Expression = { Get-Date -Date $object.updated } },
                    @{ Name = 'RestUrl'; Expression = { $object.self } }
                )
            )
        }
    }
}
