[CmdletBinding()]
param (
    $subscriptions,
    $ADUsers
)

function getMcCainADUsers {

    $ADUsers = @()
    $ADUsers = Get-AzureADUser -All $true | Select-Object DisplayName, UserPrincipalName, UserType, AccountEnabled, ObjectId #Where-Object {$_.DirSyncEnabled -eq $true -and $_.AccountEnabled -eq $true} |
    $ADUsers.count
    return $ADUsers
}

function getMcCainSubscriptions {
    $Subscriptions =  Get-AzSubscription #-SubscriptionId 6b5fafad-c388-4834-8e16-daf9828deb84   
    return $Subscriptions 
}

function getMcCainRBAC($subscriptions, $ADUsers) {
    
    $stopwatch =  [system.diagnostics.stopwatch]::StartNew()
    $roles = @()

    foreach ($subscription in $subscriptions) {

        Select-AzSubscription -Subscription @Subscription

        $ADUsers | ForEach-Object -Parallel{
            $roles = Get-AzRoleAssignment -SignInName $_.UserPrincipalName -ExpandPrincipalGroups -WarningAction SilentlyContinue | Select-Object DisplayName, RoleDefinitionName, Scope
            foreach ($role in $roles){
                $object = [PSCustomObject]@{
                    UserDisplayName = $_.DisplayName
                    UserPrincipalName = $_.UserPrincipalName
                    UserType = $_.UserType
                    AccountEnabled = $_.AccountEnabled
                    AssignmentMode = $role.DisplayName
                    RoleDefinitionName = $role.RoleDefinitionName
                    Scope = $role.Scope
                    #Subscription = $subscription.SubscriptionName
                }
                $done = $false    
                $loops = 1
                While(-Not $done -and $loops -lt 1000) {
                    try {
                        $object | Export-Csv -Path .\RolesPerUserComplete.csv -Append -NoTypeInformation
                        $done = $true
                    } catch {
                        Start-Sleep -Milliseconds 10
                        $loops += 1
                    }
                }
                #$object | Export-Csv -Path .\RolesPerUser.csv -Append -NoTypeInformation
                Write-Host "#################### User $($_.UserPrincipalName); Role $($role.RoleDefinitionName), Scope $($role.Scope) ###############"
            }
        } -ThrottleLimit 50
    }
    $stopwatch
    $stopwatch.Stop()
}

Import-Module Az
Import-Module AzureAD -UseWindowsPowerShell
Connect-AzAccount 
Connect-AzureAD 

getMcCainADUsers
getMcCainRBAC
getMcCainSubscriptions $subscriptions, $ADUsers
