$sb =  {
    Param($ADUser, $outLog)
    
    $roles = Get-AzRoleAssignment -SignInName $_.UserPrincipalName -ExpandPrincipalGroups -WarningAction SilentlyContinue | Select-Object DisplayName, RoleDefinitionName, Scope
    foreach ($role in $roles){
        $report = [PSCustomObject]@{
            UserDisplayName = $_.DisplayName
            UserPrincipalName = $_.UserPrincipalName
            AssignmentMode = $role.DisplayName
            RoleDefinitionName = $role.RoleDefinitionName
            Scope = $role.Scope
        }
        $final += $report
        Write-Output -InputObject $final
    }
}
 
 foreach($ADUser in $ADUsers){
    while ((Get-Job -State Running).Count -ge 20) {
       Start-Sleep -Seconds 5;
    }
    Start-Job -Scriptblock $sb -ArgumentList $ADUser
 }
 Get-Job | Wait-Job | Receive-Job | Out-File -Append -FilePath $outLog


 ############
$getRoles = {
    Param($ADUsers)
    $roles = Get-AzRoleAssignment -SignInName $_.UserPrincipalName -ExpandPrincipalGroups -WarningAction SilentlyContinue | Select-Object DisplayName, RoleDefinitionName, Scope
}

$global:users = @()
$global:job = @()
$global:users = ("diogo.maul@mccain.ca","chris.best@mccain.ca")
$global:users | ForEach-Object -Parallel {
        $_
        $global:job = Start-Job -ScriptBlock {Get-AzRoleAssignment -SignInName $_ -ExpandPrincipalGroups -WarningAction SilentlyContinue | Select-Object DisplayName, RoleDefinitionName, Scope}
        Receive-Job -Job $global:job
        $job = $global:job
}
Get-Job
$global:job
$job
Receive-Job -Job 

Get-Variable -Scope global


$jobs=Invoke-Command -ComputerName $computers -ScriptBlock {
    GWMI Win32_OperatingSystem | Select PScomputerName,Version
} -asjob
 Wait-job $jobs
 $jobs | Receive-job | Select PScomputerName,Version | Export-CSV 'c:\temp\temp.csv' -NoTypeInformation