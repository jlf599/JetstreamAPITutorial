To set passwords via cleartext

`awk '{ system("echo " $1":"$2" |chpasswd") }' userlist.txt`

Assuming a file with username in col 1 and pass in col 2
