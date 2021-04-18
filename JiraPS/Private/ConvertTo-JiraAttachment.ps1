function ConvertTo-JiraAttachment {
    [CmdletBinding( )]
    [OutputType( [AtlassianPS.JiraPS.Attachment] )]
    param(
        [Parameter( ValueFromPipeline )]
        [PSObject[]]
        $InputObject
    )

    process {
        foreach ($object in $InputObject) {
            Write-Debug "[$($MyInvocation.MyCommand.Name)] Converting `$object to custom object"

            [AtlassianPS.JiraPS.Attachment](ConvertTo-Hashtable -InputObject ( $object | Select-Object `
                        id,
                    fileName,
                    @{ Name = 'Author'; Expression = {
                            = (ConvertTo-JiraUser -InputObject $object.Author) ?? $null
                        }
                    },
                    @{ Name = 'Created'; Expression = {
                            if ($object.created) { Get-Date -Date $object.created } else { $null }
                        }
                    },
                    @{ Name = 'Size'; Expression = { ([Int]$object.size) } },
                    mimeType,
                    content,
                    thumbnail,
                    @{ Name = 'RestUrl'; Expression = {
                            = $object.self ?? $null
                        }
                    }
                )
            )
        }
    }
}


