#!/usr/bin/env bash
# PURPOSE:  Save lists of installed programs and libraries before the install
#           and configuration of the system. This is a baseline.
#    EXEC: ./admin-app-details-$stage-install.sh $backupDeviceName $adminDir
# EXEC EG: ./admin-app-details-$stage-install.sh mVault pre_sierra
#set -ux

# At which stage? Values: 'pre', 'post'
stage="$1"
declare adminDir="$HOME/.config/admin"
declare adminLogs="$adminDir/logs"


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
