#!/usr/bin/env bash
#  PURPOSE: This script installs Xcode Command Line Tools. It's based on the
#           fine work of Timothy Sutton: https://github.com/timsutton.
#           \shellcheck\ is terribly offended; I'm just tuning it up a bit.
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
# MODIFIED: 2017/01/25
# -----------------------------------------------------------------------------
set -x


###----------------------------------------------------------------------------
### VARIABLES
###----------------------------------------------------------------------------
# ENV Stuff
# Data Files
distPlcholder='/tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress'


###----------------------------------------------------------------------------
### FUNCTIONS
###----------------------------------------------------------------------------


###----------------------------------------------------------------------------
### MAIN PROGRAM
###----------------------------------------------------------------------------
### create the placeholder file that's checked by CLI updates' .dist code
###---
touch "$distPlcholder"


###---
### Find the CLI Tools update; resolves to:
### 'Command Line Tools (macOS Sierra version 10.12) for Xcode-8.2'
###---
cliTools="$(softwareupdate -l | grep "\*.*Command Line" | head -n 1 |   \
    awk -F"*" '{print $2}' | sed -e 's/^ *//' | tr -d '\n')"


###---
### Install the package
###---
softwareupdate -i "$cliTools" --verbose


###---
### Do some light cleaning
###---
rm "$distPlcholder"


###---
### fin~
###---
exit 0
