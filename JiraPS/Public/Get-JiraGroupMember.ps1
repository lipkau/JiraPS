function Get-JiraGroupMember {
    # .ExternalHelp ..\JiraPS-help.xml
    [CmdletBinding( SupportsPaging )]
    [OutputType( [AtlassianPS.JiraPS.User] )]
    param(
        [Parameter( Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName )]
        [ValidateNotNullOrEmpty()]
        [AtlassianPS.JiraPS.Group]
        $Group,

        [Parameter()]
        [Switch]
        $IncludeInactive,

        [Parameter()]
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

        $server = Get-JiraConfigServer -ErrorAction Stop

        $resourceURi = "$server/rest/api/latest/group/member"

        if ($PageSize -gt 50) {
            Write-Warning "JIRA's API may not properly support PageSize values higher than 50 for this method. If you receive inconsistent results, do not pass the PageSize parameter to this function to return all results."
        }
    }

    process {
        Write-DebugMessage "[$($MyInvocation.MyCommand.Name)] ParameterSetName: $($PsCmdlet.ParameterSetName)"
        Write-DebugMessage "[$($MyInvocation.MyCommand.Name)] PSBoundParameters: $($PSBoundParameters | Out-String)"

        $parameter = @{
            URI          = $resourceURi
            Method       = "GET"
            GetParameter = @{
                groupname  = $_group.Name
                maxResults = $PageSize
            }
            Paging       = $true
            OutputType   = "JiraUser"
            Credential   = $Credential
        }
        if ($IncludeInactive) {
            $parameter["includeInactiveUsers"] = $true
        }

        # Paging
        ($PSCmdlet.PagingParameters | Get-Member -MemberType Property).Name | ForEach-Object {
            $parameter[$_] = $PSCmdlet.PagingParameters.$_
        }

        Write-Debug "[$($MyInvocation.MyCommand.Name)] Invoking JiraMethod with `$parameter"
        Invoke-JiraMethod @parameter
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}
