function ConvertTo-JiraIssue {
    [CmdletBinding( )]
    [OutputType( [AtlassianPS.JiraPS.Issue] )]
    param(
        [Parameter( ValueFromPipeline )]
        [PSObject[]]
        $InputObject
    )

    process {
        foreach ($object in $InputObject) {
            Write-Debug "[$($MyInvocation.MyCommand.Name)] Converting `$InputObject to custom object"
            Write-Verbose "[$($MyInvocation.MyCommand.Name)] Converting `$InputObject to custom object"

            $result = [AtlassianPS.JiraPS.Issue](ConvertTo-Hashtable -InputObject ( $object | Select-Object `
                        id,
                    key,
                    @{ Name = "Expand"; Expression = { $object.expand -split "," } },
                    @{ Name = "Fields"; Expression = { @{ } } },
                    @{ Name = "Transition"; Expression = {
                            = (ConvertTo-JiraTransition -InputObject $object.transitions) ?? $null
                        }
                    },
                    @{ Name = "HttpUrl"; Expression = {
                            if ($object.self) { "{0}browse/{1}" -f ($object.self -split 'rest')[0], $object.key }
                            else { $null }
                        }
                    },
                    @{ Name = "RestUrl"; Expression = {
                            = $object.self ?? $null
                        }
                    }
                )
            )

            $fieldsAsHash = @{ }
            if ($object.fields) { $fieldsAsHash = ConvertTo-Hashtable -InputObject $object.fields }
            foreach ($key in $fieldsAsHash.Keys) {
                switch ($true) {
                    { $key -like "Project" } {
                        $result.Fields["Project"] = ConvertTo-JiraProject -InputObject $fieldsAsHash.$key
                        break
                    }
                    { $key -like "Priority" } {
                        $result.Fields["Priority"] = ConvertTo-JiraPriority -InputObject $fieldsAsHash.$key
                        break
                    }
                    { $key -like "Status" } {
                        $result.Fields["Status"] = ConvertTo-JiraStatus -InputObject $fieldsAsHash.$key
                        break
                    }
                    { $key -like "Components" } {
                        $result.Fields["Component"] = ConvertTo-JiraComponent -InputObject $fieldsAsHash.$key
                        break
                    }
                    { $key -like "IssueType" } {
                        $result.Fields["IssueType"] = ConvertTo-JiraIssueType -InputObject $fieldsAsHash.$key
                        break
                    }
                    { $key -like "Attachment" } {
                        $result.Fields["Attachment"] = ConvertTo-JiraAttachment $fieldsAsHash.$key
                        break
                    }
                    { $key -like "IssueLinks" } {
                        $result.Fields["IssueLink"] = ConvertTo-JiraIssueLink -InputObject $fieldsAsHash.$key
                        break
                    }
                    { $key -like "FixVersions" } {
                        $result.Fields['FixVersion'] = ConvertTo-JiraVersion $fieldsAsHash.$key
                        break
                    }
                    { $key -like "Versions" } {
                        $result.Fields['Version'] = ConvertTo-JiraVersion $fieldsAsHash.$key
                        break
                    }
                    { $key -like "Comment" -and $fieldsAsHash.comment -and $fieldsAsHash.comment.comments.Count -gt 0 } {
                        $result.Fields["Comment"] = ConvertTo-JiraComment -InputObject $fieldsAsHash.comment.comments
                        break
                    }
                    { $key -like "Worklog" -and $fieldsAsHash.worklog -and $fieldsAsHash.worklog.worklogs.Count -gt 0 } {
                        $result.Fields["Worklog"] = ConvertTo-JiraWorklogItem -InputObject $fieldsAsHash.worklog.worklogs
                        break
                    }
                    { $key -in $script:ConversionRules["issueFields"] } {
                        $result.Fields[$key] = ConvertTo-JiraIssue -inputObject $fieldsAsHash.$key
                        break
                    }
                    { $key -in $script:ConversionRules["timeSpanFields"] } {
                        $result.Fields[$key] = New-TimeSpan -Seconds $fieldsAsHash.$key
                        break
                    }
                    { $key -in $script:ConversionRules["userFields"] } {
                        $user = ConvertTo-JiraUser -InputObject ($fieldsAsHash.$key)
                        $result.Fields[$key] = if ($user) { $user } else { 'Unassigned' }
                        break
                    }
                    { $key -in $script:ConversionRules["dateFields"] -and $fieldsAsHash.$key } {
                        $result.Fields[$key] = Get-Date -Date ($fieldsAsHash.$key)
                        break
                    }
                    Default {
                        $result.Fields[$key] = $fieldsAsHash.$key
                    }
                }
            }

            $result
        }
    }
}
