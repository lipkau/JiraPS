function ConvertTo-URLEncoded {
    <#
    .SYNOPSIS
        Encode a string into URL (eg: %20 instead of " ")
    #>
    [CmdletBinding( )]
    [OutputType( [String] )]
    param (
        # String to encode
        [Parameter( ValueFromPipeline )]
        [String[]]
        $InputString
    )

    process {
        foreach ($input in $InputString) {
            Write-Verbose "[$($MyInvocation.MyCommand.Name)] Encoding string to URL"
            [System.Web.HttpUtility]::UrlEncode($input)
        }
    }
}
