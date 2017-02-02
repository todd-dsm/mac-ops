#!/usr/bin/env bash
# shellcheck disable=SC2154
#  PURPOSE: Restore data from 'current' backups.
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
#  CREATED: 2017/01/27
# -----------------------------------------------------------------------------
#set -eux


###----------------------------------------------------------------------------
### VARIABLES
###----------------------------------------------------------------------------
# ENV Stuff
declare homeStuff=("$myVMs")
declare myData=("$myCode" "$myDesktop" "$myDocs" "$myMovies" "$myMusic"     \
    "$myPics")


###----------------------------------------------------------------------------
### FUNCTIONS
###----------------------------------------------------------------------------


###----------------------------------------------------------------------------
### MAIN PROGRAM
###----------------------------------------------------------------------------
### Restore personal data FROM backups/current TO their respective destinations
###---
printf '\n\n%s\n' "Restoring code, docs, movies, music, etc..."
for dataDir in "${myData[@]}"; do
    printf '\n\n%s\n' "  Restoring $dataDir"
    rsync -aEv "$myBackups/${dataDir##*/}/" "$dataDir/"
done


###---
### Restore data FROM backups/current TO $HOME
###---
printf '\n\n%s\n' "Restoring stuff to \$HOME: vms, etc..."
for dataDir in "${homeStuff[@]}"; do
    printf '\n\n%s\n' "  Restoring $dataDir"
    rsync -aEv "$myBackups/${dataDir##*/}" "$HOME/"
done


###---
### Save a list of unowned files
###---
printf '\n\n%s\n' """
    Generating a list of files that are not owned by you; typically:
        \$USER : $USER : $(id -u)
        GROUP : $(id -gn)   : $(id -g)
    But sometimes people diddle with these things; mileage may vary.
    """
sudo find "$HOME" -name 'backup' -prune , -type f   \
   ! -user "$USER" ! -group staff  \
   -exec ls -l {} \; \( -fprintf /tmp/find-out.log '%#M  %u  %g  %p\n' \)


###---
### REQ
###---


###---
### fin~
###---
exit 0
