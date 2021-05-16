function Get-JiraGroup {
    # .ExternalHelp ..\JiraPS-help.xml
    [CmdletBinding( )]
    [OutputType( [AtlassianPS.JiraPS.Group] )]
    param(
        [Parameter( Mandatory, ValueFromPipeline )]
        [ValidateNotNullOrEmpty()]
        [Alias('GroupName')]
        [String[]]
        $Name,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential = [System.Management.Automation.PSCredential]::Empty
    )

    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Function started"

        $server = Get-JiraConfigServer -ErrorAction Stop

        $resourceURi = "$server/rest/api/latest/group?groupname={0}"
    }

    process {
        Write-DebugMessage "[$($MyInvocation.MyCommand.Name)] ParameterSetName: $($PsCmdlet.ParameterSetName)"
        Write-DebugMessage "[$($MyInvocation.MyCommand.Name)] PSBoundParameters: $($PSBoundParameters | Out-String)"

        foreach ($_name in $Name) {
            Write-Verbose "[$($MyInvocation.MyCommand.Name)] Processing [$_name]"
            Write-Debug "[$($MyInvocation.MyCommand.Name)] Processing `$_name [$_name]"

            $escapedGroupName = ConvertTo-URLEncoded $_name

            $parameter = @{
                URI          = $resourceURi -f $escapedGroupName
                Method       = "GET"
                GetParameter = @{
                    expand = "users"
                }
                OutputType   = "JiraGroup"
                Credential   = $Credential
            }
            Write-Debug "[$($MyInvocation.MyCommand.Name)] Invoking JiraMethod with `$parameter"
            Invoke-JiraMethod @parameter
        }
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}
