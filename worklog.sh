#! /bin/bash
function worklog()
{
dateonly=$(date +%a,%d%b%Y)
datetime=$(date +%a,%d%b%Y,%H:%M)
usage="
(worklog) [-L ] [-r] [-n] [-l] [-e ][-h n] -- display help for worklog

where:
    -L login/logout 
    -r log a ticket reply
    -n log a note
    -l log lunch start/stop (will auto detect start/stop)
    -t review today's log enties
    -e manually edit log
    -h show this help contents
"

if [ $# -eq 0 ]
  then
    printf "\nWorklog requires arguments:\n\n$usage"
    else
    local OPTIND option
    while getopts ":Lrnlet" option; do
     case $option in
        # Ticket reply entry
        r) read -ep "Enter ticket ID: " ticketid
            read -ep "Enter tier: " tier
            read -ep "Enter description: " descrip
            printf "$datetime,$ticketid,T$tier,$descrip\n" >> ~/worklog/logs/work.log
            printf "\nReply logged!\n" 
            # Output most recent log entries:
            printf "\n\nMost recent log activity:\n$(tail -3 ~/worklog/logs/work.log)\n\n" ;;
        # Ticket note entry
        n) read -ep "Enter note: " notecontent
            printf "$datetime,NOTE,N,$notecontent\n" >> ~/worklog/logs/work.log
            printf "\nNote logged!\n"
            # Output most recent log entries:
            printf "\n\nMost recent log activity:\n$(tail -3 ~/worklog/logs/work.log)\n\n" ;;
        # Start and stop lunch
        l) lunchstatus=$(tail -1 ~/worklog/logs/work.log | grep "Lunch start")
            if [ -z "$lunchstatus" ]
            then
            printf "$datetime,NOTE,L,Lunch start\n" >> ~/worklog/logs/work.log
            printf "\nLunch start logged!\n"
                else
            printf "$datetime,NOTE,L,Lunch end\n" >> ~/worklog/logs/work.log
            printf "\nLunch stop logged!\n"
            fi ;;
        # Log in and out   
        L) loginstatus=$(grep -E 'LOGIN|LOGOUT' ~/worklog/logs/work.log | tail -1 | awk -F"," '{print $3}')
            if [[ "$loginstatus" == "LOGOUT" ]]; then
                printf "$dateonly,LOGIN\n" >> ~/worklog/logs/work.log
                printf "\nLogged in!\n"
            else
                printf "$dateonly,LOGOUT\n" >> ~/worklog/logs/work.log
                printf "\nLogged out!\n"
            fi ;;
        # Manual log edit    
        e) vim ~/worklog/logs/work.log ;;
        # Review today's log
        t)  # Find start of this shfit
            todaylogin=$(cat ~/worklog/logs/work.log | sed '1!G;h;$!d' | grep LOGIN | head -1)
            # Get today's log entries
            awk '/'$todaylogin'/,0' ~/worklog/logs/work.log >> ~/worklog/files/today.tmp
            todayreplycount=$(cat ~/worklog/files/today.tmp | grep -vE ',N,|,L,|LOGIN|LOGOUT' | wc -l)
            todaynotecount=$(cat ~/worklog/files/today.tmp | grep ",N," | wc -l)
            # Display today's data
            printf "\n This shfit's log entries:\n $todayentries\n\nTotal replies: $todayreplycount\nTotal notes: $todaynotecount\n\n"
            # Clean up
            rm ~/worklog/files/today.tmp;;
        # Invalid response handling
       \?) printf "\nInvalid option:\n" >&2
           printf "$usage" >&2 ;;
     esac
done
fi

## End of worklog funcion
}


function breakdown()
{
shifthours=(21 22 23 00 01 02 03 04)
months=(Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec)

usage="
(breakdown) [-L ] [-r] [-n] [-l] [-e ][-h n] -- display help for breakdown

where:
    -d get log breakdown for a day 
    -m get monthly log breakdown
    -y get yearly log breakdown

"

if [ $# -eq 0 ]
  then
    printf "\nWorklog requires arguments:\n\n$usage"
    else
    local OPTIND option
    while getopts ":dmy" option; do
     case $option in
        # Day breakdown
        d) read -ep "Date shift started on (DDMonYYYY): " bdday
            # Gather shift data from work.log
            awk '/'$bdday',LOGIN/,/LOGOUT/' ~/worklog/logs/work.log | grep -vE 'LOGIN|LOGOUT' > ~/worklog/files/breakdown.tmp
            # Gather and output reply counts
            printf "\nReply count by hour:\n\n"
            for h in ${shifthours[@]}; do
                hourcount=$(cat ~/worklog/files/breakdown.tmp | grep ",$h" | grep -vE ',L,|,N,' | wc -l | tr -d '[:space:]');
                printf "hour:\t\t $h:00\nticket count:\t $hourcount\n";
            done
            printf "\nShift notes: \n\n$(grep ",N," ~/worklog/files/breakdown.tmp | awk -F',' '{print $3,$6}')\n\n"
            # Cleanup
            rm ~/worklog/files/breakdown.tmp ;;
        # Monthly breakdown
        m)  read -ep "Enter month to review (MonYYYY): " bdmonth
            printf "\nMontly breadwon for $bdmonth: \n\n"
            # Gather and output breakdown by day of month
            grep $bdmonth ~/worklog/logs/work.log | awk -F"," '{freq[$2]++} END {for (x in freq) {print x, freq[x]}}' | sort | while read line; do 
                shiftdate=$(echo $line | awk '{print $1}');
                shiftreplycount=$(grep $shiftdate ~/worklog/logs/work.log | grep -Ev ',N,|,L,|LOGIN|LOGOUT' | wc -l);
                shiftnotecount=$(grep $shiftdate ~/worklog/logs/work.log | grep ",N,"| wc -l); 
                printf "$shiftdate \n reply count: $shiftreplycount\n note count: $shiftnotecount\n"; 
                done
                printf "\n\n" ;;
        # Yearly breakdown
        y)  read -ep "Enter month to review (YYYY): " bdyear
            printf "\n Breadown for $bdyear:"
            # Gather and output breakdown by month of year
            for m in ${months[@]}; do 
                monthreplycount=$(grep $m$bdyear ~/worklog/logs/work.log | grep -vE ',N,|,L,|LOGIN|LOGOUT' | wc -l); 
                monthnotecount=$(grep $m$bdyear ~/worklog/logs/work.log | grep ",N," | wc -l); 
                printf "\nMonth: $m$bdyear\nReply count: $monthreplycount\nNote count: $monthnotecount\n"; 
            done ;;
        # Invalid response handling
       \?) printf "\nInvalid option:\n" >&2
           printf "$usage" >&2 ;;
    esac
done 
fi
## End of breakdown function
}