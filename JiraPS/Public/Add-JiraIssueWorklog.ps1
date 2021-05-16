function Add-JiraIssueWorklog {
    # .ExternalHelp ..\JiraPS-help.xml
    [CmdletBinding( SupportsShouldProcess, DefaultParameterSetName = 'auto' )]
    param(
        [Parameter( Mandatory, ValueFromPipeline )]
        [Alias('Key')]
        [AtlassianPS.JiraPS.Issue]
        $Issue,

        [Parameter( Mandatory, ValueFromPipeline )]
        [TimeSpan]
        $TimeSpent,

        [Parameter( Mandatory, ValueFromPipeline )]
        [DateTime]
        $DateStarted,

        [Parameter( Mandatory )]
        [ValidateNotNullOrEmpty()]
        [AtlassianPS.JiraPS.Comment]
        $Comment,

        [ValidateSet('All Users', 'Developers', 'Administrators')]
        [String]
        $VisibleRole = 'All Users',

        [Parameter()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential = [System.Management.Automation.PSCredential]::Empty
    )

    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Function started"
    }

    process {
        Write-DebugMessage "[$($MyInvocation.MyCommand.Name)] ParameterSetName: $($PsCmdlet.ParameterSetName)"
        Write-DebugMessage "[$($MyInvocation.MyCommand.Name)] PSBoundParameters: $($PSBoundParameters | Out-String)"

        $IssueUrl = Resolve-JiraIssueUrl -Issue $Issue

        # Harmonize DateStarted:
        # `Get-Date -Date "01.01.2000"` does not return the local timezone which is required by the API
        $DateStarted = [DateTime]::new($DateStarted.Ticks, 'Local')

        $requestBody = @{
            'comment'          = $Comment.Body
            # We need to fix the date with a RegEx replace because the API does not like:
            #   * miliseconds with more than 3 digits
            #   * `:` in the TimeZone
            'started'          = $DateStarted.ToString("o") -replace "\.(\d{3})\d*([\+\-]\d{2}):", ".`$1`$2"
            'timeSpentSeconds' = $TimeSpent.TotalSeconds.ToString()
        }

        # If the visible role Should -Be all users, the visibility block shouldn't be passed at
        # all. JIRA returns a 500 Internal Server Error if you try to pass this block with a
        # value of "All Users".
        if ($VisibleRole -ne 'All Users') {
            $requestBody.visibility = @{
                'type'  = 'role'
                'value' = $VisibleRole
            }
        }

        $parameter = @{
            URI        = "$IssueUrl/worklog"
            Method     = "POST"
            Body       = ConvertTo-Json -InputObject $requestBody
            Credential = $Credential
            Cmdlet     = $PSCmdlet
        }
        Write-Debug "[$($MyInvocation.MyCommand.Name)] Invoking JiraMethod with `$parameter"
        if ($PSCmdlet.ShouldProcess($issue.ToString(), "Adding worklog item")) {
            Invoke-JiraMethod @parameter
        }
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}
