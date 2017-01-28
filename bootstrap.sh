#!/usr/bin/env bash
# shellcheck disable=SC1090,SC1091,SC2059,SC2154
#------------------------------------------------------------------------------
# PURPOSE: Configure a base environment to get back to work quickly.
#------------------------------------------------------------------------------
# EXECUTE: ./bootstrap.sh 2>&1 | tee macos-config.out
#------------------------------------------------------------------------------
# PREREQS: 1) ssh keys must be on the new system for Github clones
#          2)
#------------------------------------------------------------------------------
#  AUTHOR: todd_dsm
#------------------------------------------------------------------------------
#    DATE: 2017/01/11
#------------------------------------------------------------------------------
set -x

###------------------------------------------------------------------------------
### VARIABLES
###------------------------------------------------------------------------------
timePre="$(date +'%T')"
source './my-vars.sh'

# macOS Build
declare adminDir="$HOME/.config/admin"
#declare adminLogs="$adminDir/logs"
declare backupDir="$adminDir/backup"
declare hostRemote='github.com'
declare termStuff="$myDownloads"
declare solarizedGitRepo='git@github.com:altercation/solarized.git'
declare myBashProfile="$HOME/.bash_profile"
declare myBashrc="$HOME/.bashrc"
declare myConfigs="$HOME/.config"
declare sysPaths='/etc/paths'
declare sysManPaths='/etc/manpaths'
# Configure Vim
declare knownHosts="$HOME/.ssh/known_hosts"
declare vimSimpleTag='" vimSimple configuration'
declare vimSimpleLocal="$myCode/vimsimple"
declare vimSimpleGitRepo='https://github.com/todd-dsm/vimSimple.git'
declare pymodConfig="$vimSimpleLocal/vim/bundle/python-mode/plugin/pymode.vim"
declare jsonIndent="$vimSimpleLocal/vim/bundle/vim-json/indent/json.vim"
declare jsonIndREGEX='" =================$'
declare jsonAppendStr='autocmd filetype json set et ts=2 sw=2 sts=2'
# Configure macOS
declare dirScreenshot="$myPics/screens"
declare linkScreens="$myDesktop/screens"

# Test the last variable
if [[ -z "$linkScreens" ]]; then
    printf '%s\n' "Crap! something is jacked."
    exit 1
else
    printf '%s\n' "Initial configs look good. Let's do this!"
fi

###----------------------------------------------------------------------------
### FUNCTIONS
###----------------------------------------------------------------------------


###----------------------------------------------------------------------------
### The Setup
###----------------------------------------------------------------------------
### Backup some files before we begin
###---
printf '\n%s\n' "Backing up the /etc directory before we begin..."
sudo rsync -aE /private/etc "$backupDir/"

###---
### Restore SSH Keys from backup. Required for Github interaction.
###---
printf '\n%s\n' "Checking to see if we have the Github public key..."
rsync -aEv  "$myBackups/.ssh/" "$mySSHDir/"

###---
### Add the Github key to the knownhosts file
###---
printf '\n%s\n\n' "Checking to see if we have the Github public key..."
if ! grep "^$hostRemote" "$knownHosts"; then
    printf '%s\n' "  We don't, pulling it now..."
    ssh-keyscan -t 'rsa' "$hostRemote" >> "$knownHosts"
else
    printf '%s\n' "  We have it, all good."
fi

###---
### Pull some stuff for the Terminal
###---
printf '\n%s\n\n' "Pulling Terminal stuff..."
git clone "$solarizedGitRepo" "$termStuff/solarized"

# Pull the settings back
rsync -aEv  "$myBackups/Documents/system" "$myDocs/"


###----------------------------------------------------------------------------
### Configure the Shell: base options
###----------------------------------------------------------------------------
printf '\n%s\n\n' "Configuring base shell options..."

printf '%s\n' "  Configuring $myBashProfile ..."
cat << EOF >> "$myBashProfile"
# URL: https://www.gnu.org/software/bash/manual/bashref.html#Bash-Startup-Files
if [ -f ~/.bashrc ]; then
	. ~/.bashrc
fi

EOF


printf '%s\n' "  Configuring $myBashrc ..."
cat << EOF >> "$myBashrc"
### My ~/.bashrc
declare sysBashrc='/etc/bashrc'
if [[ -f "\$sysBashrc" ]]; then
    . "\$sysBashrc"
fi

###############################################################################
###                                  System                                 ###
###############################################################################
export TERM='xterm-256color'
export HISTFILESIZE=
export HISTSIZE=
export PROMPT_COMMAND='history -a'
export HISTCONTROL=ignoredups
export HISTTIMEFORMAT="%a%l:%M %p  "
export HISTIGNORE='ls:bg:fg:history'

EOF

source "$myBashrc" && tail -17 "$myBashProfile"

###----------------------------------------------------------------------------
### Install Homebrew
###----------------------------------------------------------------------------
printf '\n%s\n' "Installing Homebrew..."
yes | /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

printf '%s\n' "  Updating Homebrew..."
brew update

printf '%s\n' "  Running 'brew doctor'..."
brew doctor

printf '%s\n' "  Tapping Homebrew binaries..."
brew tap homebrew/binary
brew tap caskroom/fonts

printf '\n%s\n' "Current paths:"
cat "$sysPaths"

printf '%s\n' "  Current man paths:"
cat "$sysManPaths"

###----------------------------------------------------------------------------
### Install the font: Hack
###----------------------------------------------------------------------------
printf '\n%s\n' "Installing font: Hack..."
brew cask install font-hack


###----------------------------------------------------------------------------
### Let's Get Open: GNU Coreutils
###----------------------------------------------------------------------------
printf '\n%s\n' "Let's get open..."

printf '%s\n' "Installing sed - the stream editor..."
brew install gnu-sed --with-default-names

printf '%s\n' "  Installing GNU Coreutils..."
brew install coreutils

# Set new Variables
#declare pathHomeBrew="$(brew --prefix)"
declare pathGNU_CORE="$(brew --prefix coreutils)"

# Set path for the GNU Coreutils
sudo sed -i "\|/usr/local/bin|i $pathGNU_CORE/libexec/gnubin" "$sysPaths"

# Set path for the GNU Coreutils Manuals
# FIX: MANPATH: no one seems to reliably know how it works; more later.
sudo sed -i "\|/usr/share/man|i $pathGNU_CORE/libexec/gnuman" "$sysManPaths"

# Verify the new paths have been set
printf '\n%s\n' "New paths:"
cat "$sysPaths"

printf '%s\n' "New man paths:"
cat "$sysManPaths"


printf '%s\n' "  Configuring GNU Coreutils..."
cat << EOF >> "$myBashrc"
###############################################################################
###                                 coreutils                               ###
###############################################################################
declare manGNUCoreUtils='/usr/local/opt/coreutils/libexec/gnuman'
declare manBrewProgs='/usr/local/share/man'
declare manSystemProgs='/usr/share/man'
export MANPATH="\$manGNUCoreUtils:\$manBrewProgs:\$manSystemProgs"
# Filesystem Operational Behavior
function ll { ls --color -l   "\$@" | egrep -v '.(DS_Store|CFUserTextEncoding)'; }
function la { ls --color -al  "\$@" | egrep -v '.(DS_Store|CFUserTextEncoding)'; }
function ld { ls --color -ld  "\$@" | egrep -v '.(DS_Store|CFUserTextEncoding)'; }
function lh { ls --color -alh "\$@" | egrep -v '.(DS_Store|CFUserTextEncoding)'; }
alias cp='cp -rfvp'
alias mv='mv -v'
# FIX: alias for GNU zip/unzim do not work
alias zip='/usr/local/bin/gzip'
alias unzip='/usr/local/bin/gunzip'
alias hist='history | cut -c 21-'

EOF

source "$myBashrc" && tail -14 "$myBashrc"


###----------------------------------------------------------------------------
### Install GNU Tools and Languages
###----------------------------------------------------------------------------
printf '\n%s\n' "Installing and configuring additional GNU programs..."
brew install homebrew/dupes/ed --with-default-names
brew install homebrew/dupes/gzip
brew install gnu-indent --with-default-names
brew install findutils --with-default-names
brew install gnu-which --with-default-names
brew install wget --with-pcre
# Both zip & unzip are in the same package
brew install gnu-tar --with-default-names
brew install homebrew/dupes/diffutils
brew install gnu-time --with-default-names
brew install homebrew/dupes/grep --with-default-names
brew install homebrew/dupes/rsync
brew install watch tree gawk psgrep

printf '\n%s\n' "  Configuring grep..."
cat << EOF >> "$myBashrc"
###############################################################################
###                                   grep                                  ###
###############################################################################
alias grep='grep   --color=auto' 2>/dev/null
alias egrep='egrep --color=auto' 2>/dev/null
alias fgrep='fgrep --color=auto' 2>/dev/null

###############################################################################
###                                   find                                  ###
###-------------------------------------------------------------------------###
### Easily find stuff within the root '/' filesystem (fs) without errors.
###----------------------------------------------------------------------------
# Find files somewhere on the system; to use:
#   1) call the alias, 'findsys'
#   2) pass a directory where the search should begin, and
#   3) pass a file name, either exact or fuzzy: e.g.:
# $ findsys /var/ '*.log'
function findSystemStuff()   {
    findDir="\$1"
    findFSO="\$2"
    sudo find "\$findDir" -name 'cores' -prune , -name 'dev' -prune , -name 'net' -prune , -name "\$findFSO"
}

alias findsys=findSystemStuff
###-------------------------------------------------------------------------###
### Easily find stuff within your home directory. To use:
#     1) call the alias, 'findmy'
#     2) pass a 'type' of fs object, either 'f' (file) or 'd' (directory)
#     3) pass the object name, either exact or fuzzy: e.g.:
#     \$ findmy f '.vim*'
function findMyStuff()   {
    findType="\$1"
    findFSO="\$2"
    find "\$HOME" -type "\$findType" -name "\$findFSO"
}

alias findmy=findMyStuff

EOF

source "$myBashrc" && tail -38 "$myBashrc"


###----------------------------------------------------------------------------
### Useful System Utilities
###----------------------------------------------------------------------------
printf '\n%s\n' "Installing some system utilities..."
brew install git nmap ssh-copy-id sipcalc pstree gnupg dos2unix testdisk


###----------------------------------------------------------------------------
### Install the Casks (GUI Apps)
###----------------------------------------------------------------------------
printf '\n%s\n' "Installing some utilities..."
brew cask install \
    gfxcardstatus java virtualbox android-file-transfer \
    wireshark tcl flux osxfuse atom

brew install homebrew/fuse/sshfs


printf '\n%s\n' "Installing Google Chrome..."
brew cask install google-chrome
mkdir -p "$HOME/Library/Application\ Support/Google/Chrome"
chown -R vagrant:staff "/Users/vagrant/Library/Application Support"/

printf '\n%s\n' "Installing VMware Fusion: 7..."
brew install Caskroom/versions/vmware-fusion7


###----------------------------------------------------------------------------
### PYTHON
###----------------------------------------------------------------------------
printf '\n%s\n' "Installing Python..."
brew install python

printf '%s\n' "  Configuring Python..."
cat << EOF >> "$myBashrc"
###############################################################################
###                                  Python                                 ###
###############################################################################
export PYTHONPATH="$(brew --prefix)/lib/python2.7/site-packages"
export PIP_CONFIG_FILE="\$HOME/.config/pip/pip.conf"

EOF


###---
### Configure pip
###---
printf '%s\n' "Configuring pip..."
printf '%s\n' "  Creating pip home..."
if [[ ! -d "$myConfigs/pip" ]]; then
    mkdir -p "$myConfigs/pip"
fi

printf '%s\n' "  Configuring Python pip..."
cat << EOF >> "$HOME/.config/pip/pip.conf"
# pip configuration
[list]
format=columns

EOF

source "$myBashrc" && tail -5 "$myBashrc"


printf '\n%s\n' "  Testing pip config..."
pip list

printf '%s\n' "  Upgrading Python Pip and setuptools..."
pip install --upgrade pip setuptools


###----------------------------------------------------------------------------
### golang
###----------------------------------------------------------------------------
printf '\n%s\n' "Installing the Go Programming Language..."
brew install go

# Create the code path
printf '\n%s\n' "  Creating the \$GOPATH directory..."
mkdir -p "$HOME/code/gocode"

printf '\n%s\n' "  Configuring Go..."
cat << EOF >> "$myBashrc"
###############################################################################
###                                    Go                                   ###
###############################################################################
export GOPATH="\$HOME/code/gocode"
alias mygo="cd \$GOPATH"

EOF

source "$myBashrc" && tail -5 "$myBashrc"


###----------------------------------------------------------------------------
### Bash
###----------------------------------------------------------------------------
printf '\n%s\n' "Installing Bash..."
brew install bash shellcheck dash

# Add the new version of Bash to system shells file
printf '\n%s\n' "  Configuring Bash..."
declare sysShells='/etc/shells'

grep ".*bash$" "$sysShells"
sudo sed -i "/.*bash$/ i\/usr/local/bin/bash" "$sysShells"
grep ".*bash$" "$sysShells"

cat << EOF >> "$myBashrc"
###############################################################################
###                                   Bash                                  ###
###############################################################################
export SHELL='/usr/local/bin/bash'
export BASH_VERSION="\$(bash --version | head -1)"
# ShellCheck: Ignore: https://goo.gl/n9W5ly
export SHELLCHECK_OPTS="-e SC2155"

EOF

source "$myBashrc" && tail -8 "$myBashrc"


###----------------------------------------------------------------------------
### Vim: The Power and the Glory
###----------------------------------------------------------------------------
printf '\n%s\n' "Upgrading to full-blown Vim..."
# Verify before install
printf '%s\n' "  Checking Apple's Vim..."
vim --version | egrep --color 'VIM|Compiled|python|ruby|perl|tcl'

# Install Vim with support for:
#   Use this version over the system one
#   w/o NLS (National Language Support)
#   +Python   (v2; default)
#   +Ruby     (default)
#   +Lua      (broke)
#   +mzscheme (broke)
printf '%s\n' "  Installing Vim..."
brew install vim --override-system-vi --without-nls \
    --with-lua --with-mzscheme --with-tcl

# We should evaluate Neovim
printf '%s\n' "  Installing Neovim..."
brew install neovim/neovim/neovim

printf '%s\n' "  Configuring Vim..."
cat << EOF >> "$myBashrc"
###############################################################################
###                                   Vim                                   ###
###############################################################################
export EDITOR='/usr/local/bin/vim'
alias vi="\$EDITOR"
alias vim="\$EDITOR"
alias nim='/usr/local/bin/nvim'

EOF

source "$myBashrc" && tail -8 "$myBashrc"


# Verify after install
printf '%s\n' "  The Real version of Vim:"
vim --version | egrep --color 'VIM|Compiled|python|ruby|perl|tcl'


###----------------------------------------------------------------------------
### Amazon AWS CLI
###----------------------------------------------------------------------------
printf '\n%s\n' "Installing the AWS CLI..."
pip install awscli

printf '%s\n' "  Installing some AWS CLI Utilitiese..."
pip install --upgrade jmespath jmespath-terminal

brew tap jmespath/jmespath
brew install jp

printf '%s\n' "  Configuring the AWS CLI..."
cat << EOF >> "$myBashrc"
###############################################################################
###                                 Amazon                                  ###
###############################################################################
complete -C "\$(type -P aws_completer)" aws
#export AWS_PROFILE='awsUser'
export AWS_CONFIG_FILE="\$HOME/.aws/config"

EOF

printf '%s\n' "  Setting the AWS User to your local account name..."
sed -i "/AWS_PROFILE/ s/awsUser/$USER/g" "$myBashrc"

source "$myBashrc" && tail -7 "$myBashrc"


###----------------------------------------------------------------------------
### Add a space for common remote access tokens
###----------------------------------------------------------------------------
printf '\n%s\n' "Configuring Access Tokens for Remote services..."
cat << EOF >> "$myBashrc"
###############################################################################
###                             Remote Access                               ###
###############################################################################
# HashiCorp Atlas
export ATLAS_TOKEN=''
# Homebrew / Github
export HOMEBREW_GITHUB_API_TOKEN=''

EOF

source "$myBashrc" && tail -8 "$myBashrc"


###----------------------------------------------------------------------------
### HashiCorp: Terraform
###----------------------------------------------------------------------------
printf '\n%s\n' "Installing Terraform..."
brew install terraform terraform-inventory graphviz

printf '%s\n' "  Configuring Terraform..."
cat << EOF >> "$myBashrc"
###############################################################################
###                                Terraform                                ###
###############################################################################
alias tf='/usr/local/bin/terraform'
export TF_VAR_AWS_PROFILE="\$AWS_PROFILE"
export TF_LOG='DEBUG'
export TF_LOG_PATH='/tmp/terraform.log'

EOF

source "$myBashrc" && tail -8 "$myBashrc"


###----------------------------------------------------------------------------
### HashiCorp: Packer
###----------------------------------------------------------------------------
printf '\n%s\n' "Installing Packer..."
brew install packer

printf '%s\n' "  Configuring Packer..."
cat << EOF >> "$myBashrc"
###############################################################################
###                                  Packer                                 ###
###############################################################################
export PACKER_HOME="\$HOME/vms/packer"
export PACKER_CONFIG="\$PACKER_HOME"
export PACKER_CACHE_DIR="\$PACKER_HOME/vms/packer/iso-cache/"
export PACKER_LOG='yes'
export PACKER_LOG_PATH='/tmp/packer.log'
export PACKER_NO_COLOR='yes'

EOF

source "$myBashrc" && tail -10 "$myBashrc"


###----------------------------------------------------------------------------
### HashiCorp: Vagrant
###----------------------------------------------------------------------------
printf '\n%s\n' "Installing Vagrant..."
brew cask install vagrant

printf '%s\n' "  Configuring Vagrant..."
cat << EOF >> "$myBashrc"
###############################################################################
###                                 Vagrant                                 ###
###############################################################################
#export VAGRANT_LOG=debug
export VAGRANT_HOME="\$HOME/vms/vagrant"
export VAGRANT_BOXES="\$VAGRANT_HOME/boxes"
export VAGRANT_DEFAULT_PROVIDER='virtualbox'

EOF

source "$myBashrc" && tail -8 "$myBashrc"


###----------------------------------------------------------------------------
### Ansible
###----------------------------------------------------------------------------
printf '\n%s\n' "Installing Ansible..."
pip install --upgrade ansible

printf '%s\n' "  Ansible Version Info:"
ansible --version

printf '%s\n' "  Configuring Vagrant..."
cat << EOF >> "$myBashrc"
###############################################################################
###                                 Ansible                                 ###
###############################################################################
export ANSIBLE_CONFIG="\$HOME/.ansible"

EOF

source "$myBashrc" && tail -6 "$myBashrc"

# Create a home for Ansible
printf '%s\n' "  Creating the Ansible directory..."
mkdir -p "$HOME/.ansible/roles"
touch "$HOME/.ansible/"{ansible.cfg,hosts}


###----------------------------------------------------------------------------
### Docker
###----------------------------------------------------------------------------
printf '\n%s\n' "Installing Docker, et al..."
brew install docker docker-machine docker-compose

# Create a vbox VM
printf '%s\n' "  Creating the Docker VM..."
docker-machine create --driver virtualbox default

printf '%s\n' "  Configuring Docker..."
cat << EOF >> "$myBashrc"
###############################################################################
###                                 DOCKER                                  ###
###############################################################################
eval "\$(docker-machine env default)"

EOF

source "$myBashrc" && tail -5 "$myBashrc"


###----------------------------------------------------------------------------
### Adobe CS6 Web & Design Premium (4.5GB)
###----------------------------------------------------------------------------
#printf '\n%s\n' "Installing Adobe CS6 Design & Web Premium..."
#brew cask install adobe-cs6-design-web-premium


###----------------------------------------------------------------------------
### Post-configuration Steps
###----------------------------------------------------------------------------
printf '\n%s\n' "Securing ~/.bashrc ..."
chmod 600 "$myBashrc"


###----------------------------------------------------------------------------
### Configure Vim
###----------------------------------------------------------------------------
### Pull the code
###---
printf '\n%s\n\n' "Pulling the vimSimple repo..."
git clone --recursive -j10 "$vimSimpleGitRepo" "$vimSimpleLocal"

### Make softlinks to the important files
printf '\n%s\n\n' "Creating softlinks for ~/.vim and ~/.vimrc"
ln -s "$vimSimpleLocal/vimrc" .vimrc
ln -s "$vimSimpleLocal/vim"   .vim


###----------------------------------------------------------------------------
### Modify 1-off configurations on current submodules
###---
printf '\n%s\n\n' "Making 1-off configuration changes..."
### python-mode: disable: 'pymode_rope'
printf '%s\n' "Disabling pymode_rope..."
printf '%s\n' "  Check Value before change:"
ropeBool="$(grep "('g:pymode_rope', \w)$" "$pymodConfig")"
ropeBool="${ropeBool:(-2):1}"
if [[ "$ropeBool" -ne '0' ]]; then
    printf '%s\n' "  Value is $ropeBool, Changing the value to Zero..."
    sed -i "/'g:pymode_rope', 1/ s/1/0/g" "$pymodConfig"
    sed -i "/'g:pymode_rope', 0/i $vimSimpleTag" "$pymodConfig"
else
    printf '%s\n' "  Value is already Zero"
    grep "('g:pymode_rope', \w)$" "$pymodConfig"
fi

### Print the value for logging
printf '%s\n' "  The pymode_rope plugin is disabled:"
grep "('g:pymode_rope', \w)$" "$pymodConfig"


###---
### json-vim: add: 'autocmd' to the top of the file
###---
sed -i "/$jsonIndREGEX/a $jsonAppendStr" "$jsonIndent"

### json-vim: add a space seperator
sed -i "/$jsonIndREGEX/G" "$jsonIndent"

### json-vim: add: tag as vimSimple configuration
sed -i "/${jsonAppendStr%%\ *}/i $vimSimpleTag" "$jsonIndent"


###----------------------------------------------------------------------------
### Configure The macOS
###----------------------------------------------------------------------------
### Configure the System
###---
printf '\n%s\n' "Configuring the System:"

###---
###  Set the hostname(s)
###---
printf '%s\n' "  Configuring the hostname(s)..."
### Configure the network hostname
printf '%s\n' "  Configuring network hostname..."
sudo scutil --set ComputerName "$myHostName"

### Configure the Terminal hostname
printf '%s\n' "  Configuring Terminal hostname..."
sudo scutil --set HostName "${myHostName%%.*}"

### Configure the AirDrop hostname
printf '%s\n' "  Configuring AirDrop hostname..."
sudo scutil --set LocalHostName "${myHostName%%.*}"


###---
### Storage
###---
printf '\n%s\n' "Configuring Storage:"
printf '%s\n' "  Save to disk by default (not to iCloud)..."
# defaults read NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false
defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false


###---
### Disable smart quotes and dashes system-wide
###---
printf '\n%s\n' "Disabling smart quotes and dashes system-wide:"
### Disable smart quotes
printf '%s\n' "  Disabling smart quotes..."
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false
### Disable smart dashes
printf '%s\n' "  Disabling smart dashes..."
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false


###----------------------------------------------------------------------------
### The Finder
###----------------------------------------------------------------------------
### Display all folders in List View
###---
printf '\n%s\n' "Setting Finder Preferences:"
printf '%s\n'     "  Display all windows in List View..."
defaults write com.apple.finder FXPreferredViewStyle Nlsv


###---
### Enable sidebar directories
###---
# Add $HOME
printf '%s\n'     "  Add \$HOME to sidebar..."
sfltool add-item com.apple.LSSharedFileList.FavoriteItems "file:///$HOME"
# Add Pictures
printf '%s\n'     "  Add Pictures to sidebar..."
sfltool add-item com.apple.LSSharedFileList.FavoriteItems "file:///$HOME/Pictures"
# Add Music
printf '%s\n'     "  Add Music to sidebar..."
sfltool add-item com.apple.LSSharedFileList.FavoriteItems "file:///$HOME/Music"
# Add Movies
printf '%s\n'     "  Add Movies to sidebar..."
sfltool add-item com.apple.LSSharedFileList.FavoriteItems "file:///$HOME/Movies"


###---
### New window displays home
###---
printf '%s\n' "  Display the home directory by default..."
defaults write com.apple.finder NewWindowTarget -string "PfLo"
defaults write com.apple.finder NewWindowTargetPath -string "file://${HOME}/"


###---
### Show status bar in Finder
###---
printf '%s\n' "  Display status bar in Finder..."
defaults write com.apple.finder ShowStatusBar -bool true


###---
### Search the current folder by default
###---
printf '%s\n' "  Search the current folder by default..."
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"


###---
### Display all file extensions in Finder
###---
printf '%s\n' "  Display all extensions by default..."
defaults write NSGlobalDomain AppleShowAllExtensions -bool true


###---
### Screenshot behavior
###---
printf '%s\n' "  Save screenshots to a specified location..."
if [[ ! -d "$dirScreenshot" ]]; then
    mkdir -p "$dirScreenshot"
    defaults write com.apple.screencapture location "$dirScreenshot"
fi

### Create a softlink on the Desktop
if [[ ! -h "$linkScreens" ]]; then
    ln -s "$dirScreenshot" "$linkScreens"
fi

### Set screenshots without window shadows
printf '%s\n' "  Save screenshots without window shadows..."
defaults write com.apple.screencapture disable-shadow -bool true

###---
### Show battery percentage
###---
printf '%s\n' "  Show battery percentage..."
# defaults read com.apple.menuextra.battery ShowPercent
defaults write com.apple.menuextra.battery ShowPercent -string 'YES'


###---
### Display Configuration
###---
printf '%s\n' "  Don't show mirroring options in the menu bar..."
defaults write com.apple.airplay showInMenuBarIfPresent -bool false

###---
### Display Date/Time formatted: 'EEE MMM d  h:mm a'
###---
printf '%s\n' "  Display Day HH:MM AM format..."
defaults write com.apple.menuextra.clock 'DateFormat' -string 'EEE MMM d  h:mm a'


###---
### Network Shares
###---
printf '%s\n' "  Do NOT create .DS_Store files on network volumes..."
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true


###---
### Dialog Box behavior
###---

### The Save Dialog Box
printf '%s\n' "  Expand Save panel by default..."
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true


### The Print Dialog Box
printf '%s\n' "  Expand Print panel by default..."
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint2 -bool true


###----------------------------------------------------------------------------
### The Dock
###----------------------------------------------------------------------------
printf '\n%s\n' "Setting Dock Preferences:"
printf '%s\n' "  Display The Dock at 46px..."
# Set default Tile Size to 42px
defaults write com.apple.dock tilesize 42

### Auto-Hide the Dock
printf '%s\n' "  Auto-hide The Dock..."
defaults write com.apple.dock autohide -bool true

### Optionally: adjust timing with these settings
#defaults write com.apple.dock autohide-delay -float 0
#defaults write com.apple.dock autohide-time-modifier -float 0


###----------------------------------------------------------------------------
### Configure Basic OS Security
###----------------------------------------------------------------------------
printf '\n%s\n' "Configuring Basic OS Security:"

###---
### Disable Guest User at the Login Screen
###---
printf '%s\n' "  Disable Guest User at the Login Screen..."
sudo defaults write /Library/Preferences/com.apple.loginwindow GuestEnabled -bool NO
# sudo defaults read /Library/Preferences/com.apple.loginwindow GuestEnabled
# OUTPUT: 0


###---
### Apple File Protocol
###---
printf '%s\n' "  Disable AFP Guest Access..."
defaults write com.apple.AppleFileServer.plist AllowGuestAccess -int 0


###----------------------------------------------------------------------------
### Configure Application Behavior
###----------------------------------------------------------------------------
printf '\n%s\n\n' "Configuring Application Preferences:"

###---
### TextEdit
###---
printf '%s\n' "  TextEdit Preferences: before:"
defaults read com.apple.TextEdit

# Set Author Name
printf '%s\n' "  Setting autor name..."
defaults write com.apple.TextEdit author 'Todd E Thomas' # FIX
# Use plain text not RichText
printf '%s\n' "  Use plain text by default..."
defaults write com.apple.TextEdit RichText -int 0
# Set Font
printf '%s\n' "  We'll use Courier as the font..."
defaults write com.apple.TextEdit NSFixedPitchFont 'Courier'
# Set Font Size
printf '%s\n' "  Courier is set to 14pt..."
defaults write com.apple.TextEdit NSFixedPitchFontSize -int 14
# Default Window Size
printf '%s\n' "  New Windows will open at H:45 x W:100..."
defaults write com.apple.TextEdit WidthInChars -int 100
defaults write com.apple.TextEdit HeightInChars -int 45
# Disable SmartDashes and SmartQuotes
printf '%s\n' "  Disabling SmartDashes and SmartQuotes..."
defaults write com.apple.TextEdit SmartDashes -int 0
defaults write com.apple.TextEdit SmartQuotes -int 0

printf '\n%s\n' "  TextEdit Preferences: after:"
defaults read com.apple.TextEdit


###---
### Stop Photos from opening automatically when plugging in iPhone [TEST]
###---
printf '%s\n' "  Stop Photos from opening automatically..."
defaults -currentHost write com.apple.ImageCapture disableHotPlug -bool true


###----------------------------------------------------------------------------
### Remove the Github Remote Host Key
###----------------------------------------------------------------------------
#printf '\n%s\n' "Removing the $hostRemote public key from our known_hosts file..."
#ssh-keygen -f "$knownHosts" -R "$hostRemote"


###----------------------------------------------------------------------------
### Save installed package and library details AFTER the install
###----------------------------------------------------------------------------
printf '\n%s\n' "Saving some pre-install app/lib details..."
tools/admin-app-details.sh post


###----------------------------------------------------------------------------
### Restore Personal Data
###----------------------------------------------------------------------------
printf '\n%s\n' "Restoring files..."
tools/restore-my-stuff.sh 2> /tmp/rsycn-errors.out


###----------------------------------------------------------------------------
### Announcements
###----------------------------------------------------------------------------
printf '\n\n%s\n' """
    1) Setup the AWS Client profile for yourself; e.g.:
       aws configure --profile myAWSUserName
       a) Before using the 'aws' program any further:
            Check the value of AWS_PROFILE in ~/.bashrc
            This is very likely not the user name you want.
       b) Edit ~/.bashrc and chage it to the right value.
       c) Uncomment this line: 'export AWS_PROFILE='yourUser''
       d) Write the file and Quit: :wq
       e) Source-in the changes: source ~/.bashrc
       f) Open the terminal and run this command:
            aws iam get-user
"""

printf '%s\n' """
    2) Still haven't figured out how to remove stuff from the sidebar; customize
       this to your tastes;  Finder > Preferences: Sidebar.

    3) You still have to open System Preferences and verify your settings.

    4) Data Restoration:
       a) Check for any data restore errors by:
          less /tmp/rsycn-errors.out
       b) Check for any data that is not owned by you:
          less /tmp/find-out.log
"""


###----------------------------------------------------------------------------
### Quick and Dirty duration
###----------------------------------------------------------------------------
timePost="$(date +'%T')"

### Convert time to a duration
startTime=$(date -u -d "$timePre" +"%s")
endTime=$(date -u -d "$timePost" +"%s")
procDur="$(date -u -d "0 $endTime sec - $startTime sec" +"%H:%M:%S")"
printf '%s\n' """
    The procss start  at: $timePre
    The procss end    at: $timePost
    The process duration: $procDur
"""


###----------------------------------------------------------------------------
### Fin~
###----------------------------------------------------------------------------
exit 0