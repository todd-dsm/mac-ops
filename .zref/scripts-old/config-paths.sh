#!/usr/bin/env bash
#  PURPOSE: Creates and Tests new $PATH and $MANPATH from
#           /etc/paths and
#           /etc/manpaths
# -----------------------------------------------------------------------------
#  PREREQS: a)
#           b)
#           c)
# -----------------------------------------------------------------------------
#  EXECUTE:
# -----------------------------------------------------------------------------
#     TODO: 1)
#           2)
#           3)
# -----------------------------------------------------------------------------
#   AUTHOR: Todd E Thomas
# -----------------------------------------------------------------------------
#  CREATED: 2016/09/00
# -----------------------------------------------------------------------------
set -eux


###----------------------------------------------------------------------------
### VARIABLES
###----------------------------------------------------------------------------
# ENV Stuff
sysPaths='/etc/paths'
sysManPaths='/etc/manpaths'
myPath=""
myMans=""
# Data Files


###----------------------------------------------------------------------------
### FUNCTIONS
###----------------------------------------------------------------------------


###----------------------------------------------------------------------------
### MAIN PROGRAM
###----------------------------------------------------------------------------
### Construct new paths
###---
printf '%s\n' "Constructing these lines into \$PATH..."
cat "$sysPaths"

printf '%s\n' "Constructing the \$PATH environment variable..."
while IFS= read -r binPath; do
    printf '%s\n' "  Adding: $binPath"
    if [[ -z "$myPath" ]]; then
       declare "myPath=$binPath"
   else
       declare myPath="$myPath:$binPath"
    fi
done < "$sysPaths"

export PATH="$myPath"


###---
### REQ
###---
printf '%s\n' "Constructing these lines into \$MANPATH..."
cat "$sysManPaths"

printf '%s\n' "Constructing the \$MANPATH environment variable..."
while IFS= read -r binPath; do
    printf '%s\n' "  Adding: $binPath"
    if [[ -z "$myMans" ]]; then
       declare "myMans=$binPath"
   else
       declare myMans="$myMans:$binPath"
    fi
done < "$sysManPaths"

export MANPATH="$myMans"


###---
### REQ
###---


###---
### REQ
###---


###---
### REQ
###---


###---
### REQ
###---


###---
### REQ
###---


###---
### REQ
###---


###---
### REQ
###---


###---
### REQ
###---


###---
### REQ
###---


###---
### fin~
###---
exit 0
