#!/usr/bin/env bash
# shellcheck disable=SC1071,SC1091,SC2154
#  PURPOSE: Get updates, Xcode CLI Tools, and some package details without pain.
#           For use with a new macOS install.
# -----------------------------------------------------------------------------
#  PREREQS: Script must be ran as Bash per Homebrew's requirements.
#           https://docs.brew.sh/Installation
# -----------------------------------------------------------------------------
#  EXECUTE: curl -fsSL https://goo.gl/j2y1Dn 2>&1 | zsh | tee /tmp/install-prep.out
# -----------------------------------------------------------------------------
#     TODO: 1) File Enhancement Request with Homebrew for ZSH install support.
#              https://github.com/Homebrew/homebrew-core/issues/95108
#           2)
#           3)
# -----------------------------------------------------------------------------
#   AUTHOR: todd-dsm
# -----------------------------------------------------------------------------
set -x


###----------------------------------------------------------------------------
### VARIABLES
###----------------------------------------------------------------------------
# ENV Stuff
theENV=TEST
stage='pre'
source my-vars.env > /dev/null 2>&1
#printf '\n%s\n' "Configuring this macOS for $myFullName."


###----------------------------------------------------------------------------
### FUNCTIONS
###----------------------------------------------------------------------------


###----------------------------------------------------------------------------
### MAIN PROGRAM
###----------------------------------------------------------------------------
printf '\n%s\n' "Prepping the OS for mac-ops configuration..."


####----------------------------------------------------------------------------
#### Update the OS
#### FIXME: https://github.com/todd-dsm/mac-ops/issues/63
####----------------------------------------------------------------------------
#printf '\n%s\n' "Updating macOS..."
#softwareupdate --all --install --force


####----------------------------------------------------------------------------
#### Install the Xcode CLI Tools
#### UPDATE: this will get installed as a dependency to Homebrew
#### FIXME: https://github.com/todd-dsm/mac-ops/issues/33
####----------------------------------------------------------------------------
#echo "Watch for on-screen prompts about sshd-keygen-wrapper: Accept"
#
#xcode-select --install
#
#sleep 10
#osascript <<EOD
#    tell application "System Events"
#      tell process "Install Command Line Developer Tools"
#        keystroke return
#        click button "Agree" of window "License Agreement"
#      end tell
#    end tell
#EOD


###----------------------------------------------------------------------------
### Set some foundational basics
###----------------------------------------------------------------------------
### Enable the script
###---
curl -Ls t.ly/ZXH8 | zsh


###----------------------------------------------------------------------------
### Install Homebrew
###----------------------------------------------------------------------------
printf '\n%s\n' "Installing Homebrew..."

if ! type -P brew > /dev/null 2>&1; then
    yes | CI=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
    printf '\n%s\n' "  Homebrew is already installed."
fi

printf '\n%s\n' "Running 'brew doctor'..."
brew doctor

###############################################################################
###                               BEGIN                                     ###
###############################################################################


###############################################################################
###                                  System                                 ###
###############################################################################
### Display some defaults for the log
###---
printf '\n%s\n' "Default macOS paths:"
printf '\n%s\n' "System Paths:"
cat "$sysPaths"
printf '\n%s\n' "\$PATH=$PATH"

printf '\n%s\n' "System man paths:"
cat "$sysManPaths"
if [[ -z "$MANPATH" ]]; then
    # at this stage it's always empty
    printf '\n%s\n' "The MANPATH Environmental Variable is empty!"
else
    printf '\n%s\n' "\$MANPATH=$MANPATH"
fi

### Backup paths/manpaths files
sudo cp /etc/*paths "$backupDir"



###----------------------------------------------------------------------------
### Configure the Shell: base options
###----------------------------------------------------------------------------
printf '\n%s\n' "Configuring base ZSH options..."
printf '\n%s\n' "Configuring $myShellProfile ..."
cat << EOF >> "$myShellProfile"
# URL: https://www.gnu.org/software/bash/manual/bashref.html#Bash-Startup-Files
#      With the advent of ZSH, this config seems unnecessary: RESEARCH
if [ -f ~/.zshrc ]; then
	. ~/.zshrc
fi

EOF

###----------------------------------------------------------------------------
### Let's Get Open: Install GNU Programs
###----------------------------------------------------------------------------
printf '\n%s\n' "Let's get open..."
set -x
paramsFile="${sourceDir}/gnu-programs.list"
gnuProgs=()

### install programs
brew install gnu-sed grep gawk bash findutils coreutils tree gnu-which \
    wget make automake gnu-tar gnu-time gzip gnupg diffutils gettext \
    gnu-indent

### Read list of programs from a file
while read -r gnuProgram; do
    # send name to gnuProgs array
    gnuProgs+=("$gnuProgram")
done < "$paramsFile"


###---
### Add paths for all elements in the gnuProgs array
###---
gnuSed='/usr/local/opt/gnu-sed/libexec/gnubin/sed'

printf '\n\n%s\n' "Adding paths for new GNU programs..."
for myProg in "${gnuProgs[@]}"; do
    gnuPath="$(brew --prefix "$myProg")"
    printf '%s\n' "  $gnuPath"
    sudo "$gnuSed" -i "\|/usr/local/bin|i $gnuPath/libexec/gnubin" "$sysPaths"
done


### Move system manpaths down 1 line
sudo "$gnuSed" -i -n '2{h;n;G};p' "$sysManPaths"

### Add manpaths for the GNU Manuals
printf '\n\n%s\n' "Adding manpaths for new GNU manuals..."
for myProg in "${gnuProgs[@]}"; do
    gnuPath="$(brew --prefix "$myProg")"
    printf '%s\n' "  $gnuPath"
    sudo "$gnuSed" -i "\|/usr/share/man|i $gnuPath/libexec/gnuman" "$sysManPaths"
done


###----------------------------------------------------------------------------
### PATHs
###   * System:  /usr/bin:/bin:/usr/sbin:/sbin
###   * Homebrew: anything under /usr/local
###----------------------------------------------------------------------------
printf '\n%s\n' "The new paths:"
printf '\n%s\n' "\$PATH:"
cat "$sysPaths"
printf '\n%s\n' "$PATH"


###----------------------------------------------------------------------------
### MANPATHs
###   * System:   /usr/share/man
###   * Homebrew: /usr/local/share/man
###----------------------------------------------------------------------------
printf '\n%s\n' "\$MANPATH: (available after next login)"
cat "$sysManPaths"


### Configure coreutils                                FIX LATER WITH ALIASES
printf '\n%s\n' "Configuring GNU Coreutils..."
cp sources/{aliases,functions}.zsh "$myShellDir"


###---
### RESET TEST ENVIRONMEN
###---
if [[ "$theENV" == 'TEST' ]]; then
    sudo cp "$backupDir/etc/paths"    /etc/paths
    sudo cp "$backupDir/etc/manpaths" /etc/manpaths
fi



###############################################################################
###                                END                                      ###
###############################################################################
set +x


###----------------------------------------------------------------------------
### Installing and Configuring Shells
###----------------------------------------------------------------------------
printf '\n%s\n' "Installing Bash, et al..."
brew install bash shellcheck dash bash-completion@2

###---
### Softlink sh to dash
###---
printf '\n%s\n' "Creating a softlink from sh to dash..."
ln -sf '/usr/local/bin/dash' '/usr/local/bin/sh'


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


printf '%s\n' "  Apps to a list..."
find /Applications -maxdepth 1 -type d -print | \
    sed 's|/Applications/||'    \
    > "$adminLogs/apps-find-all-$stage-install.log"


printf '%s\n' "  PAID Apps to a list..."
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
    Pulling the latest Oh My Zsh build...
"""
set -x
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
    sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi
set +x

####----------------------------------------------------------------------------
#### Preliminary ZSH Cleanup
####----------------------------------------------------------------------------
tools/zsh-shell-config.sh


###----------------------------------------------------------------------------
### Announcements
###----------------------------------------------------------------------------
printf '\n\n%s\n' """
    Configure the Shell with some sensible defaults
    tools/config-shell.sh

	You are now prepped for the mac-ops process.

    It's time to reboot!
    sudo shutdown -r now
"""


###---
### fin~
###---
exit 0
