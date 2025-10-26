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
#set -x

echo 'THIS HAS NEW/UNIX SED COMMANDS; WORTH A REVIEW'
exit

###----------------------------------------------------------------------------
### VARIABLES
###----------------------------------------------------------------------------
### ENV Stuff
: "${1:-LIVE}"
theENV="$1"
stage='pre'
source my-vars.env "$theENV" > /dev/null 2>&1
#ghAnsibleCFG="$rawGHContent/ansible/ansible/stable-2.9/examples/ansible.cfg"
#ghAnsibleHosts="$rawGHContent/ansible/ansible/stable-2.9/examples/hosts"
#pyVers='3.10'
paramsFile="${sourceDir}/gnu-programs.list"
gnuProgs=()
timeStart=$(date +%s)

sleep 5s

# The dirty bits
if [[ "$(uname -m)" == 'arm64' ]]; then
    # Apple Silicon
    brew_path='/opt/homebrew'
else
    # Intel
    brew_path='/usr/local'
fi


###----------------------------------------------------------------------------
### FUNCTIONS
###----------------------------------------------------------------------------
source lib/print-message-formatting.sh
# Load print functions: print_goal, print_req, print_pass, print_error
#source lib/printer.func


###----------------------------------------------------------------------------
### MAIN PROGRAM
###----------------------------------------------------------------------------
### The opening salvo
printReq "Prepping the OS for mac-ops configuration..."

if [[ "$myFullName" == 'fName lName' ]]; then
    printf '\n%s\n' "you didnt configure my-vars.env; do that first."
    exit 1
else
    printf '\n%s\n' "  Configuring this macOS for $myFullName."
fi


###----------------------------------------------------------------------------
### Set some foundational basics
###----------------------------------------------------------------------------
### Enable the script
###---
curl -Ls https://bit.ly/3I9ze7G | zsh


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
printReq "Updating macOS..."
#softwareupdate --all --install --force


###----------------------------------------------------------------------------
### Install Homebrew
###----------------------------------------------------------------------------
printReq "Installing Homebrew..."

#if ! type -P brew > /dev/null 2>&1; then
if [[ ! -x "${brew_path}/bin/brew" ]]; then
    yes | CI=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
    printf '\n%s\n' "  Homebrew is already installed."
fi

# make sure the robots can find Homebrew
PATH="$PATH:${brew_path}/bin"

# make sure the humans can always find homebrew
printf '\n%s\n' "  Injecting brew location into ~/.zprofile..."
cat > "$myShellProfile"  <<EOF
# homebrew location
eval "\$(/opt/homebrew/bin/brew shellenv)"
EOF

# Find brew and use it
if [[ ! -x "$(brew --prefix)/bin/brew" ]]; then
    printf '\n%s\n' "ERROR: Homebrew installation failed - brew binary not found"
    exit 1
else
    printf '\n%s\n' "  Homebrew installed successfully at: $(which brew)"
    eval "$(brew --prefix)/bin/brew shellenv" > /dev/null 2>&1
fi

printf '\n%s\n' "  Running 'brew doctor'..."
brew cleanup
brew doctor


# Create homebrew env config
printf '\n%s\n' "  Creating the homebrew.zsh env file..."
cat > "$shellConfig/homebrew.zsh"  <<EOF
##############################################################################
###                               HOMEBREW                                 ###
##############################################################################
export HOMEBREW_PREFIX='/opt/homebrew'
export HOMEBREW_CELLAR='/opt/homebrew/Cellar'
export HOMEBREW_REPOSITORY='/opt/homebrew'
eval "\$(/usr/bin/env PATH_HELPER_ROOT="/opt/homebrew" /usr/libexec/path_helper -s)"
[ -z "\${MANPATH-}" ] || export MANPATH=":\${MANPATH#:}";
export INFOPATH="/opt/homebrew/share/info:\${INFOPATH:-}"

EOF


###---------------------------------------------------------------------------
### System: pre-game
###----------------------------------------------------------------------------
### Display some defaults for the log
###---
printReq "Display default macOS paths:"

# Display current state for audit
printf '\n%s\n' "Current system paths:" && cat "$sysPaths"

printf '\n%s\n' "\$PATH=$PATH"

printf '\n%s\n' "Current system manpaths:" && cat "$sysManPaths"

if [[ -z "$MANPATH" ]]; then
    # at this stage it's always empty
    printf '\n%s\n' "The MANPATH Environmental Variable is empty!"
else
    printf '\n%s\n' "\$MANPATH=$MANPATH"
fi

### Backup paths/manpaths files
sudo cp /etc/*paths "$backupDir"


###----------------------------------------------------------------------------
### Let's Get Open: Install GNU Programs
###   * We'll use BSD sed to enable GNU programs
###----------------------------------------------------------------------------
printReq "Let's get open..."

### Read programs from list and add them to an array
while read -r gnuProgram; do
    gnuProgs+=("$gnuProgram")
done < "$paramsFile"

# Install GNU Programs
printf '\n%s\n' "Installing GNU programs..."
brew install "${gnuProgs[@]}"

# Configure paths and manpaths in single loop
printf '\n%s\n' "Configuring paths and manpaths..."
sudo sed -i '' '1{h;d;};2{G;};' "$sysManPaths"

# Add the paths
for prog in "${gnuProgs[@]}"; do
    gnuPath="$(brew --prefix "$prog")"
    printf '%s\n' "  Adding: $gnuPath"
    # BSD sed requires a hard return halfway through for some reason
    sudo sed -i '' "/\/usr\/local\/bin/i\\
$gnuPath/libexec/gnubin\\
" "$sysPaths"
    sudo sed -i '' "/\/usr\/local\/share\/man/i\\
$gnuPath/libexec/gnuman\\
" "$sysManPaths"
done
# Display final state for audit
printf '\n%s\n' "Configured system paths:" && cat "$sysPaths"
printf '\n%s\n' "Configured system manpaths:" && cat "$sysManPaths"


## Copy shell configurations
##printf '\n%s\n' "Configuring GNU shell extensions..."
##cp sources/{aliases,functions}.zsh "$myShellDir"


###----------------------------------------------------------------------------
### Installing and Configuring Shells
###----------------------------------------------------------------------------
printReq "Installing Dash, et al..."
brew install shellcheck dash bash-completion@2


###---
### Softlink sh to dash
###---
printf '\n%s\n' "Creating a softlink from sh to dash..."
sudo ln -sf "${brew_path}/bin/dash" '/usr/local/bin/sh'


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
printReq "Installing Ansible (and Python as a dependency)..."
brew install ansible


#printf '\n%s\n' "Configuring Ansible..."
#cat << EOF >> "$myZSHExt"
################################################################################
####                                 Ansible                                 ###
################################################################################
#export ANSIBLE_CONFIG="\$HOME/.ansible"
#
#EOF
#
#
#### Create a home for Ansible
#printf '\n%s\n' "Creating the Ansible directory..."
#mkdir -p "$myAnsibleDir/roles"
#
#
#### Pull the latest configs
#printf '\n%s\n' "Pulling the latest Ansible configs..."
#curl -o "$myAnsibleHosts" "$ghAnsibleHosts" > /dev/null 2>&1
#curl -o "$myAnsibleCFG"   "$ghAnsibleCFG"   > /dev/null 2>&1
#
#
#### Point Ansible to its config file
#"$gnuSed" -i '\|^#inventory.*hosts$| s|#inventory.*hosts$|inventory       = \$HOME/.ansible/hosts,/etc/ansible/hosts|g' "$myAnsibleCFG"
#"$gnuSed" -i '\|^#host_key_checking| s|#host_key_checking.*|host_key_checking = False|g' "$myAnsibleCFG"
#
#
####----------------------------------------------------------------------------
#### Configure Python
####----------------------------------------------------------------------------
#printf '\n%s\n' "Configuring the path..."
#pythonBin="$(brew info python@${pyVers} | grep '/usr/local/opt/python@.*python3$' | tr -d ' ')"
#pyPackages="$(brew info python@${pyVers} | grep site-packages$ | tr -d ' ')"
#
#sudo "$gnuSed" -i "\|/usr/local/bin|i ${pythonBin%/*}" "$sysPaths"
#sudo "$gnuSed" -i "\|/usr/local/bin|i $pyPackages"     "$sysPaths"
#
#PATH="${pythonBin%/*}:${pyPackages}:$PATH"
#
#printf '\n%s\n' "Display paths and Python version:"         # FIXME
#echo "$PATH"
#python3 --version
#sleep 3s
#
#printf '\n%s\n' "Upgrading Python Pip and setuptools..."
#python3 -m pip install --upgrade pip setuptools wheel
#python3 -m pip install --upgrade boto ipython simplejson requests boto Sphinx
#
#
#printf '\n%s\n' "Configuring Python..."
#cat << EOF >> "$myZSHExt"
################################################################################
####                                  Python                                 ###
################################################################################
#export PIP_CONFIG_FILE="\$HOME/.config/python/pip.conf"
## Setup autoenv to your tastes
##export AUTOENV_AUTH_FILE="\$HOME/.config/python/autoenv_authorized"
##export AUTOENV_ENV_FILENAME='.env'
##export AUTOENV_LOWER_FIRST=''
##source /usr/local/bin/activate.sh
#
#EOF
#
#
####---
#### Configure pip
####---
#printf '\n%s\n' "Configuring pip..."
#printf '\n%s\n' "  Creating pip home..."
#if [[ ! -d "$configDir/python" ]]; then
#    mkdir -p "$configDir/python"
#fi
#
#printf '\n%s\n' "  Creating the pip config file..."
#cat << EOF > "$configDir/python/pip.conf"
## pip configuration
#[list]
#format=columns
#
#EOF
#
#
####---
#### Configure autoenv
####---
#printf '\n%s\n' "Configuring autoenv..."
#
#
#printf '\n%s\n' "Creating the autoenv file..."
#touch "$configDir/python/autoenv_authorized"
#
#
#printf '\n%s\n' "Testing pip config..."
#pip3 list


printf '\n%s\n' "Ansible Version Info:"
ansible --version


###----------------------------------------------------------------------------
### Save installed package and library details before the install
### We will use the $XDG_CONFIG_HOME like a good POSIX system should.
### REF: https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html
###----------------------------------------------------------------------------
printReq "Saving some pre-install app/lib details..."


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


###----------------------------------------------------------------------------
### Announcements
###----------------------------------------------------------------------------
printf '\n\n%s\n' """

	You are now prepped for the mac-ops process.

    It's time to reboot!
    sudo shutdown -r now
"""

### Convert time to a duration

# At the end of your script
timeEnd=$(date +%s)
duration=$((timeEnd - timeStart))

# Convert to readable format
hours=$((duration / 3600))
minutes=$(((duration % 3600) / 60))
seconds=$((duration % 60))

printf '%s\n' """
    Process duration: ${hours}h ${minutes}m ${seconds}s
"""


### Save the install-prep log
printReq "The install log: $adminLogs/install-prep.log "
mv -f /tmp/install-prep.out "$adminLogs/install-prep.log"


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
