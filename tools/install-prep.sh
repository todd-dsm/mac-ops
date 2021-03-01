#!/usr/bin/env zsh
# shellcheck disable=SC1071
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
set -x
echo "$0 yo"

###----------------------------------------------------------------------------
### VARIABLES
###----------------------------------------------------------------------------
# ENV Stuff
configDir="${HOME}/.config"
myShellDir="${configDir}/shell"
myBashExt="${myShellDir}/mystuff.env"
myZSHExt="${myShellDir}/myzshstuff.env"
# Xcode CLI Tools
distPlcholder='/tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress'

# admin app install details
stage='pre'
adminDir="$HOME/.config/admin"
adminLogs="$adminDir/logs"


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
#softwareupdate --all --install --force
#
#
####----------------------------------------------------------------------------
#### Install the Xcode CLI Tools
####----------------------------------------------------------------------------
#### create the placeholder file that's checked by CLI updates' .dist code
####---
#touch "$distPlcholder"
#
####---
#### Find the CLI Tools update; resolves to:
#### 'Command Line Tools (macOS Sierra version 10.12) for Xcode-8.2'
####---
#cliTools="$(softwareupdate -l | grep "\*.*Command Line" | head -n 1 |   \
#    awk -F"*" '{print $2}' | sed -e 's/^ *//' | tr -d '\n')"
#
####---
#### Install the package
####---
#softwareupdate -i "$cliTools" --verbose
#
####---
#### Do some light cleaning
####---
#rm "$distPlcholder"
#
#
####----------------------------------------------------------------------------
#### Set some foundational basics
####----------------------------------------------------------------------------
#### Enable the script
####---
#curl -Ls https://goo.gl/C91diQ | bash
#
#
####----------------------------------------------------------------------------
#### Install Homebrew
####----------------------------------------------------------------------------
#printf '\n%s\n' "Installing Homebrew..."
#if ! type -P brew; then
#    yes | /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
#else
#    printf '\n%s\n' "Homebrew is already installed."
#fi
#
#printf '\n%s\n' "Running 'brew doctor'..."
#brew doctor


###----------------------------------------------------------------------------
### Installing and Configuring Shells
###----------------------------------------------------------------------------
printf '\n%s\n' "Installing Bash, et al..."
brew install bash shellcheck dash bash-completion@2

# Fix zsh compinit: insecure directories message
autoload -Uz compaudit
compaudit | xargs chmod g-w

# Rebuilding 'zcompdump' wont hurt
if [[ -f ~/.zcompdump ]]; then
    rm -f ~/.zcompdump
    compinit
fi


# Configure GNU Bash for the system and current $USER
printf '\n%s\n' "Configuring Bash..."

if [[ ! -f "$myShellDir" ]]; then
    mkdir -p "$myShellDir"
    touch "$myBashExt"
    touch "$myZSHExt"
fi

printf '\n%s\n' "Creating a softlink from sh to dash..."
ln -sf '/usr/local/bin/dash' '/usr/local/bin/sh'

#printHead "System Shells default:"
#grep '^\/' "$sysShells"
#sudo sed -i "\|^.*bash$|i /usr/local/bin/bash" "$sysShells"
#sudo sed -i "\|local|a /usr/local/bin/sh" "$sysShells"
#printHead "System Shells new:"
#grep '^\/' "$sysShells"

# Switch to GNU Bash
#currentShell="$(dscl . -read "$HOME" UserShell)"

#if [[ "${currentShell##*\ }" != "$(type -P bash)" ]]; then
#    printHead "$USER's shell is: ${currentShell##*\ }"
#    printHead "Changing default shell to GNU Bash"
#    sudo chpass -s "$(type -P bash)" "$USER"
#    dscl . -read "$HOME" UserShell
#else
#    printHead "Default shell is already GNU Bash"
#fi

cat << EOF >> "$myZSHExt"
###############################################################################
###                                   ZSH                                   ###
###############################################################################

EOF

cat << EOF >> "$myBashExt"
###############################################################################
###                                   Bash                                  ###
###############################################################################
# ShellCheck: Ignore: https://goo.gl/n9W5ly
export SHELLCHECK_OPTS="-e SC2155"

EOF

# Source-in and Display changes
#printInfo "bash ~/.bashrc changes:"
#source "$myShellProfile" > /dev/null 2>&1 && tail -8 "$myShellrc"



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

    It might be a good idea to reboot.
"""


###---
### fin~
###---
exit 0
