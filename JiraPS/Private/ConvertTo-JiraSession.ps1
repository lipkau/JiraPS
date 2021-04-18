function ConvertTo-JiraSession {
    [CmdletBinding( )]
    [OutputType( [AtlassianPS.JiraPS.Session] )]
    param(
        [Parameter( Mandatory )]
        [Microsoft.PowerShell.Commands.WebRequestSession]
        $Session,

        [Parameter( Mandatory )]
        [String]
        $Username
    )

    process {
        Write-Debug "[$($MyInvocation.MyCommand.Name)] Converting `$InputObject to custom object"

        [AtlassianPS.JiraPS.Session]@{
            Username   = $Username
            WebSession = $Session
        }
    }
}
