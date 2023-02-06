function ToDictionary {
    param (
        [Parameter(Mandatory = $true)]
        [xml]$GroupPolicy
    )

    $data = [System.Collections.Generic.Dictionary[String, Object]]::new()

    foreach ($policy in $GroupPolicy.GPO.Computer.ExtensionData.Extension.Policy) {
        $data.Add($policy.Name, $policy)
    }

    return $data
}

function Report {
    param (
        [Parameter(Mandatory = $true)]
        [string]$SiteName,
        [Parameter(Mandatory = $true)]
        [System.Collections.Generic.Dictionary[string, Object]]$Policies,
        [Parameter(Mandatory = $true)]
        [string]$OtherSiteName,
        [Parameter(Mandatory = $true)]
        [System.Collections.Generic.Dictionary[string, Object]]$Other
    )

    $compareData = @()

    foreach ($policy in $Policies.Values) {
        $compare = @{
            "Name"                 = $policy.Name
            "$SiteName State"      = $policy.State
            "$OtherSiteName State" = "Setting not present"
            "States Match"         = $false
        }

        # Check if the policy exist in the second group policy
        # If so, start overwriting the values in the compare hashtable
        if ($Other.ContainsKey($policy.Name)) {
            $compare["$OtherSiteName State"] = $Other[$policy.Name].State;
            $compare["States Match"] = ($compare["$SiteName State"] -eq $compare["$OtherSiteName State"])
        }

        # Convert hashtable to object and assign to the result object
        $compareData += [PSCustomObject]$compare
    }

    # Find the setting that only exist in $Other
    foreach ($otherPolicy in $Other.Values) {
        if (!$Policies.ContainsKey($otherPolicy.Name)) {
            # Setting only exist in site B
            $compare = @{
                "Name"                 = $otherPolicy.Name
                "$SiteName State"      = "Setting not present"
                "$OtherSiteName State" = $otherPolicy.State
                "States Match"         = $false
            }

            # Convert hashtable to object and assign to the result object
            $compareData += [PSCustomObject]$compare
        }
    }

    return $compareData
}