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
            printf "$datetime,$ticketid,T$tier,$descrip\n" >> ~/worklog/logs/work.log
            printf "\nReply logged!\n" ;;
        n) read -ep "Enter note: " notecontent
            printf "$datetime,NOTE,N,$notecontent\n" >> ~/worklog/logs/work.log
            printf "\nNote logged!\n" ;;
        l) lunchstatus=$(tail -1 ~/worklog/logs/work.log | grep "Lunch start")
            if [ -z "$lunchstatus" ]
            then
            printf "$datetime,NOTE,L,Lunch start\n" >> ~/worklog/logs/work.log
            printf "\nLunch start logged!\n"
                else
            printf "$datetime,NOTE,L,Lunch end\n" >> ~/worklog/logs/work.log
            printf "\nLunch stop logged!\n"
            fi ;;
        L) loginstatus=$(grep -E 'LOGIN|LOGOUT' ~/worklog/logs/work.log | tail -1 | awk -F"," '{print $3}')
            if [[ "$loginstatus" == "LOGOUT" ]]; then
                printf "$dateonly,LOGIN\n" >> ~/worklog/logs/work.log
                printf "\nLogged in!\n"
            else
                printf "$dateonly,LOGOUT\n" >> ~/worklog/logs/work.log
                printf "\nLogged out!\n"
            fi ;;
       \?) echo -e "\nInvalid option:\n" >&2
           echo "$usage" >&2 ;;
     esac
done
fi

# Output most recent log entries:
printf "\n\nMost recent log activity:\n$(tail -3 ~/worklog/logs/work.log)\n\n"

## End of worklog funcion
}


function breakdown()
{
shifthours=(21 22 23 00 01 02 03 04)

read -ep "Date shift started on (DDMonYYYY): " startdate
#create tmp file
awk '/'$startdate',LOGIN/,/LOGOUT/' ~/worklog/logs/work.log | grep -vE 'LOGIN|LOGOUT' > ~/worklog/files/breakdown.tmp

printf "\nReply count by hour:\n\n"
for h in ${shifthours[@]}; do
        hourcount=$(cat ~/worklog/files/breakdown.tmp | grep ",$h" | grep -vE ',L,|,N,' | wc -l | tr -d '[:space:]');
        printf "hour:\t\t $h:00\nticket count:\t $hourcount\n";
    done

printf "\nShfit notes: \n\n$(grep ",N," ~/worklog/files/breakdown.tmp | awk -F',' '{print $3,$6}')\n\n"

rm ~/worklog/files/breakdown.tmp
## End of breakdown function
}