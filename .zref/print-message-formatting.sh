#!/usr/bin/env bash
#  PURPOSE: Common formattig for all printed messages. Intended to be sourced-in
#           at runtime.
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
#  CREATED: 2022/03/07
# -----------------------------------------------------------------------------
#set -x


###----------------------------------------------------------------------------
### VARIABLES
###----------------------------------------------------------------------------
# ENV Stuff
#: "${1?  Wheres my first agument, bro!}"

# Data


###----------------------------------------------------------------------------
### FUNCTIONS
###----------------------------------------------------------------------------
function pMsg() {
    theMessage="$1"
    printf '%s\n' "$theMessage"
}


###----------------------------------------------------------------------------
### MAIN PROGRAM
###----------------------------------------------------------------------------
### Print stuff of greatest importance: Requirements
####---
printReq() {
    theReq="$1"
    printf '\e[1;34m%-6s\e[m' """
$theReq
"""
}

####---
### Print stuff of secondary importance: Headlines
####---
printHead() {
    theHead="$1"
    printf '%s' """
  $theHead
"""
}

####---
### Print stuff of tertiary importance: Informational
####---
printInfo() {
    theInfo="$1"
    printf '%s\n' """
    $theInfo
"""
}


###---
### Test print functions in the script
###---
#printReq  "Requirement"
#printHead "Headline"
#printInfo "Info"


###---
### REQ
###---


###---
### REQ
###---


###---
### fin~ libs CANNOT exit
###---
