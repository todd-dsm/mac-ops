#!/usr/bin/env bash
# shellcheck disable=SC1091,SC2016,SC2154,SC2317
#  PURPOSE: Get updates, Xcode CLI Tools, and some package details without pain.
#           For use with a new macOS install.
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
#set -x


###----------------------------------------------------------------------------
### VARIABLES
###----------------------------------------------------------------------------
### ENV Stuff
stage='pre'
source my-vars.env > /dev/null 2>&1
source lib/printer.func > /dev/null 2>&1

#ghAnsibleCFG="$rawGHContent/ansible/ansible/stable-2.9/examples/ansible.cfg"
ghAnsibleHosts="$rawGHContent/ansible/ansible/stable-2.9/examples/hosts"
paramsFile="${sourceDir}/gnu-programs.list"
gnuProgs=()
timePre="$(date +'%s')"


###----------------------------------------------------------------------------
### FUNCTIONS
###----------------------------------------------------------------------------
source lib/print-message-formatting.sh


###----------------------------------------------------------------------------
### MAIN PROGRAM
###----------------------------------------------------------------------------
### The opening salvo
print_goal "Prepping the OS for mac-ops configuration!"

if [[ "$myFullName" == 'fName lName' ]]; then
    print_error "you didnt configure my-vars.env; do that first."
else
    print_req "  Configuring macOS for $myFullName."
fi


###----------------------------------------------------------------------------
### Set some foundational basics
###----------------------------------------------------------------------------
### Enable the script
###---
print_req "Enter your password to enable the script:"
curl -Ls https://bit.ly/3I9ze7G | zsh


### Create the admin directory if it doesn't exist
### We'll be using the XDG Base Directory Spec
### https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html
print_goal "Creating an XDG Base Directory structure..."
if [[ ! -d "$adminDir" ]]; then
    print_req "Creating a space for admin logs..."
    mkdir -p "${adminDir}/"{logs,backup}
    mkdir -p "${myShellDir}"
fi


###---
### Update the OS
###---
print_goal "Updating macOS..."
#softwareupdate --all --install --force


###----------------------------------------------------------------------------
### Install Homebrew
###----------------------------------------------------------------------------
print_goal "Installing Homebrew..."
if [[ ! -x /opt/homebrew/bin/brew ]]; then
    yes | CI=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
    print_req "Homebrew is already installed."
fi


### Configure the Shell: base options
print_req "Injecting brew location into ~/.zprofile..."
cat >> "$myShellProfile"  <<EOF
# so we can always find homebrew
eval "\$(/opt/homebrew/bin/brew shellenv)"
EOF

### Initialize a new shell and pull in ENV VARS
eval "$(/opt/homebrew/bin/brew shellenv)"

print_req "Running 'brew doctor'..."
brew cleanup
brew doctor


###----------------------------------------------------------------------------
### Install rsync to enable quick backups
###----------------------------------------------------------------------------
print_goal "Installing rsync for backups..."
brew install rsync tree


### Backup /etc before we begin
print_req "Backing up the /etc directory before we begin..."
sudo rsync -aE /private/etc "$backup_dir/" 2> /tmp/rsync-err-etc.out


### Display user config directory
print_req "All install/config details will be recorded here:"
tree -d -L 3 "$configDir"


###----------------------------------------------------------------------------
### System: pre-game
###----------------------------------------------------------------------------
### Display some defaults for the log
###---
print_goal "Preparing for system modification..."
print_req "Default macOS paths:"
print_req "  System Paths:"
cat "$sysPaths"
print_req "\$PATH=$PATH"

print_req "System man paths:"
cat "$sysManPaths"
if [[ -z "$MANPATH" ]]; then
    # at this stage it's always empty
    print_req "The MANPATH Environmental Variable is empty!"
else
    print_req "\$MANPATH=$MANPATH"
fi


###----------------------------------------------------------------------------
### Let's Get Open: Install GNU Programs
###----------------------------------------------------------------------------
print_goal "Installing GNU tools..."

### install programs
print_req "Let's get open!"
brew install gnu-sed grep gawk bash findutils coreutils tree gnu-which \
    wget make automake gnu-tar gnu-time gzip gnupg diffutils gettext \
    gnu-indent


### Read list of programs from a file
while read -r gnuProgram; do
    # send name to gnuProgs array
    gnuProgs+=("$gnuProgram")
done < "$paramsFile"


### Configure PATHs
print_req "Adding paths for new GNU programs..."

### Add paths for all elements in the gnuProgs array
for myProg in "${gnuProgs[@]}"; do
    gnuPath="$(brew --prefix "$myProg")"
    print_info "$myProg"
    sudo sed -i '' "/\/usr\/local\/bin/i\\
$gnuPath/libexec/gnubin
" "$sysPaths"
done


### Configure MANPATHs
### Add manpaths for the GNU Manuals
print_req "Adding manpaths for new GNU manuals..."
for myProg in "${gnuProgs[@]}"; do
    gnuPath="$(brew --prefix "$myProg")"
    print_info "$myProg"
    sudo sed -i '' "/\/usr\/share\/man/i\\
$gnuPath/libexec/gnuman
" "$sysManPaths"
done


### Display results for logging
print_req "The new paths: (available after opening a new Terminal window)"
cat "$sysPaths"


print_req "The new manpaths: (available after opening a new Terminal window)"
cat "$sysManPaths"


###----------------------------------------------------------------------------
### Installing and Configuring Shells
###----------------------------------------------------------------------------
print_goal "Installing Bash, Dash, et al..."
brew install shellcheck dash bash-completion@2 bat


###---
### Softlink sh to dash
###---
print_req "Creating a softlink from sh to dash..."
ln -sf "${HOMEBREW_PREFIX}/bin/dash" "${HOMEBREW_PREFIX}/bin/sh"


###----------------------------------------------------------------------------
### Install the latest git
###----------------------------------------------------------------------------
print_req "Installing Git..."
brew install git

print_req "Writing ~/.gitconfig..."
cat << EOF > "$myGitConfig"
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

### Display file contents
cat "$myGitConfig"

### ignore some things universally
print_req "Writing ~/.gitignore..."
cat << EOF > "$myGitIgnore"
# macOS Stuff
.DS_Store
# Ignore IDE Garbage
**/.idea/*
**/.vscode/*
**/.cursor/*
.cursor/
.cursorrules
EOF

### Display file contents
cat "$myGitIgnore"


###----------------------------------------------------------------------------
### Install Ansible
###   * Configuration happens later
###----------------------------------------------------------------------------
print_goal "Installing Ansible (and Python as a dependency)..."
brew install ansible


print_info "Update pip..."
/Library/Developer/CommandLineTools/usr/bin/python3 -m pip install --upgrade pip --user


print_info "Ansible Version Info:"
ansible --version


###----------------------------------------------------------------------------
### Save installed package and library details before the install
### We will use the $XDG_CONFIG_HOME like a good POSIX system should.
### REF: https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html
###----------------------------------------------------------------------------
print_req "Saving some ${0:t} post-exec details..."


### Save list of all OS-related apps
print_info "Apps to a list..."
find /Applications -maxdepth 1 -type d -print | \
    sed 's|/Applications/||'    \
    > "$adminLogs/apps-find-all-$stage-install.log"


### Save log of all dotDirectories in your HOME directory
print_info "\$HOME dot directories to a list..."
find "$HOME" -maxdepth 1 \( -type d -o -type l \) -name ".*" | \
    sed "s|^$HOME/||" > "$adminLogs/apps-home-dot-dirs-$stage-install.log"


### Save log of all Homebrew-installed programs
print_info "Homebrew programs to a list..."
brew leaves > "$adminLogs/apps-homebrew-$stage-install.log"


### Save log of all OS-related apps
print_info "PAID Apps to a list..."
find /Applications -maxdepth 4 -path '*Contents/_MASReceipt/receipt' -print | \
    sed 's|.app/Contents/_MASReceipt/receipt|.app|g; s|/Applications/||' \
    > "$adminLogs/apps-paid-$stage-install.log"


### Save minimal application and library output
print_info "Apps to a list: pkgutil..."
pkgutil --pkgs > "$adminLogs/apps-pkgutil-$stage-install.log"


### Save log of all Python-related libs
print_info "Python libraries (Homebrew) to a list..."
pip3 list > "$adminLogs/libs-pip-python-$stage-install.log"


###----------------------------------------------------------------------------
### Install Oh My Zsh!
### REF: https://ohmyz.sh/ | GitHub: https://github.com/ohmyzsh/ohmyzsh
###----------------------------------------------------------------------------
print_req """
    Pulling the latest Oh My Zsh build...
"""
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
    sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    tools/config-shell.sh
else
    print_req "Oh My ZSH is already installed."
fi


###----------------------------------------------------------------------------
### Janitorial stuff
###----------------------------------------------------------------------------
### Save the install-prep log
mv -f /tmp/install-prep.out "$adminLogs/install-prep.log"

### Create a link to the log file
ln -s "$adminLogs/install-prep.log" /tmp/install-prep.log


###----------------------------------------------------------------------------
### What's the total run-time?
###----------------------------------------------------------------------------
### POST: Calculate duration
timePost="$(date +'%s')"
procDur=$((timePost - timePre))

### Convert seconds to HH:MM:SS
hours=$((procDur / 3600))
mins=$(((procDur % 3600) / 60))
secs=$((procDur % 60))


###----------------------------------------------------------------------------
### Announcements
###----------------------------------------------------------------------------
print_info """
    Process start at: $(date -r "$timePre" +'%T')
    Process end   at: $(date -r "$timePost" +'%T')
    Process duration: $(printf '%02d:%02d:%02d' "$hours" "$mins" "$secs")
"""


### make the announcement
print_req """

	You are now prepped for the mac-ops process.

	Review /tmp/install-prep.log for errors. Then...


    	It's time to reboot!
    	sudo shutdown -r now
"""


###---
### fin~
###---
exit 0
