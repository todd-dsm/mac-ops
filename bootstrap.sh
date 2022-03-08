#!/usr/bin/env bash
# shellcheck disable=SC1090,SC1091,SC2059,SC2154,SC2116,SC1117
# FIXME: SC1117
#------------------------------------------------------------------------------
# PURPOSE:  A QnD script to configure a base environment so I can get back to
#           work quickly. It will be replaced by Ansible automation as soon as
#           possible between laptop upgrades.
#           PASS 'TEST' as the first argument; if not, it's LIVE.
#------------------------------------------------------------------------------
# EXECUTE:  ./bootstrap.sh <TEST> 2>&1 | tee ~/.config/admin/logs/mac-ops-config.out
#------------------------------------------------------------------------------
# PREREQS: 1) ssh keys must be on the new system for Github clones
#          2)
#------------------------------------------------------------------------------
#  AUTHOR: todd-dsm
#------------------------------------------------------------------------------
set -x

###------------------------------------------------------------------------------
### VARIABLES
###------------------------------------------------------------------------------
: "${1:-LIVE}"
theENV="$1"
workDir="${PWD}"
timePre="$(date +'%T')"
myGroup="$(id -gn)"


### source-in user-pecific variables
source my-vars.env "$theENV" > /dev/null 2>&1
printf '\n%s\n' "Configuring this macOS for $myFullName."


### calm the homebrew messages
export HOMEBREW_NO_ENV_HINTS=TRUE


### A final announcement before we send it
if [[ "$theENV" == 'TEST' ]]; then
    # We're either testing or we aint
    echo "THIS IS ONLY A TEST"
    sleep 2s
else
    echo "We are preparing to going live..."
    sleep 5s
fi


###----------------------------------------------------------------------------
### FUNCTIONS
###----------------------------------------------------------------------------
### source-in the print library
###---
source lib/print-message-formatting.sh


###----------------------------------------------------------------------------
### The Setup
###----------------------------------------------------------------------------
### Turn on debugging in TEST mode
###---
if [[ "$theENV" == 'TEST' ]]; then
    set -x
fi


###---
### Add the Github key to the knownhosts file
###---
printReq  "Checking to see if we have the Github public key..."
if ! grep "^$hostRemote" "$knownHosts" > /dev/null 2>&1; then
    printHead "We don't, pulling it now..."
    ssh-keyscan -t 'rsa' "$hostRemote" >> "$knownHosts"
else
    printHead "We have the Github key, all good."
fi


####---
### Backup some files before we begin
####---
if [[ "$theENV" == 'TEST' ]]; then
    printReq "Backing up the /etc directory before we begin..."
    sudo rsync -aE /private/etc "$backupDir/" 2> /tmp/rsync-err-etc.out
fi

####---
### Pull some stuff for the Terminal
####---
printReq "Pulling Terminal stuff..."
git clone "$solarizedGitRepo" "$termStuff/solarized" > /dev/null 2>&1

### Pull the settings back
if [[ ! -d "$myBackups" ]]; then
    printHead "There are no 'settings' to restore."
else
    printHead "Restoring Terminal (and other) settings..."
    rsync -aEv  "$myBackups/Documents/system" "$myDocs/" 2> /tmp/rsync-err-system.out
fi


################################################################################
####                                  System                                 ###
################################################################################
### Install the font: Hack
### https://github.com/Homebrew/homebrew-cask-fonts
###----------------------------------------------------------------------------
printHead "Installing font: Hack..."
brew tap homebrew/cask-fonts
brew install font-hack


###----------------------------------------------------------------------------
### Install the Casks (GUI Apps)
###----------------------------------------------------------------------------
printReq "Installing GUI (cask) Apps..."
printHead "Installing Utilities..."
brew install --cask \
    google-chrome visual-studio-code intellij-idea-ce  \
    virtualbox virtualbox-extension-pack wireshark


###---
### VirtualBox configurations
###---
printHead "Configuring VirtualBox..."
printInfo "Setting the machinefolder property..."
vboxmanage setproperty machinefolder "$HOME/vms/vbox"

printHead "Setting VirtualBox environment variables..."
cat << EOF >> "$myZSHExt"
###############################################################################
###                                VirtualBox                               ###
###############################################################################
export VBOX_USER_HOME="\$HOME/vms/vbox"

EOF


####---
#### Install the latest version of VMware Fusion
#### Using older versions of Fusion on current macOS never seems to work.
####---
#printHead "Installing VMware Fusion..."
#brew install --cask vmware-fusion
#
####---
#### VMware configurations
####---
#printHead "Configuring VMware..."
#cat << EOF >> "$myZSHExt"
################################################################################
####                                  VMware                                 ###
################################################################################
#export VMWARE_STORAGE="\$HOME/vms/vmware"
#
#EOF


###----------------------------------------------------------------------------
### Useful System Utilities
###----------------------------------------------------------------------------
printReq  "Installing system-admin utilities..."
printHead "Some networking and convenience stuff..."
brew install \
    nmap rsync ssh-copy-id watch tree pstree psgrep                \
    sipcalc whatmask ipcalc dos2unix testdisk tcpdump tmux         \
    cfssl libressl
    #sshfs openssl


### open libressl to the system
sudo sed -i "\|/usr/local/bin|i " "$sysPaths"

### Seperate installs for programs with options
#printHead "Installing tcl-tk with options..."
#brew install tcl-tk
#
### Include path for tcl-tk
#printHead "Opening up /usr/local/opt/tcl-tk/bin so we can see tcl..."
#sudo sed -i "\|/usr/bin|i /usr/local/opt/tcl-tk/bin" "$sysPaths"
#
#printHead "Installing tcpdump with options..."
#brew install tcpdump
#
#printHead "Installing tmux with options..."
#brew install tmux
#
### Include path for tcpdump
#printHead "Opening up /usr/local/sbin so we can see tcpdump..."
#sudo sed -i "\|/usr/bin|i /usr/sbin/tcpdump" "$sysPaths"


###----------------------------------------------------------------------------
### RUST
###----------------------------------------------------------------------------
printReq "Installing Rust..."
brew install rust

printHead "Configuring the Rust path..."
sudo sed -i "\|/usr/local/bin|i \$HOME/.cargo/bin" "$sysPaths"


printHead "Configuring Rust..."
cat << EOF >> "$myZSHExt"
###############################################################################
###                                   Rust                                  ###
###############################################################################
source \$HOME/.cargo/env

EOF


####----------------------------------------------------------------------------
#### Ruby
####----------------------------------------------------------------------------
#printReq "Installing Ruby..."
#brew install ruby chruby
#
#
####---
#### Update/Install Gems
####---
#printHead "Updating all Gems..."
#gem update
#
#
#printHead "Configuring the path..."
#sudo sed -i "\|/usr/local/bin|i /usr/local/opt/ruby/bin" "$sysPaths"
#
#
#printHead "Configuring Ruby..."
#cat << EOF >> "$myZSHExt"
################################################################################
####                                   Ruby                                  ###
################################################################################
##source /usr/local/opt/chruby/share/chruby/chruby.sh
##source /usr/local/opt/chruby/share/chruby/auto.sh
#
#EOF


###----------------------------------------------------------------------------
### Install Build Utilities
###----------------------------------------------------------------------------
printReq "Installing build utilities..."
# cmake with completion requires (python) sphinx-doc
brew install cmake bazel


##----------------------------------------------------------------------------
## golang
##----------------------------------------------------------------------------
printReq "Installing the Go Programming Language..."
brew install go dep

# Create the code path
printHead "Creating the \$GOPATH directory..."
export GOPATH="$HOME/go"
mkdir -p "$GOPATH"

printHead "Configuring Go..."
cat << EOF >> "$myZSHExt"
###############################################################################
###                                    Go                                   ###
###############################################################################
export GOPATH="\$HOME/go"
alias mygo="cd \$GOPATH"

EOF

###---
### Go bins
### Until there is some consistency we'll move compiled go binaries elsewhere
###---
goBins='/opt/go-bins'
printHead "Opening up $goBins so we can see local go programs..."
sudo mkdir -p "$goBins"

# Open go-bins up to the system
sudo sed -i "\|/usr/bin|i       $goBins"                 "$sysPaths"
sudo sed -i "\|/usr/local/bin|i $gnuPath/libexec/gnubin" "$sysPaths"


###----------------------------------------------------------------------------
### nodejs and npm
###----------------------------------------------------------------------------
printReq "Installing the Node.js and npm..."
brew install node

### install/configure yarn
brew install yarn
yarn global add yarn


printHead "Configuring npm..."
cat << EOF >> "$myZSHExt"
###############################################################################
###                                  npm                                    ###
###############################################################################

EOF


###----------------------------------------------------------------------------
### Vim: The Power and the Glory
###----------------------------------------------------------------------------
printReq "Upgrading to full-blown Vim..."

### Verify before install
printHead "Checking Apple's Vim..."
vim --version | grep  -E --color 'VIM|Compiled|python|ruby|perl|tcl'

# Install Vim with support for:
#   Use this version over the system one
#   w/o NLS (National Language Support)
#   +Python   (v3; default)
#   +Ruby     (default)
#   +Lua      (broke)
#   +mzscheme (broke)


printHead "Installing Vim..."
#brew install luarocks
brew install vim neovim


printHead "Configuring Vim..."
cat << EOF >> "$myZSHExt"
###############################################################################
###                                   Vim                                   ###
###############################################################################
export EDITOR="$(type -P vim)"
alias -g vi="\$EDITOR"

EOF

### Verify after install
printHead "The Real version of Vim:"
vim --version | grep  -E --color 'VIM|Compiled|python|ruby|perl|tcl'


###----------------------------------------------------------------------------
### Amazon AWS CLI
###----------------------------------------------------------------------------
printReq "Installing the AWS CLI and some Utilities..."
brew install jq jid


### install aws aliases: https://github.com/awslabs/awscli-aliases
git clone git@github.com:awslabs/awscli-aliases.git /tmp/awscli-aliases
mkdir -p "$HOME/.aws/cli"
cp /tmp/awscli-aliases/alias "$HOME/.aws/cli/alias"


### install amazon-ecr-credential-helper FIXME
brew install docker-credential-helper-ecr


printHead "Configuring the AWS CLI..."
cat << EOF >> "$myZSHExt"
###############################################################################
###                                 Amazon                                  ###
###############################################################################
source /usr/local/bin/aws_zsh_completer.sh
complete -C "\$(type -P aws_completer)" aws
#export AWS_REGION='yourRegion'
#export AWS_PROFILE='awsUser'
export AWS_CONFIG_FILE="\$HOME/.aws/config"

EOF

printHead "Setting the AWS User to your local account name..."
sed -i "/AWS_PROFILE/ s/awsUser/${USER}/g" "$myZSHExt"

#### Restore the AWS configs if there are any                   misguided
#if [[ ! -d "$myBackups" ]]; then
#    printInfo "There are no AWS settings to restore."
#else
#    printInfo "Restoring AWS directory..."
#    rsync -aEv "$myBackups/.aws" "$HOME/"
#    sudo chown -R "$USER:$myGroup" "$HOME/.aws"
#fi


###----------------------------------------------------------------------------
### Add a space for common remote access tokens
###----------------------------------------------------------------------------
printReq "Configuring Access Tokens for Remote services..."
cat << EOF >> "$myZSHExt"
###############################################################################
###                             Remote Access                               ###
###############################################################################
# Homebrew / Github
#export HOMEBREW_GITHUB_API_TOKEN=''

EOF


###----------------------------------------------------------------------------
### HashiCorp: Terraform
###----------------------------------------------------------------------------
printHead "Installing tfenv..."
brew install tfenv graphviz

printHead "Configuring Terraform..."
cat << EOF >> "$myZSHExt"
###############################################################################
###                                Terraform                                ###
###############################################################################
alias tf="\$(command -v terraform)"
complete -o nospace -C /usr/local/bin/terraform tf
export TF_VAR_AWS_PROFILE="\$AWS_PROFILE"
export TF_LOG='TRACE'
export TF_LOG_PATH='/tmp/terraform.log'

EOF


###----------------------------------------------------------------------------
### HashiCorp: Packer
###----------------------------------------------------------------------------
printReq "Installing Packer..."
#brew install hashicorp/tap/packer
#brew install packer-completion

printHead "Configuring Packer..."
cat << EOF >> "$myZSHExt"
###############################################################################
###                                  Packer                                 ###
###############################################################################
complete -o nospace -C /usr/local/bin/packer packer
export PACKER_HOME="\$HOME/vms/packer"
export PACKER_CONFIG="\$PACKER_HOME"
export PACKER_CACHE_DIR="\$PACKER_HOME/iso-cache"
export PACKER_BUILD_DIR="\$PACKER_HOME/builds"
export PACKER_LOG='yes'
export PACKER_LOG_PATH='/tmp/packer.log'
export PACKER_NO_COLOR='yes'

EOF


###----------------------------------------------------------------------------
### Docker
###----------------------------------------------------------------------------
printReq "Installing Docker, et al..."
### Includes completion
brew install --cask docker
brew install docker-compose docker-completion docker-clean \
    docker-credential-helper hyperkit


printHead "Configuring Docker..."
cat << EOF >> "$myZSHExt"
###############################################################################
###                                 DOCKER                                  ###
###############################################################################

EOF


###----------------------------------------------------------------------------
### Install Kubernetes-related packages
###----------------------------------------------------------------------------
printReq "Installing Kubernetes-related packages..."


### Includes completion
brew install kubernetes-cli helm kind istioctl derailed/k9s/k9s eksctl \
    minikube datawire/blackbird/telepresence


###----------------------------------------------------------------------------
### Configure some sensible minikube defaults
###----------------------------------------------------------------------------
printInfo "minikube set defaults"
minikube config set cpus 2
minikube config set memory 4096
minikube config set driver hyperkit
minikube config set WantVirtualBoxDriverWarning false

printInfo "minikube get defaults"
cat ~/.minikube/config/config.json


###----------------------------------------------------------------------------
### install Krew plugins
###----------------------------------------------------------------------------
brew tap robscott/tap
brew install krew robscott/tap/kube-capacity


###----------------------------------------------------------------------------
### Install ktx; clone the ktx repo
###----------------------------------------------------------------------------
git clone https://github.com/heptiolabs/ktx /tmp/ktx
cd /tmp/ktx || exit

### Install the bash function
cp ktx "${HOME}/.ktx"

### Add this to your "${HOME}/".bash_profile (or similar)
source "${HOME}/.ktx"

### Install the auto-completion
cp ktx-completion.sh "${HOME}/.ktx-completion.sh"

### Add this to your "${HOME}/".bash_profile (or similar)
source "${HOME}/.ktx-completion.sh"


###----------------------------------------------------------------------------
### Install the weird stuff here
###----------------------------------------------------------------------------
kubeSSH='/tmp/kubectl-ssh'
curl -o "$kubeSSH" \
    -O https://raw.githubusercontent.com/luksa/kubectl-plugins/master/kubectl-ssh
chmod +x "$kubeSSH"
mv "$kubeSSH" /usr/local/bin/
command -v kubectl-ssh


printReq "Configuring kubectl, helm, et al..."
cat << EOF >> "$myZSHExt"
###############################################################################
###                              KUBERNETES                                 ###
###############################################################################
#alias kube='/usr/local/bin/kubectl'
#source <(kubectl  completion bash | sed 's/kubectl/kube/g')
#source <(minikube completion bash)
# --------------------------------------------------------------------------- #
export HELM_HOME="\$HOME/.helm"
#source <(helm     completion bash)
# --------------------------------------------------------------------------- #
source "\${HOME}/.ktx-completion.sh"
source "\${HOME}/.ktx"

EOF


###----------------------------------------------------------------------------
### Install the CoreOS Operator SDK
###----------------------------------------------------------------------------
printReq "Installing the CoreOS Operator SDK..."
brew install operator-sdk


###----------------------------------------------------------------------------
### Install confd https://github.com/kelseyhightower/confd
###----------------------------------------------------------------------------
printReq "Installing confd..."
confdDir="$GOPATH/src/github.com/kelseyhightower/confd"

### pull the latest code
git clone https://github.com/kelseyhightower/confd.git "$confdDir"
cd "$confdDir" || exit
go mod init
go mod tidy
go mod vendor

if ! make build; then
    printInfo "There was a build issue with confd."
else
    make install
fi

### head back home
cd "$workDir" || exit


###----------------------------------------------------------------------------
### Install Google Cloud Platform client
###----------------------------------------------------------------------------
printReq "Installing the Google Cloud SDK..."
### Includes completion
brew install --cask google-cloud-sdk


printReq "Configuring the Google Cloud SDK..."
cat << EOF >> "$myZSHExt"
###############################################################################
###                        Google Cloud Platform                            ###
###############################################################################
source "/usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/path.zsh.inc"
source "/usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/completion.zsh.inc"
 --------------------------------------------------------------------------- #

EOF


###----------------------------------------------------------------------------
### Configure Vim
###----------------------------------------------------------------------------
printReq "Pulling the vimSimple repo..."
git clone --recursive -j10 "$vimSimpleGitRepo" "$vimSimpleLocal"


###----------------------------------------------------------------------------
### Modify 1-off configurations on current submodules
####---
printHead "Making 1-off configuration changes..."
### python-mode: disable: 'pymode_rope'
printHead "Disabling pymode_rope..."
printInfo "Check Value before change:"
ropeBool="$(grep "('g:pymode_rope', \w)$" "$pymodConfig")"
ropeBool="${ropeBool:(-2):1}"
if [[ "$ropeBool" -ne '0' ]]; then
    printInfo "Value is $ropeBool, Changing the value to Zero..."
    sed -i "/'g:pymode_rope', 1/ s/1/0/g" "$pymodConfig"
    sed -i "/'g:pymode_rope', 0/i $vimSimpleTag" "$pymodConfig"
else
    printInfo "Value is already Zero"
    grep "('g:pymode_rope', \w)$" "$pymodConfig"
fi

### Print the value for logging
printHead "The pymode_rope plugin is disabled:"
grep "('g:pymode_rope', \w)$" "$pymodConfig"


###---
### json-vim: add: 'autocmd' to the top of the file
###---
sed -i "/$jsonIndREGEX/a $jsonAppendStr" "$jsonIndent"

### json-vim: add a space seperator
sed -i "/$jsonIndREGEX/G" "$jsonIndent"

### json-vim: add: tag as vimSimple configuration
sed -i "/${jsonAppendStr%%\ *}/i $vimSimpleTag" "$jsonIndent"

### Make softlinks to the important files
printHead "Creating softlinks for ~/.vim and ~/.vimrc"
ln -s "$vimSimpleLocal/vimrc" ~/.vimrc
ln -s "$vimSimpleLocal/vim" ~/.vim

ls -dl ~/.vimrc ~/.vim


###----------------------------------------------------------------------------
### Nvim Configurations
###----------------------------------------------------------------------------
printReq  "Neovim post-install configurations:"
printHead "Saving default \$TERM details > ~/config/term/..."
mkdir "$termDir"
infocmp "$TERM" > "$termDir/$TERM.ti"
infocmp "$TERM" | sed 's/kbs=^[hH]/kbs=\\177/' > "$termDir/$TERM-nvim.ti"

printHead "Compiling terminfo for Neovim warning..."
tic "$termDir/$TERM-nvim.ti"

printHead "Linking to existing .vim directory..."
ln -s "$vimSimpleLocal/vim" "$nvimDir"

printHead "Linking to existing .vimrc file..."
ln -s "$vimSimpleLocal/vimrc" "$nvimDir/init.vim"


###----------------------------------------------------------------------------
### Configure The macOS
###----------------------------------------------------------------------------
### Configure the System
###---
printReq "Configuring the System:"


###---
###  Set the hostname(s)
###---
if [[ "$myMBPisFor" == 'personal' ]]; then
    printHead "Configuring the hostname(s)..."
    ### Configure the network hostname
    printInfo "Configuring network hostname..."
    sudo scutil --set ComputerName "$myHostName"

    ### Configure the Terminal hostname
    printInfo "Configuring Terminal hostname..."
    sudo scutil --set HostName "${myHostName%%.*}"

    ### Configure the AirDrop hostname
    printInfo "Configuring AirDrop hostname..."
    sudo scutil --set LocalHostName "${myHostName%%.*}"
fi


###---
### Storage
###---
printHead "Configuring Storage:"
printInfo "Save to disk by default (not to iCloud)..."
defaults read NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false
defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false


###---
### Disable smart quotes and dashes system-wide
### REF: https://apple.stackexchange.com/a/334572/34436
###---
printHead "Disabling smart quotes and dashes system-wide:"


### Disable smart quotes
printInfo "Disabling smart quotes..."
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false


### Disable smart dashes
printInfo "Disabling smart dashes..."
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false


###----------------------------------------------------------------------------
### The Finder
###----------------------------------------------------------------------------
### Display all folders in List View
###---
printHead "Setting Finder Preferences:"
printInfo "Display all windows in List View..."
defaults write com.apple.finder FXPreferredViewStyle Nlsv


###---
### New window displays home
###---
printInfo "Display the home directory by default..."
defaults write com.apple.finder NewWindowTarget -string "PfLo"
defaults write com.apple.finder NewWindowTargetPath -string "file://${HOME}/"


###---
### Show status bar in Finder
###---
printInfo "Display status bar in Finder..."
defaults write com.apple.finder ShowStatusBar -bool true


###---
### Search the current folder by default
###---
printInfo "Search the current folder by default..."
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"


###---
### Display all file extensions in Finder
###---
printInfo "Display all extensions by default..."
defaults write NSGlobalDomain AppleShowAllExtensions -bool true


###---
### Screenshot behavior
###---
printInfo "Save screenshots to a specified location..."
if [[ ! -d "$dirScreenshot" ]]; then
    mkdir -p "$dirScreenshot"
    defaults write com.apple.screencapture location "$dirScreenshot"
fi


### Create a softlink on the Desktop
if [[ ! -h "$linkScreens" ]]; then
    ln -s "$dirScreenshot" "$linkScreens"
fi


### Set screenshots without window shadows
printInfo "Save screenshots without window shadows..."
defaults write com.apple.screencapture disable-shadow -bool true


###---
### Show battery percentage
###---
printInfo "Show battery percentage..."
 defaults read com.apple.menuextra.battery ShowPercent
defaults write com.apple.menuextra.battery ShowPercent -string 'YES'


###---
### Display Configuration
###---
printInfo "Don't show mirroring options in the menu bar..."
defaults write com.apple.airplay showInMenuBarIfPresent -bool false


###---
### Display Date/Time formatted: 'EEE MMM d  h:mm a'
### This is now a default
###---
printInfo "Display Day HH:MM AM format..."
defaults write com.apple.menuextra.clock 'DateFormat' -string 'EEE MMM d  h:mm a'


###---
### Network Shares
###---
printInfo "Do NOT create .DS_Store files on network volumes..."
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true


###---
### Dialog Box behavior
###---


### The Save Dialog Box
printInfo "Expand Save panel by default..."
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true


### The Print Dialog Box
printInfo "Expand Print panel by default..."
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint2 -bool true


###----------------------------------------------------------------------------
### The Dock
###----------------------------------------------------------------------------
printHead "Setting Dock Preferences:"
printInfo "Display The Dock at 46px..."


### Set default Tile Size to 42px
defaults write com.apple.dock tilesize 42


### Auto-Hide the Dock
printInfo "Auto-hide The Dock..."
defaults write com.apple.dock autohide -bool true


### Optionally: adjust timing with these settings
defaults write com.apple.dock autohide-delay -float 0
defaults write com.apple.dock autohide-time-modifier -float 0


###----------------------------------------------------------------------------
### Configure Basic OS Security
###----------------------------------------------------------------------------
printHead "Configuring Basic OS Security:"


###---
### Disable Guest User at the Login Screen
###---
printInfo "Disable Guest User at the Login Screen..."
sudo defaults write /Library/Preferences/com.apple.loginwindow GuestEnabled -bool NO
 sudo defaults read /Library/Preferences/com.apple.loginwindow GuestEnabled
### OUTPUT: 0


###---
### Apple File Protocol
###---
printInfo "Disable AFP Guest Access..."
defaults write com.apple.AppleFileServer.plist AllowGuestAccess -int 0


###----------------------------------------------------------------------------
### Configure Application Behavior
###----------------------------------------------------------------------------
printHead "Configuring Application Preferences:"


###---
### Stop Photos from opening automatically when plugging in iPhone [TEST]
###---
printInfo "Stop Photos from opening automatically..."
defaults -currentHost write com.apple.ImageCapture disableHotPlug -bool true


###---
### TextEdit
###---
printInfo "TextEdit Preferences: before:"
defaults read com.apple.TextEdit


### Set Author Name
printInfo "Setting author name..."
defaults write com.apple.TextEdit author "$myFullName"


### Use plain text not RichText
printInfo "Use plain text by default..."
defaults write com.apple.TextEdit RichText -int 0


### Set Font
printInfo "We'll use Courier as the font..."
defaults write com.apple.TextEdit NSFixedPitchFont 'Courier'


### Set Font Size
printInfo "Courier is set to 14pt..."
defaults write com.apple.TextEdit NSFixedPitchFontSize -int 14


### Default Window Size
printInfo "New Windows will open at H:45 x W:100..."
defaults write com.apple.TextEdit WidthInChars -int 100
defaults write com.apple.TextEdit HeightInChars -int 45


### Disable SmartDashes and SmartQuotes (defaut)
printInfo "Disabling SmartDashes and SmartQuotes..."
defaults write com.apple.TextEdit SmartDashes -int 0
defaults write com.apple.TextEdit SmartQuotes -int 0


printInfo "TextEdit Preferences: after:"
defaults read com.apple.TextEdit


### move back to the mac-ops directory
cd "$workDir" || exit


###----------------------------------------------------------------------------
### Remove the Github Remote Host Key
###----------------------------------------------------------------------------
printInfo "Removing the $hostRemote public key from our known_hosts file..."
ssh-keygen -f "$knownHosts" -R "$hostRemote"


###----------------------------------------------------------------------------
### Save installed package and library details AFTER the install
###----------------------------------------------------------------------------
printReq "Saving some post-install app/lib details..."
tools/admin-app-details.sh post


### Create a link to the log file
ln -s ~/.config/admin/logs/mac-ops-config.out config-output.log


###----------------------------------------------------------------------------
### Restore Personal Data
###----------------------------------------------------------------------------
#if [[ "$dataRestore" == true ]]; then
#    if [[ ! -d "$myBackups" ]]; then
#        printInfo "There are no Documents to restore."
#    else
#        printInfo "Restoring files..."
#        tools/restore-my-stuff.sh 2> /tmp/rsycn-errors.out
#    fi
#fi


###----------------------------------------------------------------------------
### Some light housework
###----------------------------------------------------------------------------
printReq "Cleaning up a bit..."
brew cleanup


###---
### move this garbage to log directory for posterity
###---
sudo find "$HOME" -type f -name 'AT.postflight*' -exec mv {} "$adminLogs" \;


###---
### Perform some font maintenance
###---
printInfo "Refreshing the Fonts directory..."
atsutil server -ping
sudo atsutil databases -remove
atsutil server -shutdown
atsutil server -ping


###---
### Recover the hosts file from backup
###---
if [[ "$myMBPisFor" == 'personal' ]]; then
    printInfo "Restoring the /etc/hosts file..."
    if [[ ! -f "$sysBackups/etc/hosts" ]]; then
        printInfo "Can't find $sysBackups/etc/hosts"
    else
        printInfo "Restoring the /etc/hosts file..."
        sudo cp "$sysBackups/etc/hosts" /etc/hosts
        sudo chown root:wheel /etc/hosts
    fi
fi


###---
### Ensure ownership of problematic files
###---
printInfo "Ensure correct ownership of ~/.viminfo file..."
if [[ -f ~/.viminfo ]]; then
    sudo chown "$USER:$myGroup" ~/.viminfo
fi


###---
### Make the config live; preserve the original for future comparisons
###---
printInfo "Copy ~/.config/shell/environment.zsh to ~/.oh-my-zsh/custom..."
cp -f "$myZSHExt" "$myShellEnv"


###----------------------------------------------------------------------------
### Announcements
###----------------------------------------------------------------------------
printf '\n\n%s\n' """
###############################################################################
#                         POST-INSTALL INSTRUCTIONS                           #
###############################################################################
"""
printf '\n%s\n' """
    1) The AWS client profile:
            Use this guide to setup your AWS cli profile:
            https://github.com/todd-dsm/mac-ops/wiki/Install-awscli
            * If you already had this setup then these settings have already
            been restored to ~/.aws/

    2) Sidebar elements have been added but I still haven't figured out how to
       remove stuff; customize this to your tastes:
       Finder > Preferences: Sidebar.

    3) You still have to open System Preferences and verify your settings. I
       can't see any other way to set these preference than the manual way.

    4) If build is PERSONAL, verify data restoration:
         a) Check for any data restore errors by:
            less /tmp/rsycn-errors.out
         b) Check for any data that is not owned by you:
            less /tmp/find-out.log

    That's basically it. Now get back to work :-)


"""


###----------------------------------------------------------------------------
### Quick and Dirty duration
###----------------------------------------------------------------------------
# we can't read /etc/paths until the next login; set date location
timePost=$(date +'%T')
### Convert time to a duration
startTime=$(date -u -d "$timePre"  +"%s")
  endTime=$(date -u -d "$timePost" +"%s")
procDur="$(date -u -d "0 $endTime sec - $startTime sec" +"%H:%M:%S")"
printf '%s\n' """
    Process start at: $timePre
    Process end   at: $timePost
    Process duration: $procDur
"""


###----------------------------------------------------------------------------
### Fin~
###----------------------------------------------------------------------------
printInfo

