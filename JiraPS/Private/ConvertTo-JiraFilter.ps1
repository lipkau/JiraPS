function ConvertTo-JiraFilter {
    [CmdletBinding( )]
    [OutputType( [AtlassianPS.JiraPS.Filter] )]
    param(
        [Parameter( ValueFromPipeline )]
        [PSObject[]]
        $InputObject
    )

    process {
        foreach ($object in $InputObject) {
            Write-Debug "[$($MyInvocation.MyCommand.Name)] Converting `$InputObject to custom object"

            [AtlassianPS.JiraPS.Filter](ConvertTo-Hashtable -InputObject ( $object | Select-Object `
                        Id,
                    Name,
                    Description,
                    @{Name = "Owner"; Expression = {
                            = (ConvertTo-JiraUser -InputObject $object.Owner) ?? $null
                        }
                    },
                    JQL,
                    Favourite,
                    @{ Name = "SharePermissions"; Expression = {
                            = (ConvertTo-JiraFilterPermission -InputObject $object.sharePermissions) ?? $null
                        }
                    },
                    ViewUrl,
                    SearchUrl,
                    @{ Name = "RestUrl"; Expression = {
                            = $object.self ?? $null
                        }
                    }
                )
            )
        }
    }
}
