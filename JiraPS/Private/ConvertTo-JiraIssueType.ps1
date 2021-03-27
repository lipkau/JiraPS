function ConvertTo-JiraIssueType {
    [OutputType( )]
    [OutputType( [AtlassianPS.JiraPS.IssueType] )]
    param(
        [Parameter( ValueFromPipeline )]
        [PSObject[]]
        $InputObject
    )

    process {
        foreach ($object in $InputObject) {
            Write-Debug "[$($MyInvocation.MyCommand.Name)] Converting `$InputObject to custom object"

            [AtlassianPS.JiraPS.IssueType](ConvertTo-Hashtable -InputObject ( $object | Select-Object `
                        id,
                    name,
                    description,
                    iconUrl,
                    @{ Name = "Subtask"; Expression = { [System.Convert]::ToBoolean($i.subtask) } },
                    @{ Name = "RestUrl"; Expression = {
                            if ($object.self) { $object.self } else { $null }
                        }
                    }
                )
            )
        }
    }
}
