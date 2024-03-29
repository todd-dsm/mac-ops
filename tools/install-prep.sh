#!/usr/bin/env bash
# shellcheck disable=SC1071,SC1091,SC2154,SC2016
#  PURPOSE: Get updates, Xcode CLI Tools, and some package details without pain.
#           For use with a new macOS install.
#           ONLY TAKES ONE ARG=TEST; wil run with no args.
# -----------------------------------------------------------------------------
#  PREREQS: Script must be ran as Bash per Homebrew's requirements.
#           https://docs.brew.sh/Installation
# -----------------------------------------------------------------------------
#  EXECUTE: curl -fsSL https://goo.gl/j2y1Dn 2>&1 | zsh | tee /tmp/install-prep.out
# -----------------------------------------------------------------------------
#     TODO: 1)
#           2)
#           3)
# -----------------------------------------------------------------------------
#   AUTHOR: todd-dsm
# -----------------------------------------------------------------------------
set -x


###----------------------------------------------------------------------------
### VARIABLES
###----------------------------------------------------------------------------
### ENV Stuff
: "${1:-LIVE}"
theENV="$1"
stage='pre'
source my-vars.env "$theENV" > /dev/null 2>&1
set -x
ghAnsibleCFG="$rawGHContent/ansible/ansible/stable-2.9/examples/ansible.cfg"
ghAnsibleHosts="$rawGHContent/ansible/ansible/stable-2.9/examples/hosts"
pyVers='3.10'
paramsFile="${sourceDir}/gnu-programs.list"
gnuProgs=()
timePre="$(date +'%T')"


###----------------------------------------------------------------------------
### FUNCTIONS
###----------------------------------------------------------------------------
source lib/print-message-formatting.sh


###----------------------------------------------------------------------------
### MAIN PROGRAM
###----------------------------------------------------------------------------
### The opening salvo
printf '\n%s\n' "Prepping the OS for mac-ops configuration..."

if [[ "$myFullName" == 'fName lName' ]]; then
    printf '\n%s\n' "you didnt configure my-vars.env; do that first."
    exit 1
else
    printf '\n%s\n' "  Configuring this macOS for $myFullName."
fi

set -x

###----------------------------------------------------------------------------
### Set some foundational basics
###----------------------------------------------------------------------------
### Enable the script
###---
curl -Ls t.ly/ZXH8 | zsh


### Create the admin directory if it doesn't exist
### We'll be using the XDG Base Directory Spec
### https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html
if [[ ! -d "$adminDir" ]]; then
    printf '\n%s\n' "Creating a space for admin logs..."
    mkdir -p "${adminDir}/"{logs,backup}
    mkdir -p "${myShellDir}"
fi


###---
### Update the OS
###---
printf '\n%s\n' "Updating macOS..."
softwareupdate --all --install --force


###----------------------------------------------------------------------------
### Install Homebrew
###----------------------------------------------------------------------------
printf '\n%s\n' "Installing Homebrew..."

if ! type -P brew > /dev/null 2>&1; then
    yes | CI=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
    printf '\n%s\n' "  Homebrew is already installed."
fi

printf '\n%s\n' "  Running 'brew doctor'..."
brew cleanup
brew doctor


printf '\n%s\n' "  Injecting brew location into ~/.zprofile..."
cat >> "$myShellProfile"  <<EOF
# Make sure we can always find homebrew
eval "\$(/opt/homebrew/bin/brew shellenv)"
EOF


# Initialize a new shell and pull in ENV VARS
zsh
source my-vars.env
which brew


###----------------------------------------------------------------------------
### System: pre-game
###----------------------------------------------------------------------------
### Display some defaults for the log
###---
printf '\n%s\n' "Default macOS paths:"
printf '\n%s\n' "  System Paths:"
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
#printf '\n%s\n' "Configuring base ZSH options..."
#printf '\n%s\n' "Configuring $myShellProfile ..."
#
#if [[ -e "$myShellProfile" ]]; then
#    cp "$myShellProfile" "$backupDir"
#fi
#
#cat << EOF >> "$myShellProfile"
## URL: https://www.gnu.org/software/bash/manual/bashref.html#Bash-Startup-Files
##      With the advent of ZSH, this config seems unnecessary: RESEARCH
#if [ -f ~/.zshrc ]; then
#	. ~/.zshrc
#fi
#
#EOF


###----------------------------------------------------------------------------
### Let's Get Open: Install GNU Programs
###----------------------------------------------------------------------------
printf '\n%s\n' "Let's get open..."

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
### Configure PATHs
###---
printf '\n\n%s\n' "Adding paths for new GNU programs..."

### Add paths for all elements in the gnuProgs array
for myProg in "${gnuProgs[@]}"; do
    gnuPath="$(brew --prefix "$myProg")"
    printf '%s\n' "  $gnuPath"
    sudo "$gnuSed" -i "\|/usr/local/bin|i $gnuPath/libexec/gnubin" "$sysPaths"
done


###---
### Configure MANPATHs
###---

### Move system manpaths down 1 line
sudo "$gnuSed" -i -n '2{h;n;G};p' "$sysManPaths"

### Add manpaths for the GNU Manuals
printf '\n\n%s\n' "Adding manpaths for new GNU manuals..."
for myProg in "${gnuProgs[@]}"; do
    gnuPath="$(brew --prefix "$myProg")"
    printf '%s\n' "  $gnuPath"
    sudo "$gnuSed" -i "\|/usr/share/man|i $gnuPath/libexec/gnuman" "$sysManPaths"
done


###---
### Display results for logging
###---
printf '\n%s\n' "The new paths: (available after opening a new Terminal window)"
cat "$sysPaths"


###---
### MANPATHs
###   * System:   /usr/share/man
###   * Homebrew: /usr/local/share/man
###---
printf '\n%s\n' "The new manpaths: (available after opening a new Terminal window)"
cat "$sysManPaths"


### Copy personal configs to $myShellDir
printf '\n%s\n' "Configuring GNU Coreutils..."
cp sources/{aliases,functions}.zsh "$myShellDir"


###----------------------------------------------------------------------------
### Installing and Configuring Shells
###----------------------------------------------------------------------------
printf '\n%s\n' "Installing Dash, et al..."
brew install shellcheck dash bash-completion@2


###---
### Softlink sh to dash
###---
printf '\n%s\n' "Creating a softlink from sh to dash..."
ln -sf '/usr/local/bin/dash' '/usr/local/bin/sh'


###----------------------------------------------------------------------------
### Install the latest git
###----------------------------------------------------------------------------
printReq "Installing Git..."
brew install git

printReq "Configuring Git..."
cat << EOF >> "$myGitConfig"
##############################################################################
##                                  GIT                                    ###
##############################################################################
[user]
	name = $myFullName
	email = $myEmailAdd
[core]
	editor = vim
	pager = cat
	excludesfile = ~/.gitignore
[color]
	ui = true
[push]
	default = matching
[alias]
	rlog = log --reverse
[pull]
	rebase = false
EOF


### ignore some things universally
cat << EOF >> "$myGitIgnore"
# macOS Stuff
.DS_Store
# Ignore IDE Garbage
**/.idea/*
**/.vscode/*

EOF


###----------------------------------------------------------------------------
### Install/Configure Ansible
###----------------------------------------------------------------------------
printf '\n%s\n' "Installing Ansible (and Python as a dependency)..."
brew install ansible


printf '\n%s\n' "Configuring Ansible..."
cat << EOF >> "$myZSHExt"
###############################################################################
###                                 Ansible                                 ###
###############################################################################
export ANSIBLE_CONFIG="\$HOME/.ansible"

EOF


### Create a home for Ansible
printf '\n%s\n' "Creating the Ansible directory..."
mkdir -p "$myAnsibleDir/roles"


### Pull the latest configs
printf '\n%s\n' "Pulling the latest Ansible configs..."
curl -o "$myAnsibleHosts" "$ghAnsibleHosts" > /dev/null 2>&1
curl -o "$myAnsibleCFG"   "$ghAnsibleCFG"   > /dev/null 2>&1


### Point Ansible to its config file
"$gnuSed" -i '\|^#inventory.*hosts$| s|#inventory.*hosts$|inventory       = \$HOME/.ansible/hosts,/etc/ansible/hosts|g' "$myAnsibleCFG"
"$gnuSed" -i '\|^#host_key_checking| s|#host_key_checking.*|host_key_checking = False|g' "$myAnsibleCFG"


###----------------------------------------------------------------------------
### Configure Python
###----------------------------------------------------------------------------
printf '\n%s\n' "Configuring the path..."
pythonBin="$(brew info python@${pyVers} | grep '/usr/local/opt/python@.*python3$' | tr -d ' ')"
pyPackages="$(brew info python@${pyVers} | grep site-packages$ | tr -d ' ')"

sudo "$gnuSed" -i "\|/usr/local/bin|i ${pythonBin%/*}" "$sysPaths"
sudo "$gnuSed" -i "\|/usr/local/bin|i $pyPackages"     "$sysPaths"

PATH="${pythonBin%/*}:${pyPackages}:$PATH"

printf '\n%s\n' "Display paths and Python version:"         # FIXME
echo "$PATH"
python3 --version
sleep 3s

printf '\n%s\n' "Upgrading Python Pip and setuptools..."
python3 -m pip install --upgrade pip setuptools wheel
python3 -m pip install --upgrade boto ipython simplejson requests boto Sphinx


printf '\n%s\n' "Configuring Python..."
cat << EOF >> "$myZSHExt"
###############################################################################
###                                  Python                                 ###
###############################################################################
export PIP_CONFIG_FILE="\$HOME/.config/python/pip.conf"
# Setup autoenv to your tastes
#export AUTOENV_AUTH_FILE="\$HOME/.config/python/autoenv_authorized"
#export AUTOENV_ENV_FILENAME='.env'
#export AUTOENV_LOWER_FIRST=''
#source /usr/local/bin/activate.sh

EOF


###---
### Configure pip
###---
printf '\n%s\n' "Configuring pip..."
printf '\n%s\n' "  Creating pip home..."
if [[ ! -d "$configDir/python" ]]; then
    mkdir -p "$configDir/python"
fi

printf '\n%s\n' "  Creating the pip config file..."
cat << EOF > "$configDir/python/pip.conf"
# pip configuration
[list]
format=columns

EOF


###---
### Configure autoenv
###---
printf '\n%s\n' "Configuring autoenv..."


printf '\n%s\n' "Creating the autoenv file..."
touch "$configDir/python/autoenv_authorized"


printf '\n%s\n' "Testing pip config..."
pip3 list


printf '\n%s\n' "Ansible Version Info:"
ansible --version


###----------------------------------------------------------------------------
### Save installed package and library details before the install
### We will use the $XDG_CONFIG_HOME like a good POSIX system should.
### REF: https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html
###----------------------------------------------------------------------------
printf '\n%s\n' "Saving some pre-install app/lib details..."


### Save list of all OS-related apps
printf '%s\n' "  Apps to a list..."
find /Applications -maxdepth 1 -type d -print | \
    sed 's|/Applications/||'    \
    > "$adminLogs/apps-find-all-$stage-install.log"


### Save log of all dotDirectories in your HOME directory
printf '%s\n\n' "  \$HOME dot directories to a list..."
find "$HOME" -maxdepth 1 \( -type d -o -type l \) -name ".*" | \
    sed "s|^$HOME/||" > "$adminLogs/apps-home-dot-dirs-$stage-install.log"


### Save log of all Homebrew-installed programs
printf '%s\n' "  Homebrew programs to a list..."
brew leaves > "$adminLogs/apps-homebrew-$stage-install.log"


### Save log of all OS-related apps
printf '%s\n' "  PAID Apps to a list..."
find /Applications -maxdepth 4 -path '*Contents/_MASReceipt/receipt' -print | \
    sed 's|.app/Contents/_MASReceipt/receipt|.app|g; s|/Applications/||' \
    > "$adminLogs/apps-paid-$stage-install.log"


### Save minimal application and library output
printf '\n%s\n' "Saving all..."
printf '%s\n' "  Apps to a list: pkgutil..."
pkgutil --pkgs > "$adminLogs/apps-pkgutil-$stage-install.log"


### Save log of all Python-related libs
printf '%s\n' "  Python libraries (Homebrew) to a list..."
pip3 list > "$adminLogs/libs-pip-python-$stage-install.log"


###----------------------------------------------------------------------------
### Install Oh My Zsh!
### REF: https://ohmyz.sh/ | GitHub: https://github.com/ohmyzsh/ohmyzsh
###----------------------------------------------------------------------------
printf '\n\n%s\n' """
    Pulling the latest Oh My Zsh build...
"""
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
    sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    tools/config-shell.sh
    cp "${myShellDir}"/*.zsh "$myShellEnv"
else
    printf '\n%s\n' "Oh My ZSH is already installed."
fi


### add advanced configuration
cp sources/zshrc-custom "$myShellrc"
"$gnuSed" -i "s/temp-user/$USER/g" "$myShellrc"


### save differences to the log for posterity
diff ~/.zshrc sources/zshrc-custom


###----------------------------------------------------------------------------
### Announcements
###----------------------------------------------------------------------------
set +x
printf '\n\n%s\n' """

	You are now prepped for the mac-ops process.

    It's time to reboot!
    sudo shutdown -r now
"""

### Convert time to a duration
startTime=$("$gnuDate" -u -d "$timePre"  +"%s")
  endTime=$("$gnuDate" -u -d "$timePost" +"%s")
procDur="$("$gnuDate" -u -d "0 $endTime sec - $startTime sec" +"%H:%M:%S")"
printf '%s\n' """
    Process start at: $timePre
    Process end   at: $timePost
    Process duration: $procDur
"""


### Save the install-prep log
mv -f /tmp/install-prep.out "$adminLogs/install-prep.log"

### Create a link to the log file
ln -s "$adminLogs/install-prep.log" install-prep.log


###----------------------------------------------------------------------------
### RESET TEST ENVIRONMENT
###----------------------------------------------------------------------------
#if [[ "$theENV" == 'TEST' ]]; then
#    sudo cp "$backupDir/paths"    /etc/paths
#    sudo cp "$backupDir/manpaths" /etc/manpaths
#fi



###---
### fin~
###---
exit 0
