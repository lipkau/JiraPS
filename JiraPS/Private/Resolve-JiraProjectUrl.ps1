function Resolve-JiraProjectUrl {
    [CmdletBinding( )]
    [OutputType( [Uri] )]
    param(
        [Parameter( Mandatory, ValueFromPipeline )]
        [AtlassianPS.JiraPS.Project]
        $Project,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.PSCmdlet]
        $Cmdlet = $((Get-Variable -Scope 1 PSCmdlet).Value)
    )

    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Function started"

        $server = Get-JiraConfigServer -ErrorAction Stop

        $resourceURi = "$server/rest/api/latest/project/{0}"
    }

    process {
        if ($Project.RestUrl) {
            $Project.RestUrl
        }
        elseif ($Project.Key) {
            $resourceURi -f $Project.Key
        }
        elseif ($Project.Id) {
            $resourceURi -f $Project.Id
        }
        else {
            $writeErrorSplat = @{
                Exception    = "Missing property for identification"
                ErrorId      = "InvalidData.Project.MissingIdentificationProperty"
                Category     = "InvalidData"
                Message      = "Project needs to be identifiable by Id or Name. Both were missing."
                TargetObject = $Project
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
