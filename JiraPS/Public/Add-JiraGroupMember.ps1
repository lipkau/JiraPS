function Add-JiraGroupMember {
    # .ExternalHelp ..\JiraPS-help.xml
    [CmdletBinding( SupportsShouldProcess )]
    [OutputType( [AtlassianPS.JiraPS.Group] )]
    param(
        [Parameter( Mandatory )]
        [ValidateNotNullOrEmpty()]
        [Alias('GroupName')]
        [AtlassianPS.JiraPS.Group]
        $Group,

        [Parameter( Mandatory, ValueFromPipeline )]
        [ValidateNotNullOrEmpty()]
        [Alias('UserName')]
        [AtlassianPS.JiraPS.User[]]
        $User,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential = [System.Management.Automation.PSCredential]::Empty,

        [Switch]
        $PassThru
    )

    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Function started"

        $server = Get-JiraConfigServer -ErrorAction Stop

        $resourceURi = "$server/rest/api/latest/group/user"
    }

    process {
        Write-DebugMessage "[$($MyInvocation.MyCommand.Name)] ParameterSetName: $($PsCmdlet.ParameterSetName)"
        Write-DebugMessage "[$($MyInvocation.MyCommand.Name)] PSBoundParameters: $($PSBoundParameters | Out-String)"

        if (-not $Group.Id) {
            $writeErrorSplat = @{
                Exception    = "Missing property for identification"
                ErrorId      = "InvalidData.Group.MissingIdentificationProperty"
                Category     = "InvalidData"
                Message      = "Group needs to be identifiable by Name. Name was missing."
                TargetObject = $Group
            }
            WriteError @writeErrorSplat
            return
        }

        foreach ($_user in $User) {
            $parameter = @{
                URI          = $resourceURi
                Method       = "POST"
                GetParameter = @{ groupname = $Group.Name }
                Body         = ConvertTo-Json -InputObject @{ $_user.identify().Key = $_user.identify().Value }
                OutputType   = "JiraGroup"
                Credential   = $Credential
                Cmdlet       = $PSCmdlet
            }
            Write-Debug "[$($MyInvocation.MyCommand.Name)] Invoking JiraMethod with `$parameter"
            if ($PSCmdlet.ShouldProcess($Group.ToString(), "Adding user '$_user'.")) {
                $result = Invoke-JiraMethod @parameter

                if ($PassThru) { $result }
            }
        }
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}
