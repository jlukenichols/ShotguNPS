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
. "C:\Scripts\includes\Write-Log.ps1"
. "C:\Scripts\includes\Delete-OldFiles.ps1"

### Define variables ###

$PathToScriptParentFolder = "C:\Scripts\NPSConfig"

#Get the current date
[DateTime]$currentDate=Get-Date

#Grab the individual portions of the date and put them in vars
$currentYear = $($currentDate.Year)
$currentMonth = $($currentDate.Month).ToString("00")
$currentDay = $($currentDate.Day).ToString("00")

$currentHour = $($currentDate.Hour).ToString("00")
$currentMinute = $($currentDate.Minute).ToString("00")
$currentSecond = $($currentDate.Second).ToString("00")

$LogFilePath = "$PathToScriptParentFolder\logs\$($env:computername)_Export_$($currentYear)-$($currentMonth)-$($currentDay)T$($currentHour)$($currentMinute)$($currentSecond).txt"
#Write-Host "`$LogFilePath: $LogFilePath"

#Write the computer name to a variable
$ComputerName = $env:COMPUTERNAME

### Open log file ###
Write-Log -LogString "Opening log file" -LogFilePath $LogFilePath

#Array of all NPS servers
[System.Collections.ArrayList]$ArrayOfNPSServers = "NPS2016-01","NPS2016-02"
Write-Log -LogString "`$ArrayOfNPSServers: $ArrayOfNPSServers" -LogFilePath $LogFilePath

### Script main body ###
$ExportFileName = "$PathToScriptParentFolder\cfg\$($env:computername)_$($currentYear)-$($currentMonth)-$($currentDay)T$($currentHour)$($currentMinute)$($currentSecond).xml"
#Export config
netsh nps export filename = "$ExportFileName" exportPSK = YES
Write-Log -LogString "Exported config to $ExportFileName" -LogFilePath $LogFilePath
#Loop through each server in the array
<#
foreach ($Server in $ArrayOfNPSServers) {
    #Make sure $Server is not the server we are running this on
    if ($Server -ne $ComputerName) {
        $LogString = "Importing config on server $Server"
        Write-Log -LogString $LogString -LogFilePath $LogFilePath
        Write-Host $LogString
        netsh -r $Server nps import filename = "$ExportFileName"
    }
}#>

## Close log file ##
Write-Log -LogString "Close log file." -LogFilePath $LogFilePath -LogRotateDays 30

#Delete old NPS config files
Delete-OldFiles -NumberOfDays 365 -PathToFiles $PathToScriptParentFolder -FileTypeExtension "xml"

### End of script main body ###
break
exit