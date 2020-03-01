#Requires -Modules Pester

# Dot source this script in any Pester test script that requires the module to be imported.

[System.Diagnostics.CodeAnalysis.SuppressMessage('PSUseDeclaredVarsMoreThanAssigments', '', Scope = '*', Target = 'ShowMockData')]
$script:ShowMockData = $false
[System.Diagnostics.CodeAnalysis.SuppressMessage('PSUseDeclaredVarsMoreThanAssigments', '', Scope = '*', Target = 'ShowDebugText')]
$script:ShowDebugText = $false

function defProp($obj, $propName, $propValue) {
    It "Defines the '$propName' property" {
        $obj.$propName | Should Be $propValue
    }
}

function hasProp($obj, $propName) {
    It "Defines the '$propName' property" {
        $obj | Get-Member -MemberType *Property -Name $propName | Should Not BeNullOrEmpty
    }
}

function hasNotProp($obj, $propName) {
    It "Defines the '$propName' property" {
        $obj | Get-Member -MemberType *Property -Name $propName | Should BeNullOrEmpty
    }
}

function defParam($command, $name) {
    It "Has a -$name parameter" {
        $command.Parameters.Item($name) | Should Not BeNullOrEmpty
    }
}

function defAlias($command, $name, $definition) {
    It "Supports the $name alias for the $definition parameter" {
        $command.Parameters.Item($definition).Aliases | Where-Object -FilterScript { $_ -eq $name } | Should Not BeNullOrEmpty
    }
}

# This function must be used from within an It block
function checkType($obj, $typeName) {
    if ($obj -is [System.Array]) {
        $o = $obj[0]
    }
    else {
        $o = $obj
    }

    (Get-Member -InputObject $o).TypeName -contains $typeName | Should Be $true
}

function castsToString($obj) {
    if ($obj -is [System.Array]) {
        $o = $obj[0]
    }
    else {
        $o = $obj
    }

    $o.ToString() | Should Not BeNullOrEmpty
}

function checkPsType($obj, $typeName) {
    It "Uses output type of '$typeName'" {
        checkType $obj $typeName
    }
    It "Can cast to string" {
        castsToString($obj)
    }
}
