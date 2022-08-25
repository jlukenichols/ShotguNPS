<#
.SYNOPSIS
  Name: Export-NPSConfig.ps1
  The purpose of this script is to replicate NPS configuration between servers
  
.DESCRIPTION
  This script will export the local server's NPS config to a file on a DFS share and then import it to all other NPS servers in $ArrayOfNPSServers

.NOTES
    Release Date: 2019-12-19T10:09
    Last Updated: 2022-01-19T10:44
   
    Author: Luke Nichols
#>

#In order to make debugging in PowerShell ISE easier, clear the screen at the start of the script
Clear-Host

### Dot-source functions ###
. "..\Write-Log\Write-Log.ps1" #Relies on https://github.com/jlukenichols/Write-Log
. "..\Write-Log\Delete-OldFiles.ps1" #Relies on https://github.com/jlukenichols/Write-Log

### Define variables ###

#Get the current date and write it to a variable
#[DateTime]$currentDate=Get-Date #Local timezone
[DateTime]$currentDate = (Get-Date).ToUniversalTime() #UTC

#Grab the individual portions of the date and put them in vars
$currentYear = $($currentDate.Year)
$currentMonth = $($currentDate.Month).ToString("00")
$currentDay = $($currentDate.Day).ToString("00")

$currentHour = $($currentDate.Hour).ToString("00")
$currentMinute = $($currentDate.Minute).ToString("00")
$currentSecond = $($currentDate.Second).ToString("00")

#Dot-source config file(s)
. ".\DefaultConfig.ps1"
if (Test-Path ".\CustomConfig.ps1") {
    . ".\CustomConfig.ps1"
}

$LogFilePath = "$PSScriptRoot\logs\$($env:computername)_Export_$($currentYear)-$($currentMonth)-$($currentDay)T$($currentHour)$($currentMinute)$($currentSecond)$($loggingTimeZone).txt"

### Open log file ###
Write-Log -LogString "Opening log file" -LogFilePath $LogFilePath
Write-Log -LogString "`$ArrayOfNPSServers: $ArrayOfNPSServers" -LogFilePath $LogFilePath

### Script main body ###
#$ExportFileName = "$PSScriptRoot\cfg\$($env:computername)_$($currentYear)-$($currentMonth)-$($currentDay)T$($currentHour)$($currentMinute)$($currentSecond).xml"
#Export config
netsh nps export filename = "$ExportFileName" exportPSK = YES
Write-Log -LogString "Exported config to $ExportFileName" -LogFilePath $LogFilePath
#Loop through each server in the array
<#
foreach ($Server in $ArrayOfNPSServers) {
    #Make sure $Server is not the server we are running this on
    if ($Server -ne $env:COMPUTERNAME) {
        $LogString = "Importing config on server $Server"
        Write-Log -LogString $LogString -LogFilePath $LogFilePath
        Write-Host $LogString
        netsh -r $Server nps import filename = "$ExportFileName"
    }
}#>

## Close log file ##
Write-Log -LogString "Close log file." -LogFilePath $LogFilePath -LogRotateDays 30

#Delete old NPS config files
Delete-OldFiles -NumberOfDays 365 -PathToFiles $PSScriptRoot -FileTypeExtension "xml"

### End of script main body ###
break
exit