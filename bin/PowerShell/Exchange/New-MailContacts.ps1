$csv = import-csv ad_vt3_copy1.csv
 
foreach($user in $csv){
        new-mailcontact -name $user.name -firstname $user.firstname -lastname $user.lastname -externalemailaddress $user.externalemailaddress -organizationalunit "dexter.dexteraxle.com/AL-KO VT"
        #set-mailcontact -identity $user.name -phone $user.phone -streetaddress $user.streetaddress -postalcode $user.postalcode -company $user.company -department $user.department -office $user.officename -title $user.title
        }


Invoke-Expression .\Set-MailContacts.ps1
