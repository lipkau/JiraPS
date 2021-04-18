function ConvertTo-JiraVersion {
    [CmdletBinding( )]
    [OutputType( [AtlassianPS.JiraPS.Version] )]
    param(
        [Parameter( ValueFromPipeline )]
        [PSObject[]]
        $InputObject
    )

    process {
        foreach ($object in $InputObject) {
            Write-Debug "[$($MyInvocation.MyCommand.Name)] Converting `$InputObject to custom object"

            [AtlassianPS.JiraPS.Version](ConvertTo-Hashtable -InputObject ( $object | Select-Object `
                        id,
                    @{ Name = "Project"; Expression = {
                            = ConvertTo-JiraProject -InputObject $object.projectId ?? $null
                        }
                    },
                    name,
                    description,
                    @{ Name = "archived"; Expression = { [System.Convert]::ToBoolean($object.archived) } },
                    @{ Name = "released"; Expression = { [System.Convert]::ToBoolean($object.released) } },
                    @{ Name = "overdue"; Expression = { [System.Convert]::ToBoolean($object.overdue) } },
                    @{ Name = "startDate"; Expression = {
                            if ($object.startDate) { Get-Date $object.startDate } else { $null }
                        }
                    },
                    @{ Name = "releaseDate"; Expression = {
                            if ($object.releaseDate) { Get-Date $object.releaseDate }
                            elseif ($object.userReleaseDate) { Get-Date $object.userReleaseDate }
                            else { $null }
                        }
                    },
                    @{ Name = "restUrl"; Expression = {
                            = $object.self ?? $null
                        }
                    }
                )
            )
        }
    }
}
