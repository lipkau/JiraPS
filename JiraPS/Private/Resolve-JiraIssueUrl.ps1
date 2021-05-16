function Resolve-JiraIssueUrl {
    [CmdletBinding( )]
    [OutputType( [Uri] )]
    param(
        [Parameter( Mandatory, ValueFromPipeline )]
        [AtlassianPS.JiraPS.Issue]
        $Issue,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.PSCmdlet]
        $Cmdlet = $((Get-Variable -Scope 1 PSCmdlet).Value)
    )

    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Function started"

        $server = Get-JiraConfigServer -ErrorAction Stop

        $resourceURi = "$server/rest/api/latest/issue/{0}"
    }

    process {
        if ($Issue.RestUrl) {
            $Issue.RestUrl
        }
        elseif ($Issue.Key) {
            $resourceURi -f $Issue.Key
        }
        elseif ($Issue.Id) {
            $resourceURi -f $Issue.Id
        }
        else {
            $writeErrorSplat = @{
                Exception    = "Missing property for identification"
                ErrorId      = "InvalidData.Issue.MissingIdentificationProperty"
                Category     = "InvalidData"
                Message      = "Issue needs to be identifiable by Id or Name. Both were missing."
                TargetObject = $Issue
                Cmdlet       = $Cmdlet
            }
            WriteError @writeErrorSplat
            return
        }
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}
