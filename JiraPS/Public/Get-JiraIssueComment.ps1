function Get-JiraIssueComment {
    # .ExternalHelp ..\JiraPS-help.xml
    [CmdletBinding( )]
    [OutputType( [AtlassianPS.JiraPS.Comment] )]
    param(
        [Parameter( Position = 0, Mandatory, ValueFromPipeline )]
        [ValidateNotNullOrEmpty()]
        [Alias('Key')]
        [AtlassianPS.JiraPS.Issue]
        $Issue,

        [ValidateRange(1, [UInt32]::MaxValue)]
        [UInt32]
        $PageSize = $script:DefaultPageSize,

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

        $parameter = @{
            URI          = "$IssueUrl/comment"
            Method       = "GET"
            GetParameter = @{
                maxResults = $PageSize
            }
            OutputType   = "JiraComment"
            Paging       = $true
            Credential   = $Credential
        }

        Write-Debug "[$($MyInvocation.MyCommand.Name)] Invoking JiraMethod with `$parameter"
        Invoke-JiraMethod @parameter
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}
