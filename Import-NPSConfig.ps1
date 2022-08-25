### This script is no longer used. Everything is done from the Export-NPSConfig.ps1 script. This is only included for posterity, you don't need it.

<#
.SYNOPSIS
  Name: Import-NPSConfig.ps1
  The purpose of this script is to import an NPS config file
  
.DESCRIPTION
  This script will import another server's NPS config from a file on a DFS share to the local server

.NOTES
    Release Date: 2019-12-19T10:09
    Last Updated: 2021-07-21T12:07
   
    Author: Luke Nichols
#>

#In order to make debugging in PowerShell ISE easier, clear the screen at the start of the script
Clear-Host

### Dot-source functions from C:\Scripts\includes\ ###
. "$(Split-Path $MyInvocation.MyCommand.Path -Parent)\..\includes\Write-Log.ps1"

### Define variables ###

$PathToConfig = "C:\Scripts\NPSConfig\cfg"

#Get the current date
[DateTime]$currentDate=Get-Date

#Grab the individual portions of the date and put them in vars
$currentYear = $($currentDate.Year)
$currentMonth = $($currentDate.Month).ToString("00")
$currentDay = $($currentDate.Day).ToString("00")

$currentHour = $($currentDate.Hour).ToString("00")
$currentMinute = $($currentDate.Minute).ToString("00")
$currentSecond = $($currentDate.Second).ToString("00")

$LogFilePath = "C:\Scripts\NPSConfig\logs\$($env:computername)_Import_$($currentYear)-$($currentMonth)-$($currentDay)T$($currentHour)$($currentMinute)$($currentSecond).txt"
#Write-Host "`$LogFilePath: $LogFilePath"

### Open log file ###

Write-Log -LogString "Opening log file" -LogFilePath $LogFilePath

### Script main body ###

#Find the newest config file from the DFS share
$NewestConfigFile = get-childitem -path $PathToConfig | sort LastWriteTime | select -last 1
$FullPathToNewestConfigFile = "$($PathToConfig)\$($NewestConfigFile.Name)"
netsh nps import filename = "$FullPathToNewestConfigFile"
$LogString = "Imported NPS config file $FullPathToNewestConfigFile"
Write-Log -LogString $LogString -LogFilePath $LogFilePath
#Write-Host $LogString 

## Close log file ##
Write-Log -LogString "Close log file." -LogFilePath $LogFilePath -LogRotateDays 30

### End of script main body ###
break
exit