function Set-JiraIssue {
    # .ExternalHelp ..\JiraPS-help.xml
    [CmdletBinding( SupportsShouldProcess )]
    [OutputType( [AtlassianPS.JiraPS.Issue] )]
    param(
        [Parameter( Mandatory, ValueFromPipeline )]
        [Alias('Key')]
        [AtlassianPS.JiraPS.Issue[]]
        $Issue,

        [String]
        $Summary,

        [String]
        $Description,

        [Alias('FixVersions')]
        [AtlassianPS.JiraPS.Version[]]
        $FixVersion,

        [AtlassianPS.JiraPS.User]
        $Assignee,

        [String[]]
        $Label,

        [PSCustomObject]
        $Fields,

        [String]
        $AddComment,

        [Switch]
        $SkipNotification,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential = [System.Management.Automation.PSCredential]::Empty,

        [Switch]
        $PassThru
    )

    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Function started"

        $fieldNames = $Fields.Keys
        if (-not ($Summary -or $Description -or $Assignee -or $Label -or $FixVersion -or $fieldNames -or $AddComment)) {
            $errorMessage = @{
                Category         = "InvalidArgument"
                CategoryActivity = "Validating Arguments"
                Message          = "The parameters provided do not change the Issue. No action will be performed"
            }
            Write-Error @errorMessage
            return
        }
    }

    process {
        Write-DebugMessage "[$($MyInvocation.MyCommand.Name)] ParameterSetName: $($PsCmdlet.ParameterSetName)"
        Write-DebugMessage "[$($MyInvocation.MyCommand.Name)] PSBoundParameters: $($PSBoundParameters | Out-String)"

        foreach ($_issue in $Issue) {
            Write-Verbose "[$($MyInvocation.MyCommand.Name)] Processing [$_issue]"
            Write-Debug "[$($MyInvocation.MyCommand.Name)] Processing `$_issue [$_issue]"

            if (-not $_issue.RestURL) {
                $_issue = Get-JiraIssue -Issue $_issue.Key -Credential $Credential -ErrorAction Stop
            }

            $issueProps = @{
                'update' = @{ }
            }

            if ($Summary) {
                # Update properties need to be passed to JIRA as arrays
                $issueProps.update["summary"] = @(@{ 'set' = $Summary })
            }

            if ($Description) {
                $issueProps.update["description"] = @(@{ 'set' = $Description })
            }

            if ($FixVersion) {
                $fixVersionSet = [System.Collections.ArrayList]@()
                foreach ($item in $FixVersion) {
                    $null = $fixVersionSet.Add( @{ 'name' = $item.Name } )
                }
                $issueProps.update["fixVersions"] = @( @{ set = $fixVersionSet } )
            }

            if ($AddComment) {
                $issueProps.update["comment"] = @(
                    @{
                        'add' = @{
                            'body' = $AddComment
                        }
                    }
                )
            }

            if ($Fields) {
                Write-Debug "[$($MyInvocation.MyCommand.Name)] Resolving `$Fields"
                foreach ($_key in $Fields.Keys) {
                    $field = Get-JiraField -Field $_key -Credential $Credential -ErrorAction SilentlyContinue
                    if (-not $field) {
                        $writeErrorSplat = @{
                            Exception    = $exception
                            ErrorId      = $errorId
                            Category     = $errorCategory
                            Message      = Out-String -InputObject $_error
                            TargetObject = $targetObject
                            Cmdlet       = $Cmdlet
                        }
                        WriteError @writeErrorSplat
                        continue
                    }

                    # For some reason, this was coming through as a hashtable instead of a String,
                    # which was causing ConvertTo-Json to crash later.
                    # Not sure why, but this forces $id to be a String and not a hashtable.
                    $id = [string]$field.Id
                    $issueProps.update[$id] = @(@{ 'set' = $Fields.$_key })
                }
            }

            $getParameters = @{ }
            if ($SkipNotification) {
                Write-Verbose "[$($MyInvocation.MyCommand.Name)] Skipping notification for watchers"
                $getParameters["notifyUsers"] = "false"
            }

            if ( @($issueProps.update.Keys).Count -gt 0 ) {
                Write-DebugMessage "[$($MyInvocation.MyCommand.Name)] Updating issue fields"

                $parameter = @{
                    URI          = $_issue.RestUrl
                    Method       = "PUT"
                    Body         = ConvertTo-Json -InputObject $issueProps -Depth 10
                    Credential   = $Credential
                    GetParameter = $getParameters
                }
                Write-Debug "[$($MyInvocation.MyCommand.Name)] Invoking JiraMethod with `$parameter"
                if ($PSCmdlet.ShouldProcess($_issue.Key, "Updating Issue")) {
                    Invoke-JiraMethod @parameter
                }
            }

            if ($Assignee) {
                Write-DebugMessage "[$($MyInvocation.MyCommand.Name)] Updating issue assignee"
                # Jira handles assignee differently; you can't change it from the default "edit issues" screen unless
                # you customize the "Edit Issue" screen.

                $parameter = @{
                    URI          = "{0}/assignee" -f $_issue.RestUrl
                    Method       = "PUT"
                    Body         = ConvertTo-Json -InputObject @{ $Assignee.identify()['key'] = $Assignee.identify()['value'] }
                    Credential   = $Credential
                    GetParameter = $getParameters
                }
                Write-Debug "[$($MyInvocation.MyCommand.Name)] Invoking JiraMethod with `$parameter"
                if ($PSCmdlet.ShouldProcess($_issue.Key, "Updating Issue [Assignee] from JIRA")) {
                    Invoke-JiraMethod @parameter
                }
            }

            if ($Label) {
                Set-JiraIssueLabel -Issue $_issue -Set $Label -Credential $Credential
            }

            if ($PassThru) {
                Get-JiraIssue -Issue $_issue -Credential $Credential
            }
        }
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}
