function Set-JiraVersion {
    # .ExternalHelp ..\JiraPS-help.xml
    [CmdletBinding( SupportsShouldProcess )]
    [OutputType( [AtlassianPS.JiraPS.Version] )]
    param(
        [Parameter( Mandatory, ValueFromPipeline )]
        [ValidateNotNullOrEmpty()]
        [AtlassianPS.JiraPS.Version[]]
        $Version,

        [Parameter()]
        [String]
        $Name,

        [Parameter()]
        [String]
        $Description,

        [Parameter()]
        [Bool]
        $Archived,

        [Parameter()]
        [Bool]
        $Released,

        [Parameter()]
        [DateTime]
        $ReleaseDate,

        [Parameter()]
        [DateTime]
        $StartDate,

        [Parameter()]
        [AtlassianPS.JiraPS.Project]
        $Project,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential = [System.Management.Automation.PSCredential]::Empty,

        [Parameter()]
        [Switch]
        $PassThru
    )

    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Function started"
    }

    process {
        Write-DebugMessage "[$($MyInvocation.MyCommand.Name)] ParameterSetName: $($PsCmdlet.ParameterSetName)"
        Write-DebugMessage "[$($MyInvocation.MyCommand.Name)] PSBoundParameters: $($PSBoundParameters | Out-String)"

        foreach ($_version in $Version) {
            Write-Verbose "[$($MyInvocation.MyCommand.Name)] Processing [$_version]"
            Write-DebugMessage "[$($MyInvocation.MyCommand.Name)] Processing `$_version [$_version]"

            if (-not $_version.RestUrl) {
                $_version = Get-JiraVersion -Id $_version.Id -Credential $Credential -ErrorAction Stop
            }

            $requestBody = @{ }

            if ($PSCmdlet.MyInvocation.BoundParameters.ContainsKey("Name")) {
                $requestBody["name"] = $Name
            }
            if ($PSCmdlet.MyInvocation.BoundParameters.ContainsKey("Description")) {
                $requestBody["description"] = $Description
            }
            if ($PSCmdlet.MyInvocation.BoundParameters.ContainsKey("Archived")) {
                $requestBody["archived"] = $Archived
            }
            if ($PSCmdlet.MyInvocation.BoundParameters.ContainsKey("Released")) {
                $requestBody["released"] = $Released
            }
            if ($PSCmdlet.MyInvocation.BoundParameters.ContainsKey("Project")) {
                if (-not $Project.Id) {
                    $Project = Get-JiraProject -Project $Project -Credential $Credential -ErrorAction Stop
                }
                $requestBody["projectId"] = $Project.Id
            }
            if ($PSCmdlet.MyInvocation.BoundParameters.ContainsKey("ReleaseDate")) {
                $requestBody["releaseDate"] = $ReleaseDate.ToString('yyyy-MM-dd')
            }
            if ($PSCmdlet.MyInvocation.BoundParameters.ContainsKey("StartDate")) {
                $requestBody["startDate"] = $StartDate.ToString('yyyy-MM-dd')
            }

            $parameter = @{
                URI        = $_version.RestUrl
                Method     = "PUT"
                Body       = ConvertTo-Json -InputObject $requestBody
                OutputType = "JiraVersion"
                Credential = $Credential
            }
            Write-Debug "[$($MyInvocation.MyCommand.Name)] Invoking JiraMethod with `$parameter"
            if ($PSCmdlet.ShouldProcess($Name, "Updating Version on JIRA")) {
                $result = Invoke-JiraMethod @parameter

                if ($PassThru) {
                    $result
                }
            }
        }
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}
