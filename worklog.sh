#! /bin/bash
function worklog()
{
dateonly=$(date +%a,%d%b%Y)
datetime=$(date +%a,%d%b%Y,%H:%M)
usage="
(worklog) [ -L ] [-r] [-n] [-l] [-h n] -- display help for worklog

where:
    -L login/logout 
    -r log a ticket reply
    -n log a note
    -l log lunch start/stop (will auto detect start/stop)
    -h show this help contents
"

if [ $# -eq 0 ]
  then
    printf "\nWorklog requires arguments:\n\n$usage"
    else
    local OPTIND option
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
        L) loginstatus=$(grep -E 'LOGIN|LOGOUT' ~/worklog/logs/replies.log | tail -1 | awk -F"," '{print $3}')
            if [[ "$loginstatus" == "LOGOUT" ]]; then
                printf "$dateonly,LOGIN\n" >> ~/worklog/logs/replies.log
            else
                printf "$dateonly,LOGOUT\n" >> ~/worklog/logs/replies.log
            fi ;;
       \?) echo -e "\nInvalid option:\n" >&2
           echo "$usage" >&2 ;;
     esac
done
fi
}


function breakdown()
{
shifthours=(21 22 23 00 01 02 03 04)

read -ep "Date shift started on (DDMonYYYY): " startdate
#create tmp file
awk '/'$startdate',LOGIN/,/LOGOUT/' ~/worklog/logs/replies.log | grep -vE 'LOGIN|LOGOUT' > ~/worklog/logs/breakdown.tmp

for h in ${shifthours[@]}; do
        hourcount=$(cat ~/worklog/logs/breakdown.tmp | grep ",$h" | grep -vE ',L,|,N,' | wc -l | tr -d '[:space:]');
        printf "hour:\t\t $h:00\nticket count:\t $hourcount\n";
    done
}