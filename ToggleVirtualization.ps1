#Requires -RunAsAdministrator

$BiosChangesMade = $False

$temp = Get-WmiObject -class Lenovo_BiosSetting -namespace root\wmi | Where-Object {$_.CurrentSetting.split(",",[StringSplitOptions]::RemoveEmptyEntries) -eq "AmdVt"} | Format-List CurrentSetting | Out-String
if ($temp.Length -gt 0) { # Setting was found
    $setting = $temp.split(',')[1].Trim()
    if ($setting -eq "Disable") {
       Write-Host "AmdVt is disabled.  Enabling now."
       (Get-WmiObject -class Lenovo_SetBiosSetting –namespace root\wmi).SetBiosSetting("AmdVt,Enable")
       $BiosChangesMade = $True
    }
    else {
       Write-Host "AmdVt was already enabled"
    }
}
else {
       Write-Host "AmdVt setting not found"
}


$temp = Get-WmiObject -class Lenovo_BiosSetting -namespace root\wmi | Where-Object {$_.CurrentSetting.split(",",[StringSplitOptions]::RemoveEmptyEntries) -eq "VirtualizationTechnology"} | Format-List CurrentSetting | Out-String
if ($temp.Length -gt 0) { # Setting was found
    $setting = $temp.split(',')[1].Trim()
    if ($setting -eq "Disable") {
       Write-Host "VirtualizationTechnology is disabled.  Enabling now."
       (Get-WmiObject -class Lenovo_SetBiosSetting –namespace root\wmi).SetBiosSetting("VirtualizationTechnology,Enable")
       $BiosChangesMade = $True
    }
    else {
       Write-Host "VirtualizationTechnology was already enabled"
    }
}
else {
       Write-Host "VirtualizationTechnology setting not found"
}

$temp = Get-WmiObject -class Lenovo_BiosSetting -namespace root\wmi | Where-Object {$_.CurrentSetting.split(",",[StringSplitOptions]::RemoveEmptyEntries) -eq "VTdFeature"} | Format-List CurrentSetting | Out-String
if ($temp.Length -gt 0) { # Setting was found
    $setting = $temp.split(',')[1].Trim()
    if ($setting -eq "Disable") {
       Write-Host "VTdFeature is disabled.  Enabling now."
       (Get-WmiObject -class Lenovo_SetBiosSetting –namespace root\wmi).SetBiosSetting("VTdFeature,Enable")
       $BiosChangesMade = $True
    }
    else {
       Write-Host "VTdFeature was already enabled"
    }
}
else {
       Write-Host "VTdFeature setting not found"
}

# Restart if changes were made
if ($BiosChangesMade -eq $True) {
   (Get-WmiObject -class Lenovo_SaveBiosSettings -namespace root\wmi).SaveBiosSettings() 
   Write-Host "Saving BIOS changes"
   Write-Host 'A reboot is required for the changes to take effect.  Would you like to restart now? [y,any other key = no]'
   $KeyPress = [System.Console]::ReadKey('NoEcho,IncludeKeyDown')
   $key = $KeyPress.Key.ToString()
   Write-Host "key: $key"
   if ($key -eq 'Y') {
      Write-Host "Restarting..."
      Restart-Computer
   }
   
}
else {
   Write-Host "No BIOS changes were made."
}