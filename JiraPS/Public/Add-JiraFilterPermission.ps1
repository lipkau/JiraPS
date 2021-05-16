function Add-JiraFilterPermission {
    # .ExternalHelp ..\JiraPS-help.xml
    [CmdletBinding( SupportsShouldProcess, DefaultParameterSetName = 'Global' )]
    [OutputType( [AtlassianPS.JiraPS.FilterPermission] )]
    param(
        [Parameter( Position = 0, Mandatory, ValueFromPipeline )]
        [AtlassianPS.JiraPS.Filter]
        $Filter,

        [Parameter( Mandatory, ParameterSetName = 'Global')]
        [Switch]
        $Global,

        [Parameter( Mandatory, ParameterSetName = 'Authenticated' )]
        [Switch]
        $Authenticated,

        [Parameter( Mandatory, ParameterSetName = 'Project' )]
        [AtlassianPS.JiraPS.Project]
        $Project,

        [Parameter( ParameterSetName = 'Project' )]
        [Alias('ProjectRole')]
        [AtlassianPS.JiraPS.Role]
        $Role,

        [Parameter( Mandatory, ParameterSetName = 'Group' )]
        [AtlassianPS.JiraPS.Group]
        $Group,

        # Jira Server allows for granting "view" and "edit" permissions
        # [Parameter()]
        # [ValidateNotNullOrEmpty()]
        # [ValidateSet('Viewer', 'Editor')]
        # [String]
        # $Type = "Viewer",

        [Parameter()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential = [System.Management.Automation.PSCredential]::Empty
    )

    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Function started"

        $server = Get-JiraConfigServer -ErrorAction Stop

        $parameter = @{
            Method     = "POST"
            OutputType = 'JiraFilterPermission'
            Credential = $Credential
            Cmdlet     = $PSCmdlet
        }

        $resourceURi = "$server/rest/api/latest/filter/{0}/permission"
    }

    process {
        Write-DebugMessage "[$($MyInvocation.MyCommand.Name)] ParameterSetName: $($PsCmdlet.ParameterSetName)"
        Write-DebugMessage "[$($MyInvocation.MyCommand.Name)] PSBoundParameters: $($PSBoundParameters | Out-String)"

        if (-not $Filter.Id) {
            $Filter = Get-JiraFilter $Filter -Credential $Credential -ErrorAction Stop
        }

        if (-not $Filter.Id) {
            $writeErrorSplat = @{
                Exception    = "Missing property for identification"
                ErrorId      = "InvalidData.Filter.MissingIdentificationProperty"
                Category     = "InvalidData"
                Message      = "Filter needs to be identifiable by Id. Id was missing."
                TargetObject = $Filter
            }
            WriteError @writeErrorSplat
            return
        }

        $type = $PSCmdlet.ParameterSetName
        $body = @{ type = $type.ToLower() }
        switch ($type) {
            "Global" { }
            "Authenticated" { }
            "Project" {
                if (-not ($Project.Id -and $Project.Key)) {
                    $Project = Get-JiraProject $Project -Credential $Credential -ErrorAction Stop
                }

                $body["projectId"] = $Project.Id

                if ($Role) {
                    if ((-not $Role.Id) -and $Role.Name) {
                        $Role = Get-JiraRole -Project $Project -Credential $Credential -ErrorAction Stop |
                        Where-Object { $_.Name -eq $Role.Name }
                    }

                    $body["type"] = "projectRole"
                    $body["projectRoleId"] = $Role.Id
                }
            }
            "Group" {
                $body["groupname"] = $Group.Name
            }
        }

        $parameter['Uri'] = $resourceURi -f $Filter.Id
        $parameter['Body'] = ConvertTo-Json $body

        Write-Debug "[$($MyInvocation.MyCommand.Name)] Invoking JiraMethod with `$parameter"
        if ($PSCmdlet.ShouldProcess($Filter.ToString(), "Adding Permission [$type]")) {
            Invoke-JiraMethod @parameter
        }
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}
