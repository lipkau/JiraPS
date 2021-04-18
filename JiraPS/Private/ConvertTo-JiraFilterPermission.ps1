function ConvertTo-JiraFilterPermission {
    [CmdletBinding( )]
    [OutputType( [AtlassianPS.JiraPS.FilterPermission] )]
    param(
        [Parameter( ValueFromPipeline )]
        [PSObject[]]
        $InputObject
    )

    process {
        foreach ($object in $InputObject) {
            Write-Debug "[$($MyInvocation.MyCommand.Name)] Converting `$InputObject to custom object"

            [AtlassianPS.JiraPS.FilterPermission](ConvertTo-Hashtable -InputObject ( $object | Select-Object `
                        id,
                    type,
                    @{ Name = "group"; Expression = {
                            = (ConvertTo-JiraGroup -InputObject $object.group) ?? $null
                        }
                    },
                    @{ Name = "project"; Expression = {
                            = (ConvertTo-JiraProject -InputObject $object.project) ?? $null
                        }
                    },
                    @{ Name = "role"; Expression = {
                            = (ConvertTo-JiraRole -InputObject $object.role) ?? $null
                        }
                    }
                )
            )
        }
    }
}
