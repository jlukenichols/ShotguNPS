# DO NOT MODIFY DefaultConfig.ps1 !!!
# Changes to this file will be overwritten if you update your local repo after the remote repo is updated.
# If you want to make changes to the default config, make a copy of this file called CustomConfig.ps1 and make your changes there.
# The script will always load the DefaultConfig.ps1 file and IF a CustomConfig.ps1 file exists it will be loaded afterward, overwriting any duplicate settings with your custom ones.

#ISO-8601 format time zone code that you want your log files timestamped as. E.g. UTC is "Z", UTC-4 is "-4", etc.
$loggingTimeZone = "Z"

#Array of the hostnames of all your NPS servers. Best practice is to use FQDN.
[System.Collections.ArrayList]$ArrayOfNPSServers = "NPS2016-01.yourdomain.org","NPS2016-02.yourdomain.org"

#Full path to the log file. Best to leave at default unless you have a good reason to change it.
$LogFilePath = "$PSScriptRoot\logs\$($env:computername)_Export_$($currentYear)-$($currentMonth)-$($currentDay)T$($currentHour)$($currentMinute)$($currentSecond)$($loggingTimeZone).txt"

#Full path to the exported NPS config file. Best to leave at default unless you have a good reason to change it.
$ExportFileName = "$PSScriptRoot\cfg\$($env:computername)_$($currentYear)-$($currentMonth)-$($currentDay)T$($currentHour)$($currentMinute)$($currentSecond)$($loggingTimeZone).xml"

#Set this to $true if you want to delete your config file after replication. You might want to do this if you are worried about plaintext secrets being stored on the server.
#Set this to $false if you want to retain a history of your NPS config changes over time.
$DeleteConfigFileAfterReplication = $false

#This is how many days of logs your script will keep. It will delete anything that was created over this many days ago.
$LogRotateDays = 30

#This is how many days of config files your script will keep. It will delete anything that was created over this many days ago.
#Please note that if $DeleteConfigFilesAfterReplication -eq $true, this value is meaningless because the config files will always be deleted immediately after replication.
$ConfigFileRotateDays = 365