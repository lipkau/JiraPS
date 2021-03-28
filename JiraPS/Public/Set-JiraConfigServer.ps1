function Set-JiraConfigServer {
    # .ExternalHelp ..\JiraPS-help.xml
    [CmdletBinding( )]
    [OutputType( [void] )]
    [System.Diagnostics.CodeAnalysis.SuppressMessage('PSUseShouldProcessForStateChangingFunctions', '')]
    param(
        [Parameter( Mandatory )]
        [ValidateNotNullOrEmpty()]
        [Alias('Uri', 'Url')]
        [Uri]
        $Server
    )

    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Function started"
    }

    process {
        $script:JiraServerUrl = $Server

        Set-Content -Value $Server -Path "$script:serverConfig"
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}
