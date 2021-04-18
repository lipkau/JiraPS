function ConvertTo-JiraWorklogItem {
    [CmdletBinding( )]
    [OutputType( [AtlassianPS.JiraPS.WorklogItem] )]
    param(
        [Parameter( ValueFromPipeline )]
        [PSObject[]]
        $InputObject
    )

    process {
        foreach ($object in $InputObject) {
            Write-Debug "[$($MyInvocation.MyCommand.Name)] Converting `$InputObject to custom object"

            [AtlassianPS.JiraPS.WorklogItem](ConvertTo-Hashtable -InputObject ( $object | Select-Object `
                        id,
                    @{ Name = 'Issue'; Expression = {
                            if ($object.IssueId) { [AtlassianPS.JiraPS.Issue]@{ Id = $object.IssueId } }
                            else { $null }
                        }
                    },
                    comment,
                    visibility,
                    @{ Name = 'Author'; Expression = {
                            = (ConvertTo-JiraUser -InputObject $object.author) ?? $null
                        }
                    },
                    @{ Name = 'UpdateAuthor'; Expression = {
                            = (ConvertTo-JiraUser -InputObject $object.updateAuthor) ?? $null
                        }
                    },
                    @{ Name = 'Created'; Expression = {
                            if ($object.created) { Get-Date ($object.created) } else { $null }
                        }
                    },
                    @{ Name = 'Updated'; Expression = {
                            if ($object.updated) { Get-Date ($object.updated) } else { $null }
                        }
                    },
                    @{ Name = 'Started'; Expression = {
                            if ($object.started) { Get-Date ($object.started) } else { $null }
                        }
                    },
                    TimeSpent,
                    @{ Name = 'TimeSpentSeconds'; Expression = { [Int]$object.TimeSpentSeconds } },
                    @{ Name = "restUrl"; Expression = {
                            = $object.self ?? $null
                        }
                    }
                )
            )
        }
    }
}
