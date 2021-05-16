function Add-JiraIssueLink {
    # .ExternalHelp ..\JiraPS-help.xml
    [CmdletBinding( SupportsShouldProcess )]
    param(
        [Parameter( Mandatory, ValueFromPipeline )]
        [Alias('Key')]
        [AtlassianPS.JiraPS.Issue]
        $Issue,

        [Parameter( Mandatory )]
        [AtlassianPS.JiraPS.IssueLink[]]
        $IssueLink,

        [AtlassianPS.JiraPS.Comment]
        $Comment,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential = [System.Management.Automation.PSCredential]::Empty
    )

    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Function started"

        $server = Get-JiraConfigServer -ErrorAction Stop

        $resourceURi = "$server/rest/api/latest/issueLink"
    }

    process {
        Write-DebugMessage "[$($MyInvocation.MyCommand.Name)] ParameterSetName: $($PsCmdlet.ParameterSetName)"
        Write-DebugMessage "[$($MyInvocation.MyCommand.Name)] PSBoundParameters: $($PSBoundParameters | Out-String)"

        if (-not $Issue.Key) {
            $writeErrorSplat = @{
                Exception    = "Missing property for identification"
                ErrorId      = "InvalidData.Issue.MissingIdentificationProperty"
                Category     = "InvalidData"
                Message      = "Issue needs to be identifiable by Key. Key was missing."
                TargetObject = $Issue
            }
            WriteError @writeErrorSplat
            return
        }

        foreach ($_issueLink in $IssueLink) {
            if ($_issueLink.inwardIssue) {
                $inwardIssue = @{ key = $_issueLink.inwardIssue.key }
            }
            else {
                $inwardIssue = @{ key = $Issue.key }
            }

            if ($_issueLink.outwardIssue) {
                $outwardIssue = @{ key = $_issueLink.outwardIssue.key }
            }
            else {
                $outwardIssue = @{ key = $Issue.key }
            }

            $body = @{
                type         = @{ name = $_issueLink.type.name }
                inwardIssue  = $inwardIssue
                outwardIssue = $outwardIssue
            }

            if ($Comment) {
                $body.comment = ($Comment | Select-Object Body)
            }

            $parameter = @{
                URI        = $resourceURi
                Method     = 'POST'
                Body       = ConvertTo-Json -InputObject $body
                Credential = $Credential
                Cmdlet     = $PSCmdlet
            }
            Write-Debug "[$($MyInvocation.MyCommand.Name)] Invoking JiraMethod with `$parameter"
            if ($PSCmdlet.ShouldProcess($Issue.ToString(), 'Adding an issue link')) {
                Invoke-JiraMethod @parameter
            }
        }
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}
