cls
$defaultForegroundColor = $host.ui.RawUI.ForegroundColor
$defaultBackgroundColor = $host.ui.RawUI.BackgroundColor
$host.ui.RawUI.ForegroundColor = "Yellow"
$host.ui.RawUI.BackgroundColor = "DarkGray"
Write-Output "                            _  _  _ ______ _       ______                                     "
Write-Output "                            (_)(_)(_) _____|_)     (_____ \                                    "
Write-Output "                            _  _  ( (____  _        ____) )                                   "
Write-Output "                           | || || \____ \| |      / ____/                                    "
Write-Output "                           | || || |____) ) |_____| (_____                                    "
Write-Output "                            \_____(______/|_______)_______)                                   "
Write-Output "                                                                                              "
Write-Output " ______  _     _ _ _       ______  _______ ______      ______ _______ _______ _     _ ______  "
Write-Output "(____  \(_)   (_) (_)     (______)(_______|_____ \    / _____|_______|_______|_)   (_|_____ \ "
Write-Output " ____)  )_     _| |_       _     _ _____   _____) )  ( (____  _____      _    _     _ _____) )"
Write-Output "|  __  (| |   | | | |     | |   | |  ___) |  __  /    \____ \|  ___)    | |  | |   | |  ____/ "
Write-Output "| |__)  ) |___| | | |_____| |__/ /| |_____| |  \ \    _____) ) |_____   | |  | |___| | |      "
Write-Output "|______/ \_____/|_|_______)_____/ |_______)_|   |_|  (______/|_______)  |_|   \_____/|_|      "
Write-Output "                                                                                              "
$host.ui.RawUI.BackgroundColor = $defaultBackgroundColor
$host.ui.RawUI.ForegroundColor = "Red"
Write-Output ""
Write-Output ""
Write-Output "This script is required NOT to be ran as an administrator (dont run PowerShell or PowerShell ISE as admin and execute script)."
Write-Output ""
$host.ui.RawUI.ForegroundColor = "Green"
Write-Output "This script is jsut meant for those that plan to do WSL2 Image Building as this has the environment vars required for the ansible code to run."
$host.ui.RawUI.ForegroundColor = $defaultForegroundColor
$host.ui.RawUI.BackgroundColor = $defaultBackgroundColor

Write-Output "Redhat Registry info can be found here: https://access.redhat.com/terms-based-registry/#/accounts"
$redhat_registry_user = Read-Host 'Enter Redhat Registry Username'
$redhat_registry_token = Read-Host 'Enter Redhat Registry Token'

Function Set-WSLENV-Environment-Variable {
    $userEnvironmentVars = [Environment]::GetEnvironmentVariables("User")
    $userAnsibleEnvironmentVars = $userEnvironmentVars.Keys | Where-Object {$_ -like "ANSIBLE*" }
    $userWslEnvVar = $userEnvironmentVars.Keys | Where-Object {$_ -eq "WSLENV" }
    $wslEnvArrayVar = New-Object System.Collections.ArrayList
    $suppressOutput = $wslEnvArrayVar.Add("USERPROFILE")
    $newWslEnvVar = New-Object System.Collections.ArrayList
    $needToCreateOrModifyWslEnvVar = $false
    if ($userAnsibleEnvironmentVars.Count -gt 0) {
        Write-Verbose "Found user ansible environment variables; ensuring available in WSLENV"
        foreach ($varAnsible in $userAnsibleEnvironmentVars) {        
            $suppressOutput = $wslEnvArrayVar.Add($varAnsible)
        }#end foreach
    }#end if
    if ($userWslEnvVar.Count -eq 0) {
        Write-Verbose "WSLENV user environment variable doesn't exist. Will create it..."
        $needToCreateOrModifyWslEnvVar = $true
        $newWslEnvVar = $wslEnvArrayVar
    }#end if
    else {
        Write-Verbose "WSLENV user environment variable already exists. Will keep existing values and possibly add to it."
        $wslEnvExistingVars = [Environment]::GetEnvironmentVariable("WSLENV", "User").Split(':')
        foreach ($varToAdd in $wslEnvArrayVar) {
            if (!$wslEnvExistingVars.Contains($varToAdd)) {
                  $needToCreateOrModifyWslEnvVar = $true  
                  $suppressOutput = $newWslEnvVar.Add($varToAdd)
            }#end if not already there
        }#end foreach var to ensure is part of WSLENV
        foreach ($existingVar in $wslEnvExistingVars) {
            if (!$newWslEnvVar.Contains($existingVar)) {
                  $suppressOutput = $newWslEnvVar.Add($existingVar)
            }#end if not already there
        }#end foreach existing var in WLSENV
    }#end else
    if ($needToCreateOrModifyWslEnvVar) {
        Write-Verbose "Before Value: $env:WSLENV"
        Write-Verbose "WSLENV user environment variable requires creation or modification."                         
        $wslEnvVarNewValueToSet = $newWslEnvVar -join ":"       
        $updateWslUserVarCommand = [Environment]::SetEnvironmentVariable("WSLENV", $wslEnvVarNewValueToSet, "User")  
        Start-Process PowerShell -ArgumentList "-command (Invoke-Expression {$updateWslUserVarCommand})" -WindowStyle Hidden -Wait -Verb RunAs                                   
        $env:WSLENV = $newWslEnvVar -join ":" # Force update to current session since it wont pick up the changes otherwise
        Write-Verbose "After Value: $env:WSLENV"
        Write-Verbose "WSLENV user environment variable updated."  

    }#end if 
    else {
        Write-Verbose "WSLENV user environment variable already exists and no modifications are required."
    }#end else
    return $true
}

[Environment]::SetEnvironmentVariable("ANSIBLE_REDHAT_USER", $redhat_registry_user, "User")
[Environment]::SetEnvironmentVariable("ANSIBLE_REDHAT_TOKEN", $redhat_registry_token, "User")
# Issue with passing %TOKEN% to WSLENV as it doesnt provide value but as string instead
Write-Output "Ensuring WSLENV user environment variable has default settings"
$setWslEnvReturnVal = Set-WSLENV-Environment-Variable
Write-Output "Done ensuring WSLENV user environment variable has default settings"
