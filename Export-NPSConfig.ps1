<#
.SYNOPSIS
  Name: Export-NPSConfig.ps1
  The purpose of this script is to replicate NPS configuration between servers
  
.DESCRIPTION
  This script will export the local server's NPS config to a file and then import it to all other NPS servers in $ArrayOfNPSServers

.NOTES
    Release Date: 2019-12-19T10:09
    Last Updated: 2022-09-06T09:55
   
    Author: Luke Nichols
#>

#In order to make debugging in PowerShell ISE easier, clear the screen at the start of the script
Clear-Host

#Change the working directory to $PSScriptRoot
Set-Location $PSScriptRoot

### Dot-source functions ###
. "$PSScriptRoot\..\Write-Log\Write-Log.ps1" #Relies on https://github.com/jlukenichols/Write-Log
. "$PSScriptRoot\..\Write-Log\Delete-OldFiles.ps1" #Relies on https://github.com/jlukenichols/Write-Log

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
. "$PSScriptRoot\DefaultConfig.ps1"
if (Test-Path "$PSScriptRoot\CustomConfig.ps1") {
    . "$PSScriptRoot\CustomConfig.ps1"
}

#Grab the name of the parent folder for "logs"
$LogFileParentPath = Split-Path -parent $LogFilePath
#Check if $LogFileParentPath already exists
if (Test-Path $LogFileParentPath) {
    #Folder already exists, do nothing
} else {
    #Folder does not exist, create it
    New-Item -Path (Split-Path -parent $LogFileParentPath) -ItemType Directory -Name $(Split-Path -Leaf $LogFileParentPath)
}

#Grab the name of the parent folder for "cfg"
$ExportFileParentPath = Split-Path -parent $ExportFileName
#Check if $ExportFileParentPath already exists
if (Test-Path $ExportFileParentPath) {
    #Folder already exists, do nothing
} else {
    #Folder does not exist, create it
    New-Item -Path (Split-Path -parent $ExportFileParentPath) -ItemType Directory -Name $(Split-Path -Leaf $ExportFileParentPath)
}

### Open log file ###
Write-Log -LogString "Opening log file" -LogFilePath $LogFilePath
Write-Log -LogString "`$ArrayOfNPSServers: $ArrayOfNPSServers" -LogFilePath $LogFilePath

### Script main body ###

#Export config
netsh nps export filename = "$ExportFileName" exportPSK = YES #WARNING: This will export PSK's (secrets) in plain text. Make sure you save this file to a secure location.
Write-Log -LogString "Exported config to $ExportFileName" -LogFilePath $LogFilePath
#Loop through each server in the array
foreach ($Server in $ArrayOfNPSServers) {
    #Make sure $Server is not the server we are running this on
    if ($Server -notlike "$env:COMPUTERNAME*") {
        $LogString = "Importing config on server $Server"
        Write-Log -LogString $LogString -LogFilePath $LogFilePath
        Write-Host $LogString
        netsh -r $Server nps import filename = "$ExportFileName"
    }
}

#Optionally delete the config file if you are worried about storing secrets in plaintext
if ($DeleteConfigFileAfterReplication -eq $true) {
    Remove-Item $ExportFileName
}

## Close log file ##
Write-Log -LogString "Close log file." -LogFilePath $LogFilePath -LogRotateDays $LogRotateDays

#Delete old NPS config files
Delete-OldFiles -NumberOfDays $ConfigFileRotateDays -PathToFiles $ExportFileParentPath -FileTypeExtension "xml"

### End of script main body ###
break
exit