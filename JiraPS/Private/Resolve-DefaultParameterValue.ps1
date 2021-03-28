function Resolve-DefaultParameterValue {
    <#
	.SYNOPSIS
		Used to filter and process default parameter values.

	.DESCRIPTION
		This command picks all the default parameter values from a reference hashtable.
		It then filters all that match a specified command and binds them to that specific command, narrowing its focus.
		These get merged into either a new or a specified hashtable and returned.

	.EXAMPLE
		PS C:\> Resolve-DefaultParameterValue -Reference $global:PSDefaultParameterValues -CommandName 'Invoke-WebRequest'

		Returns a hashtable containing all default parameter values in the global scope affecting the command 'Invoke-WebRequest'.
#>
    [CmdletBinding()]
    [OutputType( [Hashtable] )]
    param (
        # The hashtable to pick default parameter valeus from.
        [Parameter( Mandatory )]
        [Hashtable]
        $Reference,

        # The commands to pick default parameter values for.
        [Parameter( Mandatory )]
        [String[]]
        $CommandName,

        # The target hashtable to merge results into.
        # By default an empty hashtable is used.
        [Hashtable]
        $Target = @{ },

        # Only resolve for specific parameter names.
        [String[]]
        $ParameterName = "*"
    )

    begin {
        $defaultItems = New-Object -TypeName System.Collections.ArrayList

        foreach ($key in $Reference.Keys) {
            $null = $defaultItems.Add(
                [PSCustomObject]@{
                    Key       = $key
                    Value     = $Reference[$key]
                    Command   = $key.Split(":")[0]
                    Parameter = $key.Split(":")[1]
                }
            )
        }
    }

    process {
        foreach ($command in $CommandName) {
            foreach ($item in $defaultItems) {
                if ($command -notlike $item.Command) { continue }

                foreach ($parameter in $ParameterName) {
                    if ($item.Parameter -like $parameter) {
                        if ($parameter -ne "*") {
                            $Target["$($command):$($parameter)"] = $item.Value
                        }
                        else {
                            $Target["$($command):$($item.Parameter)"] = $item.Value
                        }
                    }
                }
            }
        }
    }

    end {
        $Target
    }
}
