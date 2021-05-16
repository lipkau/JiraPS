function Set-JiraFilter {
    # .ExternalHelp ..\JiraPS-help.xml
    [CmdletBinding( SupportsShouldProcess )]
    [OutputType([AtlassianPS.JiraPS.Filter])]
    param(
        [Parameter( Mandatory, ValueFromPipeline )]
        [ValidateNotNullOrEmpty()]
        [AtlassianPS.JiraPS.Filter]
        $Filter,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [String]
        $Name,

        [Parameter()]
        [String]
        $Description,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [String]
        $JQL,

        [Parameter()]
        [Alias('Favourite')]
        [Bool]
        $Favorite,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential = [System.Management.Automation.PSCredential]::Empty
    )

    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Function started"

        $server = Get-JiraConfigServer -ErrorAction Stop

        $resourceURi = "$server/rest/api/latest/filter/{0}"
    }

    process {
        Write-DebugMessage "[$($MyInvocation.MyCommand.Name)] ParameterSetName: $($PsCmdlet.ParameterSetName)"
        Write-DebugMessage "[$($MyInvocation.MyCommand.Name)] PSBoundParameters: $($PSBoundParameters | Out-String)"

        # TODO: validate filter has id

        if ($PSCmdlet.MyInvocation.BoundParameters.ContainsKey("Name")) {
            $Filter.Name = $Name
        }
        if ($PSCmdlet.MyInvocation.BoundParameters.ContainsKey("Description")) {
            $Filter.Description = $Description
        }
        if ($PSCmdlet.MyInvocation.BoundParameters.ContainsKey("JQL")) {
            $Filter.JQL = $JQL
        }
        if ($PSCmdlet.MyInvocation.BoundParameters.ContainsKey("Favorite")) {
            $Filter.Favorite = $Favorite
        }

        if ($requestBody.Keys.Count) {
            $parameter = @{
                URI        = $resourceURi -f $Filter.Id
                Method     = "PUT"
                Body       = ConvertTo-Json -InputObject ($requestBody | Select-Object Name, Description, JQL, Favorite)
                OutputType = "JiraFilter"
                Credential = $Credential
            }
            Write-Debug "[$($MyInvocation.MyCommand.Name)] Invoking JiraMethod with `$parameter"
            if ($PSCmdlet.ShouldProcess($Filter.ToString(), "Update Filter")) {
                Invoke-JiraMethod @parameter
            }
        }
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}
