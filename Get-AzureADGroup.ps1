
install-module PSExcel 
Import-Module PSExcel

$path = "C:\Users\dimaul\OneDrive - McCain Foods Limited\Projects\RBAC\CompleteAzureRBAC.xlsx"

$groups = (Import-XLSX -Path $path -Sheet "AD Groups" -RowStart 1)
$list = @()

$RBAC = "" | Select-Object Group, Name, Email

foreach ($group in $groups)
    {
    #$groups.Group = $group.'AD Groups'

    $ADGroup = Get-AzureADGroup -SearchString $group.'AD Groups' | Select-Object DisplayName
    Write-Host $ADGroup.DisplayName
    $users = Get-AzureADGroup -SearchString $group.'AD Groups' | Get-AzureADGroupMember

    foreach ($user in $users)
        {
            #$item | Add-Member -type NoteProperty -Name 'Group' -Value $group.'AD Groups'
            $RBAC.Group = $group.'AD Groups'
            Write-Host $groups.Group 
            #$item | Add-Member -type NoteProperty -Name 'DisplayName' -Value $user.DisplayName
            $RBAC.Name = $user.DisplayName
            Write-Host $user.DisplayName

            #$item | Add-Member -type NoteProperty -Name 'Email' -Value $user.UserPrincipalName
            $RBAC.Email = $user.UserPrincipalName
            Write-Host $user.UserPrincipalName

            $list += $RBAC
            $RBAC = "" | Select-Object Group, Name, Email
            #$item = ""

            #pause
        }
    }

    $list |  Export-Csv -Path .\AzureADGroupMembership.csv -Append -NoTypeInformation 