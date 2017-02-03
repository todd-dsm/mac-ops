#!/usr/bin/env bash
#  PURPOSE: Record app install details after the install.
# -----------------------------------------------------------------------------
#  PREREQS: none
# -----------------------------------------------------------------------------
#  EXECUTE: ./admin-app-details.sh post
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
# admin app install details
if [[ -z "$1" ]]; then
   declare stage='pre'
else
   declare stage="$1"
fi
declare adminDir="$HOME/.config/admin"
declare adminLogs="$adminDir/logs"


###----------------------------------------------------------------------------
### FUNCTIONS
###----------------------------------------------------------------------------


###----------------------------------------------------------------------------
### MAIN PROGRAM
###----------------------------------------------------------------------------
### Snapshot app install details
###----------------------------------------------------------------------------
printf '\n%s\n' "Snapshotting some $stage-install app/lib details..."

# Create the admin directory if it doesn't exist
if [[ ! -d "$adminDir" ]]; then
    printf '\n%s\n' "Creating a space for admin logs..."
    mkdir -p "$adminDir/"{logs,backup}
fi

# Save minimal application and library output
printf '\n%s\n' "Saving all..."
printf '%s\n' "  Apps to a list: pkgutil..."
pkgutil --pkgs > "$adminLogs/apps-pkgutil-$stage-install.log"


printf '%s\n' "  Apps to a list: GNU find..."
find /Applications -maxdepth 1 -type d -print | \
    sed 's|/Applications/||'    \
    > "$adminLogs/apps-find-all-$stage-install.log"


printf '%s\n' "  PAID Apps to a list: GNU find..."
find /Applications -maxdepth 4 -path '*Contents/_MASReceipt/receipt' -print | \
    sed 's|.app/Contents/_MASReceipt/receipt|.app|g; s|/Applications/||' \
    > "$adminLogs/apps-paid-$stage-install.log"


# if it's pre-install there will be no Homebrew
if [[ "$stage" == 'post' ]]; then
    # Collect Homebrew stats
    printf '%s\n' "  Homebrew programs to a list..."
    brew leaves > "$adminLogs/apps-homebrew-$stage-install.log"

    # Collect Homebrew Python stats
    printf '%s\n' "  Homebrewed python2 libraries to a list..."
    pip list > "$adminLogs/libs-pip-$stage-install.log"

    # Collect Homebrew Python3 stats
    printf '%s\n' "  Homebrewed python3 libraries to a list..."
    pip3 list > "$adminLogs/libs-pip3-$stage-install.log"
else
    printf '%s\n' """
      No Homebrew packages or Python libraries
      Homebrew is not installed yet.
    """
fi


printf '%s\n\n' "  \$HOME dot directories to a list..."
find "$HOME" -maxdepth 1 \( -type d -o -type l \) -name ".*" | \
    sed "s|^$HOME/||" > "$adminLogs/apps-home-dot-dirs-$stage-install.log"


###----------------------------------------------------------------------------
### Announcements
###----------------------------------------------------------------------------
printf '\n\n%s\n' """
	Details about installed programs have been recorded.
"""


###---
### fin~
###---
exit 0
