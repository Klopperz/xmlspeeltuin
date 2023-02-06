. .\function.ps1
. .\forms.ps1

Add-Type -AssemblyName System.Windows.Forms

$sbPrimaryPolicy = {
    $txtPrimaryPolicy.Text = New-OpenFileDialog -InitialDirectory $PSScriptRoot
}
$sbReplicaPolicy = {
    $txtReplicaPolicy.Text = New-OpenFileDialog -InitialDirectory $PSScriptRoot
} 
$sbReport = {
    $txtReport.Text = New-OpenFileDialog -InitialDirectory $PSScriptRoot
} 

$sbDoWork = {
    if (!(test-path $txtPrimaryPolicy.Text)){
        Write-Error "no valid Primary XML file specified"
    } elseif (!(test-path $txtReplicaPolicy.Text)){
        Write-Error "no valid Replica XML file specified"
    } else {
        Write-host "Valid input"
        [xml]$PrimaryPolicy = Get-Content $txtPrimaryPolicy.Text
        [xml]$ReplicaPolicy = Get-Content $txtReplicaPolicy.Text

        $PrimaryGroupPolicy = ToDictionary -GroupPolicy $PrimaryPolicy
        $SecondaryGroupPolicy = ToDictionary -GroupPolicy $ReplicaPolicy

        $reports = Report -SiteName $PrimaryPolicy.GPO.Name -OtherSiteName $ReplicaPolicy.GPO.Name -Policies $PrimaryGroupPolicy -Other $SecondaryGroupPolicy
        Write-host $reports
        [System.Windows.Forms.ListView]$lvReport.items.Clear()
        foreach ($report in $reports){
            $lviReport = New-Object System.Windows.Forms.ListViewItem($report.Name)
            $lviReport.SubItems.Add([Convert]::toString($report.'FSLogix-Site-A State')) | Out-Null
            $lviReport.SubItems.Add([Convert]::toString($report.'FSLogix-Site-B State')) | Out-Null
            $lviReport.SubItems.Add([Convert]::toString($report.'States Match'))  | Out-Null
            $lvReport.Items.Add($lviReport)                                     | Out-Null
        }
    }
} 

[System.Windows.Forms.Form]$frmMain =               New-Form                      -width 600 -height 400 -header "Awesome" -borderstyle FixedDialog -hide_minimizebox -hide_maximizebox 
                                                    New-Formlabel    -x 1   -y 1  -width 100 -height 20  -ParentObject $frmMain -Text "PrimaryPolicy" | Out-Null
[System.Windows.Forms.TextBox]$txtPrimaryPolicy =   New-Formtextbox  -x 105 -y 1  -width 145 -height 20  -ParentObject $frmMain -Text "<path>"
                                                    New-Formbutton   -x 250 -y 1  -width 20  -height 20  -ParentObject $frmMain -Text "..." -Script $sbPrimaryPolicy
                                                    New-Formlabel    -x 1   -y 30 -width 100 -height 20  -ParentObject $frmMain -Text "ReplicaPolicy" | Out-Null
[System.Windows.Forms.TextBox]$txtReplicaPolicy =   New-Formtextbox  -x 105 -y 30 -width 145 -height 20  -ParentObject $frmMain -Text "<path>"
                                                    New-Formbutton   -x 250 -y 30 -width 20  -height 20  -ParentObject $frmMain -Text "..." -Script $sbReplicaPolicy

                                                    New-Formbutton   -x 1   -y 60 -width 270 -height 20  -ParentObject $frmMain -Text "Generate report" -Script $sbDoWork

[System.Windows.Forms.ListView]$lvReport =          New-Formlistview -x 1   -y 90 -Width 580 -height 270 -ParentObject $frmMain -view "Details" -Scrollable
                                                    Add-ListviewColumn -oListView $lvReport  -Text "Name"           -Width 250 -Silence
                                                    Add-ListviewColumn -oListView $lvReport  -Text "Site Eee State" -Width 100 -Silence
                                                    Add-ListviewColumn -oListView $lvReport  -Text "Site Bee State" -Width 100 -Silence
                                                    Add-ListviewColumn -oListView $lvReport  -Text "Site Match"     -Width 80  -Silence

$frmMain.ShowDialog()