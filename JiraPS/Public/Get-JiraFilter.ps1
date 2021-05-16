function Get-JiraFilter {
    # .ExternalHelp ..\JiraPS-help.xml
    [CmdletBinding( DefaultParameterSetName = 'ByFilter' )]
    [OutputType( [AtlassianPS.JiraPS.Filter] )]
    param(
        [Parameter( Position = 0, Mandatory, ValueFromPipeline, ParameterSetName = 'ByFilter' )]
        [Alias('Id')]
        [AtlassianPS.JiraPS.Filter[]]
        $Filter,

        [Parameter( Mandatory, ParameterSetName = 'MyFavorite' )]
        [Alias('Favourite')]
        [Switch]
        $Favorite,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential = [System.Management.Automation.PSCredential]::Empty
    )

    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Function started"

        $server = Get-JiraConfigServer -ErrorAction Stop

        $parameter = @{
            Method     = 'GET'
            OutputType = 'JiraFilter'
            Credential = $Credential
            Cmdlet     = $PSCmdlet
        }

        $resourceURi = "$server/rest/api/latest/filter/{0}"
    }

    process {
        Write-DebugMessage "[$($MyInvocation.MyCommand.Name)] ParameterSetName: $($PsCmdlet.ParameterSetName)"
        Write-DebugMessage "[$($MyInvocation.MyCommand.Name)] PSBoundParameters: $($PSBoundParameters | Out-String)"

        switch ($PSCmdlet.ParameterSetName) {
            "ByFilter" {
                foreach ($_filter in $Filter) {
                    Write-Verbose "[$($MyInvocation.MyCommand.Name)] Processing [$_filter]"
                    Write-Debug "[$($MyInvocation.MyCommand.Name)] Processing `$_filter [$_filter]"

                    $parameter['Uri'] = $resourceURi -f $_filter.Id

                    Write-Debug "[$($MyInvocation.MyCommand.Name)] Invoking JiraMethod with `$parameter"
                    Invoke-JiraMethod @parameter
                }
            }
            "MyFavorite" {
                $parameter['Uri'] = $resourceURi -f 'favourite'

                Write-Debug "[$($MyInvocation.MyCommand.Name)] Invoking JiraMethod with `$parameter"
                Invoke-JiraMethod @parameter
            }
        }
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}
