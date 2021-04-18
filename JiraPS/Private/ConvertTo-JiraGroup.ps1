function ConvertTo-JiraGroup {
    [CmdletBinding( )]
    [OutputType( [AtlassianPS.JiraPS.Group] )]
    param(
        [Parameter( ValueFromPipeline )]
        [PSObject[]]
        $InputObject
    )

    process {
        foreach ($object in $InputObject) {
            Write-Debug "[$($MyInvocation.MyCommand.Name)] Converting `$InputObject to custom object"

            [AtlassianPS.JiraPS.Group](ConvertTo-Hashtable -InputObject ( $object | Select-Object `
                        name,
                    @{ Name = "Size"; Expression = {
                            if ([int]($object.users.size) -gt 0) { $object.users.size }
                            else { 0 }
                        }
                    },
                    @{ Name = "Member"; Expression = {
                        if ($object.users.items) { $object.users.items | ConvertTo-JiraUser }
                        else { $null }
                    } },
                    @{ Name = "RestUrl"; Expression = {
                            = $object.self ?? $null
                        }
                    }
                )
            )
        }
    }
}
