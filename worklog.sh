#! /bin/bash
function worklog()
{
# Create required directories
if [ ! -d "~/.worklog/" ]; then
    mkdir ~/.worklog/ > /dev/null 2>&1
fi

# Gather date and time info
dateonly=$(date +%a,%d%b%Y)
datetime=$(date +%a,%d%b%Y,%H:%M)

# Usage output
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
            printf "$datetime,$ticketid,T$tier,$descrip\n" >> ~/.worklog/work.log
            printf "\nReply logged!\n\n" 
            activereplycount=$(($activereplycount + 1))
            # Output most recent log entries:
            printf "\n\nMost recent log activity:\n\n$(tail -5 ~/.worklog/work.log)\n\nCurrent reply count: $activereplycount\n\n" ;;
        # Ticket note entry
        n) read -ep "Enter note: " notecontent
            printf "$datetime,NOTE,N,$notecontent\n" >> ~/.worklog/work.log
            printf "\nNote logged!\n\n"
            # Output most recent log entries:
            printf "\n\nMost recent log activity:\n$(tail -5 ~/.worklog/work.log)\n\n" ;;
        # Start and stop lunch
        l) lunchstatus=$(tail -1 ~/.worklog/work.log | grep "Lunch start")
            if [ -z "$lunchstatus" ]
            then
            printf "$datetime,NOTE,L,Lunch start\n" >> ~/.worklog/work.log
            printf "\nLunch start logged!\n\n"
                else
            printf "$datetime,NOTE,L,Lunch end\n" >> ~/.worklog/work.log
            printf "\nLunch stop logged!\n\n"
            fi ;;
        # Log in and out   
        L) loginstatus=$(grep -E 'LOGIN|LOGOUT' ~/.worklog/work.log | tail -1 | awk -F"," '{print $3}')
            if [[ "$loginstatus" == "LOGOUT" ]]; then
                printf "$dateonly,LOGIN\n" >> ~/.worklog/work.log
                printf "\nLogged in!\n\n"
                activereplycount=0
            else
                printf "$dateonly,LOGOUT\n" >> ~/.worklog/work.log
                printf "\nLogged out!\n\n"
            fi ;;
        # Manual log edit    
        e) "${EDITOR:-vim}" ~/.worklog/work.log ;;
        # Review today's log
        t)  # Find start of this shfit
            todaylogin=$(cat ~/.worklog/work.log | sed '1!G;h;$!d' | grep LOGIN | head -1)
            # Get today's log entries
            awk '/'$todaylogin'/,0' ~/.worklog/work.log >> ~/.worklog/today.tmp
            todayentries=$(cat ~/.worklog/today.tmp)
            todayreplycount=$(cat ~/.worklog/today.tmp | grep -vE ',N,|,L,|LOGIN|LOGOUT' | wc -l)
            todaynotecount=$(cat ~/.worklog/today.tmp | grep ",N," | wc -l)
            # Display today's data
            printf "\n This shfit's log entries:\n $todayentries\n\nTotal replies: $todayreplycount\nTotal notes: $todaynotecount\n\n"
            # Clean up
            rm ~/.worklog/today.tmp ;;
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
(breakdown) [-L ] [-r] [-n] [-l] [-e ] [-h n] -- display help for breakdown

where:
    -d get log breakdown for a specififed date 
    -m get log breakdown for a specififed month
    -y get log breakdown for a specififed year

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
            awk '/'$bdday',LOGIN/,/LOGOUT/' ~/.worklog/work.log | grep -vE 'LOGIN|LOGOUT' > ~/.worklog/breakdown.tmp
            # Gather and output reply counts
            printf "\nReply count by hour:\n\n"
            for h in ${shifthours[@]}; do
                hourcount=$(cat ~/.worklog/breakdown.tmp | grep ",$h" | grep -vE ',L,|,N,' | wc -l | tr -d '[:space:]');
                printf "hour:\t\t $h:00\nticket count:\t $hourcount\n";
            done
            printf "\nTotal replies: $(grep -vE ',N,|,L,'  ~/.worklog/breakdown.tmp | wc -l)\n"
            printf "\nShift notes: \n\n$(grep ",N," ~/.worklog/breakdown.tmp | awk -F',' '{print $3,$6}')\n\n"
            # Cleanup
            rm ~/.worklog/breakdown.tmp ;;
        # Monthly breakdown
        m)  read -ep "Enter month to review (MonYYYY): " bdmonth
            printf "\nMontly breadwon for $bdmonth: \n\n"
            # Gather and output breakdown by day of month
            grep $bdmonth ~/.worklog/work.log | awk -F"," '{freq[$2]++} END {for (x in freq) {print x, freq[x]}}' | sort | while read line; do 
                shiftdate=$(echo $line | awk '{print $1}');
                shiftreplycount=$(grep $shiftdate ~/.worklog/work.log | grep -Ev ',N,|,L,|LOGIN|LOGOUT' | wc -l);
                shiftnotecount=$(grep $shiftdate ~/.worklog/work.log | grep ",N,"| wc -l); 
                printf "$shiftdate \n reply count: $shiftreplycount\n note count: $shiftnotecount\n"; 
                done
                printf "\n\n"
                # Cleanup
                rm ~/.worklog/breakdown.tmp ;;
        # Yearly breakdown
        y)  read -ep "Enter month to review (YYYY): " bdyear
            printf "\n Breadown for $bdyear:"
            # Gather and output breakdown by month of year
            for m in ${months[@]}; do 
                monthreplycount=$(grep $m$bdyear ~/.worklog/work.log | grep -vE ',N,|,L,|LOGIN|LOGOUT' | wc -l); 
                monthnotecount=$(grep $m$bdyear ~/.worklog/work.log | grep ",N," | wc -l); 
                printf "\nMonth: $m$bdyear\nReply count: $monthreplycount\nNote count: $monthnotecount\n"; 
            done
            # Cleanup
            rm ~/.worklog/breakdown.tmp ;;
        # Invalid response handling
       \?) printf "\nInvalid option:\n" >&2
           printf "$usage" >&2 ;;
    esac
done 
fi
## End of breakdown function
}