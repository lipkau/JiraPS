function ConvertTo-JiraStatus {
    [CmdletBinding( )]
    [OutputType( [AtlassianPS.JiraPS.Status] )]
    param(
        [Parameter( ValueFromPipeline )]
        [PSObject[]]
        $InputObject
    )

    process {
        foreach ($object in $InputObject) {
            Write-Debug "[$($MyInvocation.MyCommand.Name)] Converting `$InputObject to custom object"

            [AtlassianPS.JiraPS.Status](ConvertTo-Hashtable -InputObject ( $object | Select-Object `
                        Id,
                    name,
                    description,
                    @{ Name = 'Category'; Expression = {
                            = (ConvertTo-JiraStatusCategory -InputObject $object.statusCategory) ?? $null
                        }
                    },
                    iconUrl,
                    @{ Name = "RestUrl"; Expression = {
                            = $object.self ?? $null
                        }
                    }
                )
            )
        }
    }
}
