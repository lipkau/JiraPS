function ConvertTo-JiraTransition {
    [CmdletBinding( )]
    [OutputType( [AtlassianPS.JiraPS.Transition] )]
    param(
        [Parameter( ValueFromPipeline )]
        [PSObject[]]
        $InputObject
    )

    process {
        foreach ($object in $InputObject) {
            Write-Debug "[$($MyInvocation.MyCommand.Name)] Converting `$InputObject to custom object"

            [AtlassianPS.JiraPS.Transition](ConvertTo-Hashtable -InputObject ( $object | Select-Object `
                        Id,
                    name,
                    @{ Name = "ResultStatus"; Expression = {
                            = (ConvertTo-JiraStatus -InputObject $object.to) ?? $null
                        }
                    }
                )
            )
        }
    }
}
