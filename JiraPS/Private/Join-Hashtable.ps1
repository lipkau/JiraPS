function Join-Hashtable {
    <#
	.SYNOPSIS
		Combines multiple hashtables into a single table.

	.DESCRIPTION
		Combines multiple hashtables into a single table.
		On multiple identic keys, the last wins.

	.EXAMPLE
		PS C:\> Join-Hashtable -Hashtable $Hash1, $Hash2

		Merges the hashtables contained in $Hash1 and $Hash2 into a single hashtable.
#>
    [OutputType( )]
    [OutputType( [Hashtable] )]
    Param (
        # The tables to merge.
        [Parameter( Position = 0, Mandatory, ValueFromPipeline )]
        [AllowNull()]
        [System.Collections.IDictionary[]]
        $InputObject
    )
    begin {
        $table = @{ }
    }

    process {
        foreach ($item in $InputObject) {
            foreach ($key in $item.Keys) {
                $table[$key] = $item[$key]
            }
        }
    }

    end {
        $table
    }
}
