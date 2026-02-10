$mbs = import-csv .\users.csv

foreach($mb in $mbs){
set-Mailbox $mb.username -UseDatabaseQuotaDefaults:$False -issuewarningQuota "UNLIMITED" -ProhibitSendQuota "UNLIMITED" -ProhibitSendReceive "UNLIMITED"
}
