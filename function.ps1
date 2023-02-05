function Compare-PolicySettings {
    #https://www.theserverside.com/opinion/Master-slave-terminology-alternatives-you-can-use-right-now
    param (
        [Parameter(Mandatory=$true)]
        [xml]$PrimaryPolicy,
        [Parameter(Mandatory=$true)]
        [xml]$ReplicaPolicy
    )

    $compareData = @()
    $PPN = $PrimaryPolicy.GPO.Name
    $RPN = $ReplicaPolicy.GPO.Name

    for ($i=0; $i -lt $PrimaryPolicy.GPO.Computer.ExtensionData.Extension.Policy.Count; $i++) {
        $j=0
        foreach ($item in $ReplicaPolicy.GPO.Computer.ExtensionData.Extension.Policy.Name) {
            $MatchValue = $PrimaryPolicy.GPO.Computer.ExtensionData.Extension.Policy.Name[$i].CompareTo($ReplicaPolicy.GPO.Computer.ExtensionData.Extension.Policy.Name[$j])
            if ($MatchValue -eq 0) {
                $replicaState = $ReplicaPolicy.GPO.Computer.ExtensionData.Extension.Policy.State[$j]
                $j=0
                break
            } elseif ($j -ge ($ReplicaPolicy.GPO.Computer.ExtensionData.Extension.Policy.Count-1)) {
                $replicaState = "Setting not present"
                $replicaState
            } else {
                $j++
            } 
        }
        $compare = [PSCustomObject]@{
            "Name" = $PrimaryPolicy.GPO.Computer.ExtensionData.Extension.Policy.Name[$i]
            "$PPN State" = $PrimaryPolicy.GPO.Computer.ExtensionData.Extension.Policy.State[$i]
            "$RPN State" = $replicaState
            "States Match" = ($PrimaryPolicy.GPO.Computer.ExtensionData.Extension.Policy.State[$i] -eq $replicaState)
            #"Random" = Get-Random -Minimum 1 -Maximum 100
        }        
        $compareData += $compare
    }
    return $compareData
}

Compare-PolicySettings -PrimaryPolicy $PrimaryPolicy -ReplicaPolicy $ReplicaPolicy
