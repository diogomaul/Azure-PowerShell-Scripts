
Connect-AzAccount
$Subscriptions =  Get-AzSubscription

foreach ($subscription in $subscriptions) {
    Write-Host $subscription
    Select-AzSubscription -Subscription @Subscription
    Write-Host $subscription.Name
    Get-AzRoleAssignment -Scope "/subscriptions/$subscription" | Select-Object * | Export-Csv -Path .\CompleteAzureRBAC.csv -Append -NoTypeInformation 
    $resourceGroups = Get-AzResourceGroup
    foreach ($resourceGroup in $resourceGroups) {
        Get-AzRoleAssignment -ResourceGroupName $resourceGroup | Select-Object * | Export-Csv -Path .\CompleteAzureRBAC.csv -Append -NoTypeInformation 
    }
}

#Get-AzRoleAssignment -SignInName admdimaul@mccain.com
#Get-AzRoleAssignment -Scope "/subscriptions/65763622-4bd1-45e6-82fc-2f11e3663439" | select * | Export-Csv -Path .\AzureRBACSub.csv -Append -NoTypeInformation 
