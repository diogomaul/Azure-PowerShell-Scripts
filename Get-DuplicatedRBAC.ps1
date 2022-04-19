Connect-AzAccount
$Subscriptions =  Get-AzSubscription #-SubscriptionId 6b5fafad-c388-4834-8e16-daf9828deb84

foreach ($subscription in $subscriptions) {
    
    $Subscription =  Get-AzSubscription -SubscriptionId $subscription #f0b7fe8e-ca14-45a5-a259-0d64f2d6402d

    Select-AzSubscription -Subscription @Subscription
    $subRoleAssignments = Get-AzRoleAssignment -Scope "/subscriptions/$subscription" | Where-Object ObjectType -eq "User" | Select-Object SignInName, RoleDefinitionName, Scope, RoleAssignmentName #| Export-Csv -Path .\$($subscription.name)_List.csv -Append -NoTypeInformation 

    $resourceGroups  = Get-AzResourceGroup
    foreach ($resourceGroup in $resourceGroups) {
        $resourceGroup.ResourceGroupName
        $RGRoleAssignment = Get-AzRoleAssignment -Scope "/subscriptions/$subscription/resourcegroups/$($resourceGroup.ResourceGroupName)" | Where-Object ObjectType -eq "User" | Select-Object SignInName, RoleDefinitionName, Scope, RoleAssignmentName #| Export-Csv -Path .\RG_List.csv -Append -NoTypeInformation 
        foreach ($RGRole in $RGRoleAssignment){
            foreach ($SubRole in $SubRoleAssignments){
            if ($RGRole.RoleAssignmentName -ne $SubRole.RoleAssignmentName){
                if ($RGRole.SignInName -eq $SubRole.SignInName){
                    if ($RGRole.RoleDefinitionName -eq $SubRole.RoleDefinitionName){
                        if ($RGRole.Scope -ne $SubRole.Scope){
                            if ($SubRole.Scope -eq "/subscriptions/$subscription"){
                                Write-Host "Possible duplicated Role for User $($RGRole.SignInName) with the same Role $($RGRole.RoleDefinitionName), in two scopes Scope $($RGRole.Scope) and $($SubRole.Scope)"
                                $object = New-Object PSObject 
                                $object | Add-Member -type NoteProperty -Name User -Value $RGRole.SignInName
                                $object | Add-Member -type NoteProperty -Name Role -Value $RGRole.RoleDefinitionName
                                $object | Add-Member -type NoteProperty -Name Scope1 -Value $RGRole.Scope
                                $object | Add-Member -type NoteProperty -Name Scope2 -Value $SubRole.Scope
                                $object | Export-Csv -Path .\DuplicatedList.csv -Append -NoTypeInformation 
                                
                                #Write-Host "Permission at the Sub is: $($SubRole.RoleAssignmentName), $($SubRole.SignInName), Role $($SubRole.RoleDefinitionName), Scope $($SubRole.Scope)"
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

$objectCollection | Export-Csv c:\test.csv -NoTypeInformation
    

    ########################################### drafts ##########################################################

    
    #Check RBAC roles at the Management Group and Subscription level
    
   <# foreach ($SubRole in $subRoleAssignments) {
        #write-host $subRoleAssignments[$i]

        $i = $subRoleAssignments.Count
        if ($SubRole.SignInName -eq $subRoleAssignments[$i].SignInName){
        Write-Host "User $($SubRole.SignInName)"
        Write-Host $i
        $i --
        }
        if ($SubRole.RoleDefinitionName -eq $SubRole.RoleDefinitionName){
            Write-Host "User $($SubRole.SignInName), has the Role $($SubRole.RoleDefinitionName)"
                if ($SubRole.RoleAssignmentName -ne $subRoleAssignments.RoleAssignmentName){
                    #if ($_.Scope -eq  "/providers/Microsoft.Management/managementGroups/59fa7797-abec-4505-81e6-8ce092642190"){
                        Write-Host "The Subscription RBAC has entries with same name and same scope that might be unecessary: User $($SubRole.SignInName), has the Role $($SubRole.RoleDefinitionName), different Scope $($SubRole.Scope)"
                        #Write-Host "Permission at the MG is: $($SubRole.SignInName), Role $($SubRole.RoleDefinitionName), Scope $($SubRole.Scope)"
                    #    }
                    }
                }
            }
        } #>


            foreach ($RGRole in $RGRoleAssignment){
            foreach ($SubRole in $SubRoleAssignments){
                if ($RGRole.SignInName -eq $SubRole.SignInName){
                    if ($RGRole.RoleDefinitionName -eq $SubRole.RoleDefinitionName){
                        if ($RGRole.Scope -ne $SubRole.Scope){
                        Write-Host "Same name $($RGRole.SignInName) and same Role $($RGRole.RoleDefinitionName) and different Scope $($RGRole.Scope)"}
                        }
                    }
                }
            }


        #$RGRoleAssignment

        if ($result = Compare-Object $subRoleAssignments $RGRoleAssignment -Property Scope -IncludeEqual -ExcludeDifferent | ft) {
            Compare-Object $subRoleAssignments $RGRoleAssignment -Property SignInName, RoleDefinitionName -ExcludeDifferent -IncludeEqual | Select SignInName, RoleDefinitionName, Scope
            

        

$duplicatedRBAC = @()
$duplicatedRBAC = $RGRoleAssignment | % {compare-object $_ -DifferenceObject $subRoleAssignments -property SignInName, RoleDefinitionName -excludedifferent -includeequal -passthru | Select SignInName, RoleDefinitionName, Scope}

$badtemplates = diff $goodtemplates.name $templates.name


        $result = @()
        $RGRoleAssignment | ForEach-Object{
             if ($subRoleAssignments.SignInName -contains $_.SignInName){
                if($subRoleAssignments.RoleDefinitionName -contains $_.RoleDefinitionName){
                    #if($subRoleAssignments.Scope -notcontains $_.Scope){
                Write-Host $_.SignInName
                Write-Host $_}
                $result += $_
                }
            }
        #}
         
        
        foreach ($RGRole in $RGRoleAssignment){
            foreach ($SubRole in $SubRoleAssignments){
                if ($RGRole.SignInName -eq $SubRole.SignInName){
                    if ($RGRole.RoleDefinitionName -eq $SubRole.RoleDefinitionName){
                        if ($RGRole.Scope -ne $SubRole.Scope){
                        Write-Host "Same name $($RGRole.SignInName) and same Role $($RGRole.RoleDefinitionName) and different Scope $($RGRole.Scope)"
                        }
                    }
                }
            }
        }

                            
                }
            }
      



                  | Export-Csv -Path .\$($subscription.name)_RoleComparison.csv -Append -NoTypeInformation

        $subRoleAssignments | ForEach-Object{
        #$subObject = $_
        #    $RGRoleAssignment | ForEach-Object{
        #    $RGObject = $_
                $result = Compare-Object $subRoleAssignments $RGRoleAssignment -Property SignInName, RoleDefinitionName, RoleAssignmentName, Scope -IncludeEqual -ExcludeDifferent | ft
                }
        #    }

        #$subRoleAssignments.ToString()
        #if ($subRoleAssignments.SignInName -contains $_){
        #     Write-Host "`$SubRoleAssignments contains `$RGRoleAssignments object $_"
        #     if ($RGRoleAssignment.RoleDefinitionName -contains $_){
        #        Write-Host "$RGRoleAssignments.SignInName has the role $RGRoleAssignment.RoleDefinitionName and $SubRoleAssignments.RoleDefinitionName"
        #        }
        #    }
        #}
    }
}

$RGRoleAssignment[1]
$subRoleAssignments[0]


$RGRoleAssignment.ToString()
$subRoleAssignments.ToString()

Compare-Object $RGRoleAssignment $subRoleAssignments -IncludeEqual

$result = Compare-Object $RGRoleAssignment[1] $subRoleAssignments[0] -Property SignInName, RoleDefinitionName, RoleAssignmentName, Scope -IncludeEqual

if ($result.SideIndicator -eq "=="){
    Write-Host "repetidas"
    }


$RGRoleAssignment = ""

$Group1 = @("chris.best","diogo.maul","dan.taylor", "")
$Group2 = @("chris.best","andy.saunders","daniel.machado", "jenifer.becker")

      $Group1| ForEach-Object{
        if ($Group2 -contains $_){
             Write-Host " $_"
        }
    }

            
    #if ($RGRoleAssignment.SignInName -eq $subRoleAssignments.SignInName) {
    #    Write-Host "It's the same person"
    #else
    #    Write-Host "All Good"

Get-AzContext

Get-AzRoleAssignment -ResourceGroupName MF_PowerBI_Dev-RG