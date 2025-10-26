#!/usr/bin/env bash
set -ux

timePre="$(date +'%T')"
sleep 10
timePost="$(date +'%T')"

### Convert time to a duration
startTime=$(date -u -d "$timePre" +"%s")
endTime=$(date -u -d "$timePost" +"%s")
procDur="$(date -u -d "0 $endTime sec - $startTime sec" +"%H:%M:%S")"
printf '%s\n' """
    The procss start    : $timePre
    The procss ended    : $timePost
    The process duration: $procDur
"""

