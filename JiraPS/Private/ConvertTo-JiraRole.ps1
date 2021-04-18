function ConvertTo-JiraRole {
    [CmdletBinding( )]
    [OutputType([AtlassianPS.JiraPS.Role])]
    param(
        [Parameter( ValueFromPipeline )]
        [PSObject[]]
        $InputObject
    )

    process {
        foreach ($object in $InputObject) {
            Write-Debug "[$($MyInvocation.MyCommand.Name)] Converting `$InputObject to custom object"

            [AtlassianPS.JiraPS.Role](ConvertTo-Hashtable -InputObject ( $object | Select-Object `
                        id,
                    name,
                    description,
                    @{ Name = "actors"; Expression = {
                            = (ConvertTo-JiraRoleActor -InputObject $object.actors) ?? $null
                        }
                    },
                    @{ Name = "RestUrl"; Expression = {
                            = $object.self ?? $null
                        }
                    }
                )
            )
        }
    }
}
