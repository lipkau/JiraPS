function ConvertTo-JiraComment {
    [CmdletBinding( )]
    [OutputType( [AtlassianPS.JiraPS.Comment] )]
    param(
        [Parameter( ValueFromPipeline )]
        [PSObject[]]
        $InputObject
    )

    process {
        foreach ($object in $InputObject) {
            Write-Debug "[$($MyInvocation.MyCommand.Name)] Converting `$InputObject to custom object"

            [AtlassianPS.JiraPS.Comment](ConvertTo-Hashtable -InputObject ( $object | Select-Object `
                        Id,
                    body,
                    @{ Name = 'Visibility'; Expression = {
                            = (ConvertTo-Hashtable -InputObject $object.visibility) ?? @{ }
                        }
                    },
                    @{ Name = 'Author'; Expression = {
                            = (ConvertTo-JiraUser -InputObject $object.author) ?? $null
                        }
                    },
                    @{ Name = 'UpdateAuthor'; Expression = {
                            = (ConvertTo-JiraUser -InputObject $object.updateAuthor) ?? $null
                        }
                    },
                    @{ Name = 'Created'; Expression = {
                            if ($object.created) { Get-Date -Date $object.created } else { $null }
                        }
                    },
                    @{ Name = 'Updated'; Expression = {
                            if ($object.updated) { Get-Date -Date $object.updated } else { $null }
                        }
                    },
                    @{ Name = 'RestUrl'; Expression = {
                            = $object.self ?? $null
                        }
                    }
                )
            )
        }
    }
}
