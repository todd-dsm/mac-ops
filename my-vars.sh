#!/usr/bin/env bash
# -----------------------------------------------------------------------------
# User-specific variables required before running the automation.
# WARNING: YOU MUST SET THESE VARIABLES FIRST. DO NOT RUN bootstrap.sh WITHOUT
#          HAVING CONFIGURED THESE PARAMETERS.
# -----------------------------------------------------------------------------

# Are we testing or are we really doing this?
export theENV='TEST'

# What would you like to call your computer?
#   If there isn't one just delete computer?
export myMBPName='tbook'

# Do you have an internal domain?
#   If there isn't one just delete the value between the quotes.
export myDomain='ptest'

# What's the TLD for the internal domain?
#   If there isn't one just delete the value between the quotes.
export myTLD='us'

# Altogether
export myDomaiName="$myDomain.$myTLD"

# Set the Domain Name and TLD to .local if there is nothing else
if [[ -z "$myDomaiName" ]]; then
    export myDomaiName='.local'
fi

# Call it 'macos' if we're testing - whatever you want if we're live.
if [[ "$theENV" == 'TEST' ]]; then
    export myHostName="macos.$myDomaiName"
else
    export myHostName="$myMBPName.$myDomaiName"
fi

# Define a path to your backup device. It's just a path. It can point to an NFS
# share, a USB drive, whatever.
export myBackupDev='/Volumes/mVault'

# Define a path to your latest backups
if [[ "$theENV" == 'TEST' ]]; then
    export myBackupDir='test'
else
    export myBackupDir='pre_sierra'
fi


# Define the last "$USER" backed up. 2 options:
# 1) If your user-name is the same as it was on the last install, skip this
#    step. The automation will take care of everything else.
# 2) If your user-name has changed since the last install then define what it
#    was. We simply need to get stuff from the backup location.
if [[ "$theENV" == 'TEST' ]]; then
    export lastUser="$USER"
else
    export lastUser="thomas"    # replace with your current user name
fi

# Define Restore SRC (source of the backups)
export myBackups="$myBackupDev/$myBackupDir/$lastUser/current"

# -----------------------------------------------------------------------------
# Define some personal truths *if they are different*. This stuff doesn't
# change much though.
# -----------------------------------------------------------------------------

# Where do you keep your code/projects?
export myCode="$HOME/code"

# Where do you store your virtual machines?
export myVMs="$HOME/vms"

# Define where the ssh keys go
export mySSHDir="$HOME/.ssh"

# Desktop
export myDesktop="$HOME/Desktop"

# Documents
export myDocs="$HOME/Documents"

# Movies
export myMovies="$HOME/Movies"

# Music
export myMusic="$HOME/Music"

# Pictures
export myPics="$HOME/Pictures"

# Downloads
export myDownloads="$HOME/Downloads"

# Define
export myParam='myVal'

