#!/usr/bin/env bash
#  PURPOSE: Get updates, Xcode CLI Tools, and some package details without pain.
#           For use with a new macOS install.
# -----------------------------------------------------------------------------
#  PREREQS: none
# -----------------------------------------------------------------------------
#  EXECUTE: curl -Lo- https://goo.gl/j2y1Dn | bash | tee /tmp/install-prep.out
# -----------------------------------------------------------------------------
#     TODO: 1)
#           2)
#           3)
# -----------------------------------------------------------------------------
#   AUTHOR: todd-dsm
# -----------------------------------------------------------------------------
#  CREATED: 2017/01/27
# -----------------------------------------------------------------------------
set -x


###----------------------------------------------------------------------------
### VARIABLES
###----------------------------------------------------------------------------
# ENV Stuff
# Data Files


###----------------------------------------------------------------------------
### FUNCTIONS
###----------------------------------------------------------------------------


###----------------------------------------------------------------------------
### MAIN PROGRAM
###----------------------------------------------------------------------------
### Get the start time
###---
printf '\n%s\n' "Prepping the OS for mac-ops install..."
timePre="$(date +'%T')"


###---
### Update the OS
###---
printf '\n%s\n' "Updating macOS..."
softwareupdate -i -a

###---
### Install Xcode CLI Tools
###---
printf '\n%s\n' "Installing Xcode CLI Tools..."
install-xcode-cli-tools.sh

###---
### Save installed package and library details before the install
###---
printf '\n%s\n' "Saving some pre-install app/lib details..."
admin-app-details.sh pre


###----------------------------------------------------------------------------
### Announcements
###----------------------------------------------------------------------------
printf '\n\n%s\n' """
	You are now prepped for the mac-ops install process.
"""

###----------------------------------------------------------------------------
### Quick and Dirty duration
###----------------------------------------------------------------------------
timePost="$(date +'%T')"

### Convert time to a duration
startTime=$(date -u -d "$timePre" +"%s")
endTime=$(date -u -d "$timePost" +"%s")
procDur="$(date -u -d "0 $endTime sec - $startTime sec" +"%H:%M:%S")"
printf '%s\n' """
    Prep start  at: $timePre
    Prep end    at: $timePost
    Prep  duration: $procDur
"""


###---
### fin~
###---
exit 0
