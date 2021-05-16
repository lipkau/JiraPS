function Find-JiraFilter {
    # .ExternalHelp ..\JiraPS-help.xml
    [CmdletBinding( SupportsPaging )]
    [OutputType( [AtlassianPS.JiraPS.Filter] )]
    param(
        [Parameter( ValueFromPipeline )]
        [String[]]$Name,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [Alias('UserName', 'AccountId', 'Owner')]
        [AtlassianPS.JiraPS.User]
        $User,

        [Parameter()]
        [Alias('GroupName')]
        [AtlassianPS.JiraPS.Group]
        $Group,

        [Parameter()]
        [AtlassianPS.JiraPS.Project]
        $Project,

        [Parameter()]
        [Validateset('description', 'favourite', 'favouritedCount', 'jql', 'owner', 'searchUrl', 'sharePermissions', 'subscriptions', 'viewUrl')]
        [String[]]
        $Fields = @('description', 'favourite', 'favouritedCount', 'jql', 'owner', 'searchUrl', 'sharePermissions', 'subscriptions', 'viewUrl'),

        [Parameter()]
        [Validateset('description', 'favourite_count', 'is_favourite', 'id', 'name', 'owner')]
        [String]$Sort,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential = [System.Management.Automation.PSCredential]::Empty
    )

    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Function started"

        $server = Get-JiraConfigServer -ErrorAction Stop

        $parameter = @{
            URI          = "$server/rest/api/latest/filter/search"
            Method       = 'GET'
            GetParameter = @{
                expand = $Fields -join ','
            }
            Paging       = $true
            OutputType   = "JiraFilter"
            Credential   = $Credential
            Cmdlet       = $PSCmdlet
        }
    }

    process {
        Write-DebugMessage "[$($MyInvocation.MyCommand.Name)] PSBoundParameters: $($PSBoundParameters | Out-String)"


        if ($PSCmdlet.MyInvocation.BoundParameters.ContainsKey('User')) {
            $parameter['GetParameter']["accountID"] = $User.AccountId
        }
        if ($PSCmdlet.MyInvocation.BoundParameters.ContainsKey('GroupName')) {
            $parameter['GetParameter']['groupName'] = $Group.Name
        }
        if ($PSCmdlet.MyInvocation.BoundParameters.ContainsKey('Project')) {
            if (-not $Project.Id) {
                $Project = Get-JiraProject -Project $Project -Credential $Credential -ErrorAction Stop
            }
            $parameter['GetParameter']['projectId'] = $Project.Id
        }
        if ($PSCmdlet.MyInvocation.BoundParameters.ContainsKey('Sort')) {
            $parameter['GetParameter']['orderBy'] = $Sort
        }

        # Paging
        ($PSCmdlet.PagingParameters | Get-Member -MemberType Property).Name | ForEach-Object {
            $parameter[$_] = $PSCmdlet.PagingParameters.$_
        }

        if ($PSCmdlet.MyInvocation.BoundParameters.ContainsKey('Name')) {
            foreach ($_name in $Name) {
                $parameter['GetParameter']['filterName'] = $_name
                Write-Debug "[$($MyInvocation.MyCommand.Name)] Invoking JiraMethod with `$parameter"

                Invoke-JiraMethod @parameter
            }
        }
        else {
            Write-Debug "[$($MyInvocation.MyCommand.Name)] Invoking JiraMethod with `$parameter"

            Invoke-JiraMethod @parameter
        }

    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}
