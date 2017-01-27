#!/usr/bin/env bash
# PURPOSE: Save lists of installed programs and libraries.
#    EXEC: ./record-app-details.sh $backupDeviceName $backupDir
# EXEC EG: ./record-app-details.sh mVault pre_sierra
#set -ux

declare backupDrive="$1"
declare backupDir="$2"
declare backupDir="/Volumes/$backupDrive/$backupDir/progs"

printf '\n%s\n' "Saving all..."
printf '%s\n' "  Apps to a list: pkgutil..."
pkgutil --pkgs > "$backupDir/apps-pkgutil.txt"


printf '%s\n' "  Apps to a list: GNU find..."
find /Applications -maxdepth 1 -type d -print | \
    sed 's|/Applications/||'    \
    > "$backupDir/apps-find-all.txt"


printf '%s\n' "  PAID Apps to a list: GNU find..."
find /Applications -maxdepth 4 -path '*Contents/_MASReceipt/receipt' -print | \
    sed 's|.app/Contents/_MASReceipt/receipt|.app|g; s|/Applications/||' \
    > "$backupDir/apps-paid.txt"


printf '%s\n' "  Homebrew programs to a list..."
brew leaves > "$backupDir/apps-homebrew.txt"


printf '%s\n' "  Python libraries (Homebrew) to a list..."
pip list > "$backupDir/libs-pip-python.txt"


printf '%s\n\n' "  \$HOME dot directories to a list..."
find "$HOME" -maxdepth 1 \( -type d -o -type l \) -name ".*" | \
    sed "s|^$HOME/||" > "$backupDir/apps-home-dot-dirs.txt"
