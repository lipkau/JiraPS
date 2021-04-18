function ConvertTo-Hashtable {
    <#
    .SYNOPSIS
        Converts a PSCustomObject to Hashtable

    .DESCRIPTION
        PowerShell v4 on Windows 8.1 seems to have trouble casting [PSCustomObject] to custom classes.
        This function is a workaround, as casting from [Hashtable] is no problem.
    #>
    [CmdletBinding( )]
    [OutputType( [Hashtable] )]
    param(
        # Object to convert
        [Parameter( Position = 0, Mandatory, ValueFromPipeline )]
        [PSCustomObject]
        $InputObject
    )

    process {
        $hash = @{ }

        $InputObject.PSObject.Properties | ForEach-Object {
            $hash[$_.Name] = $_.Value
        }

        $hash
    }
}
