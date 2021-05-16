function Set-JiraUser {
    # .ExternalHelp ..\JiraPS-help.xml
    [CmdletBinding( SupportsShouldProcess, DefaultParameterSetName = 'ByNamedParameters' )]
    [OutputType( [AtlassianPS.JiraPS.User] )]
    param(
        [Parameter( Mandatory, ValueFromPipeline )]
        [ValidateNotNullOrEmpty()]
        [Alias("Username")]
        [AtlassianPS.JiraPS.User]
        $User,

        [Parameter( ParameterSetName = 'ByNamedParameters' )]
        [ValidateNotNullOrEmpty()]
        [String]
        $DisplayName,

        [Parameter( ParameterSetName = 'ByNamedParameters' )]
        [ValidateNotNullOrEmpty()]
        [ValidateScript(
            {
                if ($_ -match '^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$') {
                    return $true
                }
                else {
                    $exception = ([System.ArgumentException]"Invalid Argument") #fix code highlighting]
                    $errorId = 'ParameterValue.NotEmail'
                    $errorCategory = 'InvalidArgument'
                    $errorTarget = $EmailAddress
                    $errorItem = New-Object -TypeName System.Management.Automation.ErrorRecord $exception, $errorId, $errorCategory, $errorTarget
                    $errorItem.ErrorDetails = "The value provided does not look like an email address."
                    $PSCmdlet.ThrowTerminatingError($errorItem)
                    return $false
                }
            }
        )]
        [String]
        $EmailAddress,

        [Parameter( ParameterSetName = 'ByNamedParameters' )]
        [Boolean]
        $Active,

        [Parameter( Position = 1, Mandatory, ParameterSetName = 'ByHashtable' )]
        [Hashtable]
        $Property,

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

        if (-not $User.RestUrl) {
            $User = Get-JiraUser -Username $User -Credential $Credential -ErrorAction Stop
        }

        switch ($PSCmdlet.ParameterSetName) {
            'ByNamedParameters' {
                $Property = @{ }

                if ($DisplayName) {
                    $Property["displayName"] = $DisplayName
                }

                if ($EmailAddress) {
                    $Property["emailAddress"] = $EmailAddress
                }

                if ($PSBoundParameters.ContainsKey('Active')) {
                    $Property["active"] = $Active
                }
            }
            'ByHashtable' { }
        }

        if ($Property.Keys.Count -eq 0) {
            return
        }

        $parameter = @{
            URI        = $User.RestUrl
            Method     = "PUT"
            Body       = ConvertTo-Json -InputObject $Property -Depth 4
            OutputType = "JiraUser"
            Credential = $Credential
        }
        Write-Debug "[$($MyInvocation.MyCommand.Name)] Invoking JiraMethod with `$parameter"
        if ($PSCmdlet.ShouldProcess($User.ToString(), "Updating user")) {
            $result = Invoke-JiraMethod @parameter

            if ($PassThru) {
                $result
            }
        }
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}
