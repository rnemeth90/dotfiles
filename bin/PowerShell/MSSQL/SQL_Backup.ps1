#Script to backup all SQL databases in SQL Server 2008
#Created by: Ryan Nemeth / Pinnacle Group of Indiana
#10/12/2013 10:30 PM

import-module SQLPS -disablenamechecking

#backup-sqldatabase -serverinstance %% -database %% -backupaction %%

#cd's to the default location for SQL server databases
Set-Location SQLSERVER:\SQL\TESTSQL\DEFAULT\Databases

#creates a for loop that will parse through every db in the directory
#and assing it's name to the db variable
foreach ($db in (Get-ChildItem))
    {
        #applies the name function to the db variable and assigns
		#it to the dbname variable
		$dbname = $db.Name
		
		#get's the current date and time, assigns to the dt variable
		#this will be used later for file naming
        $dt = Get-Date -Format yyyyMMddHHmmss
		
		#creates backups of all databases in the dbname variable
		#and names the file %dbname%%date/time%.bak
        Backup-SqlDatabase -Database $dbname -BackupFile "$($dbname)_db_$($dt).bak"
    }

	