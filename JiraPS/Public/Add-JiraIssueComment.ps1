function Add-JiraIssueComment {
    # .ExternalHelp ..\JiraPS-help.xml
    [CmdletBinding( SupportsShouldProcess, DefaultParameterSetName = 'NoRestrictions' )]
    [OutputType( [AtlassianPS.JiraPS.Comment] )]
    param(
        [Parameter( Mandatory )]
        [ValidateNotNullOrEmpty()]
        [String]
        $Comment,

        [Parameter( Mandatory, ValueFromPipeline )]
        [Alias('Key')]
        [AtlassianPS.JiraPS.Issue]
        $Issue,

        [Parameter( ParameterSetName = 'RestrictToGroup' )]
        [AtlassianPS.JiraPS.Group]
        $RestrictToGroup,

        [Parameter( ParameterSetName = 'RestrictToRole' )]
        [AtlassianPS.JiraPS.Role]
        $RestrictToRole,

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

        $requestBody = @{
            'body' = $Comment
        }

        if ($RestrictToGroup) {
            $requestBody['visibility'] = @{
                'type'  = 'group'
                'value' = $RestrictToGroup.Name
            }
        }

        # If the visible role Should -Be all users, the visibility block shouldn't be passed at
        # all. JIRA returns a 500 Internal Server Error if you try to pass this block with a
        # value of "All Users".
        if ($RestrictToRole -and $RestrictToRole.Name -ne 'All Users') {
            $requestBody['visibility'] = @{
                'type'  = 'role'
                'value' = $RestrictToRole.Name
            }
        }

        $parameter = @{
            URI        = "$IssueUrl/comment"
            Method     = 'POST'
            Body       = ConvertTo-Json -InputObject $requestBody
            OutputType = 'JiraComment'
            Credential = $Credential
            Cmdlet     = $PSCmdlet
        }
        Write-Debug "[$($MyInvocation.MyCommand.Name)] Invoking JiraMethod with `$parameter"
        if ($PSCmdlet.ShouldProcess($Issue.ToString(), 'Adding comment')) {
            Invoke-JiraMethod @parameter
        }
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}
