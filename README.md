# Worklog

Simple bash script to keep a log of personal work activity throughout a shift.

```
(worklog) [-L] [-r] [-n] [-C] [-R] [-l] [-e] [-h n] -- display help for worklog
  where:
    -L login/logout 
    -r log a ticket reply
    -n log a note
    -C log monitoring alert claim
    -R log montioring alert resolution
    -l set omni status to lunch (will auto detect start/stop)
    -p set omni status to phone
    -f set omni status to phasing
    -o set omni status to offline
    -t review today's log enties
    -e manually edit log
```
(breakdown) [-L] [-r] [-n] [-l] [-e] [-h n] -- display help for breakdown
where:
    -d get log breakdown for a specififed date 
    -m get log breakdown for a specififed month
    -y get log breakdown for a specififed year
```
