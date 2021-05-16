function Add-JiraIssueWatcher {
    # .ExternalHelp ..\JiraPS-help.xml
    [CmdletBinding( SupportsShouldProcess )]
    [OutputType( [void] )]
    param(
        [Parameter( Mandatory, ValueFromPipeline )]
        [AtlassianPS.JiraPS.User[]]
        $Watcher,

        [Parameter( Mandatory )]
        [Alias('Key')]
        [AtlassianPS.JiraPS.Issue]
        $Issue,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential = [System.Management.Automation.PSCredential]::Empty
    )

    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Function started"

        $IssueUrl = Resolve-JiraIssueUrl -Issue $Issue
    }

    process {
        Write-DebugMessage "[$($MyInvocation.MyCommand.Name)] ParameterSetName: $($PsCmdlet.ParameterSetName)"
        Write-DebugMessage "[$($MyInvocation.MyCommand.Name)] PSBoundParameters: $($PSBoundParameters | Out-String)"

        foreach ($_watcher in $Watcher) {
            Write-Verbose "[$($MyInvocation.MyCommand.Name)] Processing [$_watcher]"
            Write-Debug "[$($MyInvocation.MyCommand.Name)] Processing `$_watcher [$_watcher]"

            $parameter = @{
                URI        = "$IssueUrl/watchers"
                Method     = "POST"
                Body       = '"{0}"' -f $_watcher.identify().Value
                Credential = $Credential
                Cmdlet     = $PSCmdlet
            }
            Write-Debug "[$($MyInvocation.MyCommand.Name)] Invoking JiraMethod with `$parameter"
            if ($PSCmdlet.ShouldProcess($Issue.ToString(), "Adding user '$_watcher' as watcher.")) {
                Invoke-JiraMethod @parameter
            }
        }
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}
