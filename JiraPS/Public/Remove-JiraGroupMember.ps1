function Remove-JiraGroupMember {
    # .ExternalHelp ..\JiraPS-help.xml
    [CmdletBinding( SupportsShouldProcess, ConfirmImpact = 'High' )]
    param(
        [Parameter( Mandatory, ValueFromPipeline )]
        [ValidateNotNullOrEmpty()]
        [Alias('GroupName')]
        [AtlassianPS.JiraPS.Group[]]
        $Group,

        [Parameter( Mandatory )]
        [ValidateNotNullOrEmpty()]
        [Alias('UserName')]
        [AtlassianPS.JiraPS.User[]]
        $User,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential = [System.Management.Automation.PSCredential]::Empty,

        [Switch]
        $PassThru,

        [Switch]
        $Force
    )

    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Function started"

        $server = Get-JiraConfigServer -ErrorAction Stop

        $resourceURi = "$server/rest/api/latest/group/user"

        if ($Force) {
            Write-DebugMessage "[$($MyInvocation.MyCommand.Name)] -Force was passed. Backing up current ConfirmPreference [$ConfirmPreference] and setting to None"
            $oldConfirmPreference = $ConfirmPreference
            $ConfirmPreference = 'None'
        }
    }

    process {
        Write-DebugMessage "[$($MyInvocation.MyCommand.Name)] ParameterSetName: $($PsCmdlet.ParameterSetName)"
        Write-DebugMessage "[$($MyInvocation.MyCommand.Name)] PSBoundParameters: $($PSBoundParameters | Out-String)"

        foreach ($_group in $Group) {
            Write-Verbose "[$($MyInvocation.MyCommand.Name)] Processing [$_group]"
            Write-Debug "[$($MyInvocation.MyCommand.Name)] Processing `$_group [$_group]"

            # TODO: validate group has Id

            foreach ($_user in $User) {
                Write-Verbose "[$($MyInvocation.MyCommand.Name)] Processing [$_user]"
                Write-Debug "[$($MyInvocation.MyCommand.Name)] Processing `$_user [$_user]"

                # TODO: validate user has Id

                $parameter = @{
                    URI          = $resourceURi
                    Method       = "DELETE"
                    GetParameter = @{
                        groupname                = $_group.Name
                        $_user.identify()["key"] = $_user.identify()["value"]
                    }
                    Credential   = $Credential
                }
                Write-Debug "[$($MyInvocation.MyCommand.Name)] Invoking JiraMethod with `$parameter"
                if ($PSCmdlet.ShouldProcess($_group.toString(), "Remove $_user from group")) {
                    Invoke-JiraMethod @parameter
                }
            }

            if ($PassThru) {
                Get-JiraGroup -InputObject $_group -Credential $Credential
            }
        }
    }

    end {
        if ($Force) {
            Write-DebugMessage "[$($MyInvocation.MyCommand.Name)] Restoring ConfirmPreference to [$oldConfirmPreference]"
            $ConfirmPreference = $oldConfirmPreference
        }

        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}
