#!/bin/bash
DIR="$( cd "$( dirname "{$BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

#Text for invalid arguments
help="Invalid argument provided please use:
\n--help to see available commands"

#Defaults
HOURS=0
MINUTES=0
SECONDS=0

#Checking if any arguments
if [ $# -eq 0 ]; then
    echo -e $help
    exit 1
fi

for arg in "$@" 
do
    case $arg in
        --help)
            echo -e "Commands used are:
            \n-h=HOURS
            \n-m=MINUTES
            \n-s=SECONDS
            \n-n=Name
            \n--id=MeetingID"
            exit 1
            ;;
        --id=*) 
            meetingId="${arg#*=}"
            shift
            ;;
        -n=*)
            name="${arg#*=}"
            shift
            ;;
        -h=*|--hours=*) 
            HOURS="${arg#*=}"
            HOURS=$((3600*HOURS))
            shift
            ;;
        -m=*|--minutes=*)
            MINUTES="${arg#*=}"
            MINUTES=$((60*MINUTES))
            shift
            ;;
        -s=*|--seconds=*)
            SECONDS="${arg#*=}"
            SECONDS=$((2+SECONDS))
            shift
            ;;
        \? ) 
            echo -e $help
            exit 1
            ;;
    esac
done

#Checking if meeting id has been provided
if [ -z ${meetingId+x} ]; then
    echo -e "Meeting ID was not entered please add Meeting ID with --id"
    exit 1
fi

#Checking if name has been provided
if [ -z ${name+x} ]; then
    echo -e "Name has not been entered please enter name with argument: -n"
    exit 1
fi

#Coverting time to seconds then checking if above minimum
time=$((HOURS+MINUTES+SECONDS))
if [ ${time} = 0 ]; then
    echo -e "Time is below minimum please add how many hours, minutes and seconds with: \n-h= -m= -s="
    exit 1
fi

#Creating file name
searchstring="-"

rest=${meetingId#*$searchstring}
offset=$(( ${#meetingId} - ${#rest} - ${#searchstring} ))
total=$(( ${#meetingId} - ${#offset} ))
filename="${name}${meetingId:offset:total}.webm"

#Meeting download command
node ./bbb-recorder/export.js "https://classroom.esp-ac.uk/playback/presentation/2.0/playback.html?meetingId=${meetingId}" $filename $time false

#Changing file extension