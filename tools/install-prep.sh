#!/usr/bin/env bash
#  PURPOSE: Get updates, Xcode CLI Tools, and some package details without pain.
#           For use with a new macOS install.
# -----------------------------------------------------------------------------
#  PREREQS: none
# -----------------------------------------------------------------------------
#  EXECUTE: curl -fsSL https://goo.gl/j2y1Dn 2>&1 | bash | tee /tmp/install-prep.out
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
# Xcode CLI Tools
distPlcholder='/tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress'

# admin app install details
stage="pre"
declare adminDir="$HOME/.config/admin"
declare adminLogs="$adminDir/logs"


###----------------------------------------------------------------------------
### FUNCTIONS
###----------------------------------------------------------------------------


###----------------------------------------------------------------------------
### MAIN PROGRAM
###----------------------------------------------------------------------------
### Get the start time
###---
printf '\n%s\n' "Prepping the OS for mac-ops configuration..."


###----------------------------------------------------------------------------
### Update the OS
###----------------------------------------------------------------------------
printf '\n%s\n' "Updating macOS..."
softwareupdate -i -a



###----------------------------------------------------------------------------
### Install the Xcode CLI Tools
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


###----------------------------------------------------------------------------
### Save installed package and library details before the install
###----------------------------------------------------------------------------
printf '\n%s\n' "Saving some pre-install app/lib details..."

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
    printf '%s\n' "  Python libraries (Homebrew) to a list..."
    pip list > "$adminLogs/libs-pip-python-$stage-install.log"
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
	You are now prepped for the mac-ops process.
"""


###---
### fin~
###---
exit 0
