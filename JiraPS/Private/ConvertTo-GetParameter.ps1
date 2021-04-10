function ConvertTo-GetParameter {
    <#
    .SYNOPSIS
    Generate the GET parameter string for an URL from a hashtable
    #>
    [CmdletBinding( )]
    [OutputType( [String] )]
    param (
        [Parameter( Mandatory, ValueFromPipeline )]
        [System.Collections.IDictionary]
        $InputObject
    )

    process {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Making HTTP get parameter string out of a hashtable"

        $parameters = New-Object -TypeName System.Collections.ArrayList

        foreach ($key in $InputObject.Keys) {
            $value = ConvertTo-URLEncoded $InputObject[$key]
            $null = $parameters.Add("$key=$value")
        }

        "?{0}" -f ($parameters -join "&")
    }
}
