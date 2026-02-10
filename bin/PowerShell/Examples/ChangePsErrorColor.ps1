# #############################################################################
# NAME: ChangePsErrorColor.ps1
# AUTHOR:  Ryan Nemeth
# DATE:  12/31/2014
# EMAIL: ryannemeth@live.com
# 
# COMMENT:  This script will change the font color of Powershell error messages
#
# VERSION HISTORY
# 1.0.2014.12.31 Initial Version.
# 
# TO ADD
# -?
# #############################################################################

write-host "What color would you like errors to appear in?"
$color = read-host " "
$host.PrivateData.ErrorForegroundColor = $color