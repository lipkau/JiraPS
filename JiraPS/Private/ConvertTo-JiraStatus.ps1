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
                            if ($object.statusCategory) { ConvertTo-JiraStatusCategory $object.statusCategory } else { $null }
                        }
                    },
                    iconUrl,
                    @{Name = "RestUrl"; Expression = {
                            if ($object.self) { $object.self } else { $null }
                        }
                    }
                )
            )
        }
    }
}
