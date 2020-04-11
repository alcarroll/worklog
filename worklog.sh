#! /bin/bash

## TO DO
## - improve breakdown date entry
## - add monthly and yearly arguments for breakdown 

function worklog()
{
datetime=$(date +%a,%d%b%Y,%H:%M)
usage="
(worklog) [ -L ] [-r] [-n] [-l] [-h n] -- display help for global support functions

where:
    -L login/logout 
    -r log a ticket reply
    -n log a note
    -l log lunch start/stop (will auto detect start/stop)
    -h show this help contents
"

if [ $# -eq 0 ]
  then
    printf "\nThe ticketlog command requires arguments:\n\n$usage"
    else
#    local OPTIND option
    while getopts ":Lrnl" option; do
     case $option in
        r) read -ep "Enter ticket ID: " ticketid
            read -ep "Enter tier: " tier
            read -ep "Enter description: " descrip
            printf "$datetime,$ticketid,T$tier,$descrip\n" >> ~/worklog/logs/replies.log
            printf "Reply logged!" ;;
        n) read -ep "Enter note :" notecontent
            printf "$datetime,NOTE,N,$notecontent\n" >> ~/worklog/logs/replies.log ;;
        l) lunchstatus=$(tail -1 ~/worklog/logs/replies.log | grep "Lunch start")
            if [ -z "$lunchstatus" ]
            then
            printf "$datetime,NOTE,L,Lunch start\n" >> ~/worklog/logs/replies.log 
                else
            printf "$datetime,NOTE,L,Lunch end\n" >> ~/worklog/logs/replies.log
            fi ;;
        L) loginstatus=$(grep -E 'LOGIN|LOGOUT' ~/worklog/logs/replies.log | tail -1 | awk -F"," '{print $4}')
            if [[ "$loginstatus" == "LOGOUT" ]]; then
                printf "$datetime,LOGIN\n" >> ~/worklog/logs/replies.log
            else
                printf "$datetime,LOGOUT\n" >> ~/worklog/logs/replies.log
            fi ;;
       \?) echo -e "\nInvalid option:\n" >&2
           echo "$usage" >&2 ;;
     esac
done
fi
}

## breakdown function WIP
function breakdown()
{
shifthours=(21 22 23 00 01 02 03 04)

read -ep "Year: " startyear
read -ep "Month: " startmonth
read -ep "Day shift started on: " startday


starton="$startday$startmonth$startyear"
endon="$endday$endmonth$endyear"

echo $starton
echo $endon


for h in ${shifthours[@]}; do
        hourcount=$(grep -i $startday$startmonth ~/worklog/logs/replies.log | grep ",$h" | grep -vE ',L,|,N,' | wc -l | tr -d '[:space:]');
        printf "hour:\t\t $h:00\nticket count:\t $hourcount\n";
#        shiftnotes=$()
    done
}
