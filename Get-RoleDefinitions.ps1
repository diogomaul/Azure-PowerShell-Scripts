Connect-AzAccount
Connect-AzureAD 

$stopwatch =  [system.diagnostics.stopwatch]::StartNew()
$Subscriptions =  Get-AzSubscription #-SubscriptionId 6b5fafad-c388-4834-8e16-daf9828deb84
$ADUsers = @()
$ADUsers = Get-AzureADUser -All $true | Where-Object {$_.DirSyncEnabled -eq $true -and $_.AccountEnabled -eq $true} | Select-Object DisplayName, UserPrincipalName, UserType, AccountEnabled, ObjectId 
Write-Output $ADUsers.UserPrincipalName >> .\ADUsers.log
Write-Host "$($ADUsers.count) users found"
Write-Host "Time elapsed $($stopwatch.elapsed)"

foreach ($subscription in $subscriptions) {
    $stopwatch =  [system.diagnostics.stopwatch]::StartNew()
    foreach ($ADUser in $ADUsers){
        $roles = Get-AzRoleAssignment -SignInName $ADUser.UserPrincipalName -ExpandPrincipalGroups -WarningAction SilentlyContinue | Select-Object DisplayName, SignInName, RoleDefinitionName, Scope

        #if ($true -eq $roles){
        #    Write-Host "User $($ADUser.UserPrincipalName) is active, $($stopwatch.elapsed)"
        #}

        if ($true -eq $roles){
            foreach ($role in $roles){
                $object = [PSCustomObject]@{
                    UserDisplayName = $ADUser.DisplayName
                    UserPrincipalName = $ADUser.UserPrincipalName
                    AssignmentMode = $role.DisplayName
                    RoleDefinitionName = $role.RoleDefinitionName
                    Scope = $role.Scope
                }
            $object | Export-Csv -Path .\RolesPerUserSerial.csv -Append -NoTypeInformation
            Write-Host "#################### User $($ADUser.UserPrincipalName); Role $($role.RoleDefinitionName), Scope $($role.Scope) $($stopwatch.elapsed) ###############"
            Write-Output "User $($ADUser.UserPrincipalName), Role $($role.RoleDefinitionName), $($stopwatch.elapsed)" >> .\RBACs.log
            }
        }
    }
    $stopwatch
}

$stopwatch.Stop()

###################################### DRAFT ########################################

<#$list = @()

$users = Get-AzureADUser -Top 50 | Where-Object {$_.DirSyncEnabled -eq $true} | Select-Object DisplayName, UserPrincipalName, UserType, AccountEnabled, ObjectId 
$users.count

$users = Get-AzureADUser -All $true | Where-Object {$_.UserPrincipalName -eq "admdimaul@mccain.com"} | Select-Object DisplayName, UserPrincipalName, UserType, AccountEnabled, ObjectId 

$users = @()
#$users = ("Chris.BEST@mccain.ca","admdimaul@mccain.com","admchbest@mccain.com", "admvikilari@mccain.com")



foreach ($user in $users){
    $ADUsers += Get-AzureADUser -ObjectID $user | Select-Object DisplayName, UserPrincipalName, UserType, AccountEnabled, ObjectId 
    }




$users = Get-AzureADUser -Top 1000 | Where-Object {$_.DirSyncEnabled -eq $true -and $_.AccountEnabled -eq $true} | Select-Object DisplayName, UserPrincipalName, UserType, AccountEnabled, ObjectId 

$roles = @()
foreach ($user in $users){
    #$roles = @()
    $roles += Get-AzRoleAssignment -SignInName $user.UserPrincipalName -ExpandPrincipalGroups -WarningAction SilentlyContinue | Select-Object DisplayName, SignInName, RoleDefinitionName, Scope 
    foreach ($role in $roles){
        #Write-Host $role.Scope
        $object = New-Object PSObject 
        $object | Add-Member -type NoteProperty -Name UserDisplayName -Value $user.UserPrincipalName
        $object | Add-Member -type NoteProperty -Name RBACAssignmentName -Value $role.DisplayName
        $object | Add-Member -type NoteProperty -Name SignInName -Value $role.SignInName
        $object | Add-Member -type NoteProperty -Name RoleDefinitionName -Value $role.RoleDefinitionName
        $object | Add-Member -type NoteProperty -Name Scope -Value $role.Scope
        $object | Export-Csv -Path .\RolesPerUser.csv -Append -NoTypeInformation 
        Write-Host "$($role.DisplayName) added"
    }
}



$users = Get-AzureADUser -All $true | Where-Object UserType -eq "Guest" | Select-Object DisplayName, UserPrincipalName, UserType, AccountEnabled, ObjectId
$users.count

#>