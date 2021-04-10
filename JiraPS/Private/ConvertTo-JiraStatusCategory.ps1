function ConvertTo-JiraStatusCategory {
    [CmdletBinding( )]
    [OutputType( [AtlassianPS.JiraPS.StatusCategory] )]
    param(
        [Parameter( ValueFromPipeline )]
        [PSObject[]]
        $InputObject
    )

    process {
        foreach ($object in $InputObject) {
            Write-Debug "[$($MyInvocation.MyCommand.Name)] Converting `$InputObject to custom object"

            [AtlassianPS.JiraPS.StatusCategory](ConvertTo-Hashtable -InputObject ( $object | Select-Object `
                        id,
                    key,
                    name,
                    colorName,
                    @{ Name = "RestUrl"; Expression = {
                            if ($object.self) { $object.self } else { $null }
                        }
                    }
                )
            )
        }
    }
}
