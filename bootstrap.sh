#!/usr/bin/env bash
# shellcheck disable=SC1090,SC1091,SC2059,SC2154,SC2116,SC1117
# FIXME: SC1117
#------------------------------------------------------------------------------
# PURPOSE:  A QnD script to configure a base environment so I can get back to
#           work quickly. It will be replaced by Ansible automation as soon as
#           possible between laptop upgrades.
#------------------------------------------------------------------------------
# EXECUTE:  ./bootstrap.sh TEST 2>&1 | tee ~/.config/admin/logs/mac-ops-config.out
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
: "${1?  Wheres my environment, bro!}"
theENV="$1"
workDir="${PWD}"

if [[ "$theENV" == 'TEST' ]]; then
    # We're either testing or we aint
    echo "THIS IS ONLY A TEST"
    sleep 2s
else
    echo "We are preparing to going live..."
    sleep 3s
fi


source './my-vars.env' "$theENV"
timePre="$(date +'%T')"
myGroup="$(id -g)"

###----------------------------------------------------------------------------
### FUNCTIONS
###----------------------------------------------------------------------------
### Print stuff of greatest importance: Requirements
###---
printReq() {
    theReq="$1"
    printf '\e[1;34m%-6s\e[m' """
$theReq
"""
}

###---
### Print stuff of secondary importance: Headlines
###---
printHead() {
    theHead="$1"
    printf '%s' """
  $theHead
"""
}

###---
### Print stuff of tertiary importance: Informational
###---
printInfo() {
    theInfo="$1"
    printf '%s\n' """
    $theInfo
"""
}

###---
### Print Requirement
###---
getNewPaths() {
    declare PATH=''
    ### Construct new paths
    printReq "Constructing the \$PATH environment variable..."
    while IFS= read -r binPath; do
        printHead "Adding: $binPath"
        if [[ -z "$myPath" ]]; then
           "myPath=$binPath"
       else
           myPath="$myPath:$binPath"
        fi
    done < "$sysPaths"

    export PATH="$myPath"


    ### Construct new manpaths
    printReq "Constructing the \$MANPATH environment variable..."
    while IFS= read -r manPath; do
        printHead "Adding: $manPath"
        if [[ -z "$myMans" ]]; then
           "myMans=$manPath"
       else
           myMans="$myMans:$manPath"
        fi
    done < "$sysManPaths"

    export MANPATH="$myMans"
}


###----------------------------------------------------------------------------
### The Setup
###----------------------------------------------------------------------------
### Add the Github key to the knownhosts file
###---
printReq  "Checking to see if we have the Github public key..."
if ! grep "^$hostRemote" "$knownHosts" > /dev/null 2>&1; then
    printHead "We don't, pulling it now..."
    ssh-keyscan -t 'rsa' "$hostRemote" >> "$knownHosts"
else
    printHead "We have the Github key, all good."
fi

###---
### Backup some files before we begin
###---
if [[ "$theENV" == 'TEST' ]]; then
    printReq "Backing up the /etc directory before we begin..."
    sudo rsync -aE /private/etc "$backupDir/" 2> /tmp/rsync-err-etc.out
fi

###---
### Pull some stuff for the Terminal
###---
printReq "Pulling Terminal stuff..."
git clone "$solarizedGitRepo" "$termStuff/solarized" > /dev/null 2>&1

# Pull the settings back
if [[ ! -d "$myBackups" ]]; then
    printHead "There are no 'settings' to restore."
else
    printHead "Restoring Terminal (and other) settings..."
    rsync -aEv  "$myBackups/Documents/system" "$myDocs/" 2> /tmp/rsync-err-system.out
fi


################################################################################
####                                  System                                 ###
################################################################################
### Display some defaults for the log
###---
printHead "Default macOS paths:"
printInfo "System Paths:"
cat "$sysPaths"
printInfo "\$PATH=$PATH"

printHead "System man paths:"
cat "$sysManPaths"
if [[ -z "$MANPATH" ]]; then
    # at this stage it's always empty
    printInfo "The MANPATH Environmental Variable is empty!"
else
    printInfo "\$MANPATH=$MANPATH"
fi


####----------------------------------------------------------------------------
#### Install the font: Hack
#### https://github.com/Homebrew/homebrew-cask-fonts
####----------------------------------------------------------------------------
#printHead "Installing font: Hack..."
#brew tap homebrew/cask-fonts
#brew install font-hack
#
#
####----------------------------------------------------------------------------
#### Let's Get Open: Install GNU Programs
####----------------------------------------------------------------------------
#printReq "Let's get open..."
#paramsFile="${sourceDir}/gnu-programs.list"
#gnuProgs=()
#
## Read list of programs from a file
#set -x
#while read -r gnuProgram; do
#    # install program
#    brew install "$gnuProgram"
#    # send name to gnuProgs array
#    gnuProgs+=("$gnuProgram")
#done < "$paramsFile"
#
#
####---
#### Add paths for all elements in the gnuProgs array
####---
#gnuSed='/usr/local/opt/gnu-sed/libexec/gnubin/sed'
#
#printf '\n\n%s\n' "Adding paths for new GNU programs..."
#for myProg in "${gnuProgs[@]}"; do
#    gnuPath="$(brew --prefix "$myProg")"
#    printf '%s\n' "  $gnuPath"
#    sudo "$gnuSed" -i "\|/usr/local/bin|i $gnuPath/libexec/gnubin" "$sysPaths"
#done
#
#
## Move system manpaths down 1 line
#sudo "$gnuSed" -i -n '2{h;n;G};p' "$sysManPaths"
#
#### Add manpaths for the GNU Manuals
#printf '\n\n%s\n' "Adding manpaths for new GNU manuals..."
#for myProg in "${gnuProgs[@]}"; do
#    gnuPath="$(brew --prefix "$myProg")"
#    printf '%s\n' "  $gnuPath"
#    sudo "$gnuSed" -i "\|/usr/share/man|i $gnuPath/libexec/gnuman" "$sysManPaths"
#done
#
#
####----------------------------------------------------------------------------
#### PATHs
####   * System:  /usr/bin:/bin:/usr/sbin:/sbin
####   * Homebrew: anything under /usr/local
####----------------------------------------------------------------------------
#printHead "The new paths:"
#printInfo "\$PATH:"
#cat "$sysPaths"
#printInfo "$PATH"
#
#
####----------------------------------------------------------------------------
#### MANPATHs
####   * System:   /usr/share/man
####   * Homebrew: /usr/local/share/man
####----------------------------------------------------------------------------
#printHead "\$MANPATH: (available after next login)"
#cat "$sysManPaths"
#
#if [[ -z "$MANPATH" ]]; then
#    printInfo "Current MANPATH is empty!"
#else
#    printInfo "\$MANPATH=$MANPATH"
#fi
#
#
#### Configure coreutils                                FIX LATER WITH ALIASES
#printHead "Configuring GNU Coreutils..."
#cp sources/{aliases,functions}.zsh "$myShellDir"
#
#
####---
#### RESET TEST ENVIRONMEN
####---
##if [[ "$theENV" == 'TEST' ]]; then
##    sudo cp ~/.config/admin/backup/etc/paths /etc/paths
##    sudo cp ~/.config/admin/backup/etc/manpaths /etc/manpaths
##fi
#
#
####----------------------------------------------------------------------------
### Install the Casks (GUI Apps)
###----------------------------------------------------------------------------
printReq "Installing GUI (cask) Apps..."
printHead "Installing Utilities..."
brew install --cask \
    google-chrome visual-studio-code intellij-idea-ce  \
    virtualbox virtualbox-extension-pack wireshark

exit
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


###---
### Install the latest version of VMware Fusion
### Using older versions of Fusion on current macOS never seems to work.
###---
printHead "Installing VMware Fusion..."
brew install --cask vmware-fusion

###---
### VMware configurations
###---
printHead "Configuring VMware..."
cat << EOF >> "$myZSHExt"
###############################################################################
###                                  VMware                                 ###
###############################################################################
export VMWARE_STORAGE="\$HOME/vms/vmware"

EOF

#tail -10 "$myShellrc"


###----------------------------------------------------------------------------
### Useful System Utilities
###----------------------------------------------------------------------------
printReq "Installing system-admin utilities..."
printHead "Some networking and convenience stuff..."
brew install \
    nmap rsync openssl ssh-copy-id watch tree pstree psgrep                 \
    sipcalc whatmask ipcalc dos2unix testdisk tcpdump tmux
    #openssh sshfs

### Seperate installs for programs with options
#printHead "Installing tcl-tk with options..."
#brew install tcl-tk

### Include path for tcl-tk
#printHead "Opening up /usr/local/opt/tcl-tk/bin so we can see tcl..."
#sudo sed -i "\|/usr/bin|i /usr/local/opt/tcl-tk/bin" "$sysPaths"

#printHead "Installing tcpdump with options..."
#brew install tcpdump

#printHead "Installing tmux with options..."
#brew install tmux

### Include path for tcpdump
#printHead "Opening up /usr/local/sbin so we can see tcpdump..."
#sudo sed -i "\|/usr/bin|i /usr/sbin/tcpdump" "$sysPaths"


###----------------------------------------------------------------------------
### RUST
###----------------------------------------------------------------------------
printReq "Installing Rust..."
brew install rust

printHead "Configuring the path..."
sudo "$gnuSed" -i "\|/usr/local/bin|i \$HOME/.cargo/bin" "$sysPaths"


printHead "Configuring Rust..."
cat << EOF >> "$myZSHExt"
###############################################################################
###                                   Rust                                  ###
###############################################################################
#source $HOME/.cargo/env

EOF


###----------------------------------------------------------------------------
### PYTHON
###----------------------------------------------------------------------------
printReq "Installing Python..."
brew install python

printHead "Upgrading Python Pip and setuptools..."
pip3 install --upgrade pip setuptools wheel
pip3 install --upgrade ipython simplejson requests boto Sphinx

printHead "Configuring the path..."
sudo "$gnuSed" -i "\|/usr/local/bin|i $(brew --prefix)/opt/python/libexec/bin" "$sysPaths"

printHead "Configuring Python..."
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
printReq "Configuring pip..."
printHead "Creating pip home..."
if [[ ! -d "$configDir/python" ]]; then
    mkdir -p "$configDir/python"
fi

printHead "Creating the pip config file..."
cat << EOF > "$configDir/python/pip.conf"
# pip configuration
[list]
format=columns

EOF

###---
### Configure autoenv
###---
printHead "Configuring autoenv..."

printHead "Creating the autoenv file..."
touch "$configDir/python/autoenv_authorized"

# Source-in and Display changes
#printHead "python ~/.bashrc changes:"
#source "$myShellProfile" && tail -5 "$myShellrc"

printInfo "Testing pip config..."
pip3 list


###----------------------------------------------------------------------------
### Ruby
###----------------------------------------------------------------------------
printReq "Installing Ruby..."
brew install ruby chruby

###---
### Update/Install Gems
###---
printHead "Updating all Gems..."
gem update "$(gem list | cut -d' ' -f1)"

printHead "Configuring the path..."
sudo "$gnuSed" -i "\|/usr/local/bin|i /usr/local/opt/ruby/bin" "$sysPaths"


printHead "Configuring Ruby..."
cat << EOF >> "$myZSHExt"
###############################################################################
###                                   Ruby                                  ###
###############################################################################
#source /usr/local/opt/chruby/share/chruby/chruby.sh
#source /usr/local/opt/chruby/share/chruby/auto.sh

EOF

# Source-in and Display changes
#printInfo "ruby ~/.bashrc changes:"
#source "$myShellProfile" && tail -6 "$myShellrc"


###----------------------------------------------------------------------------
### Install Build Utilities
###----------------------------------------------------------------------------
printReq "Installing build utilities..."
# cmake with completion requires (python) sphinx-doc
brew install cmake bazel


###----------------------------------------------------------------------------
### golang
###----------------------------------------------------------------------------
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

# Source-in and Display changes
#printInfo "golang ~/.bashrc changes:"
#source "$myShellProfile" && tail -6 "$myShellrc"

###---
### Go bins
### Until there is some consistency we'll move compiled go binaries elsewhere
###---
goBins='/opt/go-bins'
printHead "Opening up $goBins so we can see local go programs..."
sudo mkdir -p "$goBins"

# Open go-bins up to the system
sudo "$gnuSed" -i "\|/usr/bin|i       $goBins"                 "$sysPaths"
sudo "$gnuSed" -i "\|/usr/local/bin|i $gnuPath/libexec/gnubin" "$sysPaths"


###----------------------------------------------------------------------------
### Bash
###----------------------------------------------------------------------------
#printf '\n%s\n' "Installing Bash..."
#brew install bash shellcheck dash bash-completion@2
#
## Configure GNU Bash for the system and current $USER
#printReq "Configuring Bash..."
#
#printHead "Creating a softlink from sh to dash..."
#ln -sf '/usr/local/bin/dash' '/usr/local/bin/sh'
#
#printHead "System Shells default:"
#grep '^\/' "$sysShells"
#sudo sed -i "\|^.*bash$|i /usr/local/bin/bash" "$sysShells"
#sudo sed -i "\|local|a /usr/local/bin/sh" "$sysShells"
#printHead "System Shells new:"
#grep '^\/' "$sysShells"
#
## Switch to GNU Bash
#currentShell="$(dscl . -read "$HOME" UserShell)"
#
#if [[ "${currentShell##*\ }" != "$(type -P bash)" ]]; then
#    printHead "$USER's shell is: ${currentShell##*\ }"
#    printHead "Changing default shell to GNU Bash"
#    sudo chpass -s "$(type -P bash)" "$USER"
#    dscl . -read "$HOME" UserShell
#else
#    printHead "Default shell is already GNU Bash"
#fi
#
#cat << EOF >> "$myZSHExt"
################################################################################
####                                   Bash                                  ###
################################################################################
#export SHELL='/usr/local/bin/bash'
## ShellCheck: Ignore: https://goo.gl/n9W5ly
#export SHELLCHECK_OPTS="-e SC2155"
#
#EOF
#
## Source-in and Display changes
#printInfo "bash ~/.bashrc changes:"
#source "$myShellProfile" > /dev/null 2>&1 && tail -8 "$myShellrc"


###----------------------------------------------------------------------------
### nodejs and npm
###----------------------------------------------------------------------------
printReq "Installing the Node.js and npm..."
brew install node

# install/configure yarn
brew install yarn
yarn global add yarn


printHead "Configuring npm..."
cat << EOF >> "$myZSHExt"
###############################################################################
###                                  npm                                    ###
###############################################################################

EOF

# Source-in and Display changes
#printInfo "npm ~/.bashrc changes:"
#source "$myShellProfile" > /dev/null 2>&1 && tail -5 "$myShellrc"

###---
### install yarn packages
###---
# yeoman
#yarn add yo


###----------------------------------------------------------------------------
### Vim: The Power and the Glory
###----------------------------------------------------------------------------
printReq "Upgrading to full-blown Vim..."

# Verify before install
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
echo "ignore: Error: Vim will not link against both Luajit & Lua message"


printHead "Configuring Vim..."
cat << EOF >> "$myZSHExt"
###############################################################################
###                                   Vim                                   ###
###############################################################################
export EDITOR="$(type -P vim)"
alias -g vi="\$EDITOR"

EOF

# Source-in and Display changes
#printInfo "vim ~/.bashrc changes:"
#source "$myShellProfile" > /dev/null 2>&1 && tail -8 "$myShellrc"


# Verify after install
printHead "The Real version of Vim:"
vim --version | grep  -E --color 'VIM|Compiled|python|ruby|perl|tcl'


###----------------------------------------------------------------------------
### Amazon AWS CLI
###----------------------------------------------------------------------------
printReq "Installing the AWS CLI and some Utilities..."
pip3 install awscli jmespath jmespath-terminal
brew tap jmespath/jmespath
brew install jp jq jid

# install aws aliases: https://github.com/awslabs/awscli-aliases
git clone git@github.com:awslabs/awscli-aliases.git /tmp/awscli-aliases
mkdir -p "$HOME/.aws/cli"
cp /tmp/awscli-aliases/alias "$HOME/.aws/cli/alias"

# install amazon-ecr-credential-helper
go get -u github.com/awslabs/amazon-ecr-credential-helper/ecr-login/cli/docker-credential-ecr-Login
# take it home
if [[ -f "$HOME/go/bin/docker-credential-ecr-login" ]]; then
    sudo mv "$HOME/go/bin/docker-credential-ecr-login" "$goBins"
fi

printHead "Configuring the AWS CLI..."
cat << EOF >> "$myZSHExt"
###############################################################################
###                                 Amazon                                  ###
###############################################################################
#source /usr/local/bin/aws_zsh_completer.sh
#complete -C "\$(type -P aws_completer)" aws
#export AWS_REGION='yourRegion'
#export AWS_PROFILE='awsUser'
export AWS_CONFIG_FILE="\$HOME/.aws/config"

EOF

printHead "Setting the AWS User to your local account name..."
"$gnuSed" -i "/AWS_PROFILE/ s/awsUser/${USER}/g" "$myZSHExt"

# Restore the AWS configs if there are any
if [[ ! -d "$myBackups" ]]; then
    printInfo "There are no AWS settings to restore."
else
    printInfo "Restoring AWS directory..."
    rsync -aEv "$myBackups/.aws" "$HOME/"
    sudo chown -R "$USER:$myGroup" "$HOME/.aws"
fi

# Source-in and Display changes
#printInfo "aws ~/.bashrc changes:"
#source "$myShellProfile" > /dev/null 2>&1 && tail -7 "$myShellrc"


###----------------------------------------------------------------------------
### Add a space for common remote access tokens
###----------------------------------------------------------------------------
printReq "Configuring Access Tokens for Remote services..."
cat << EOF >> "$myZSHExt"
###############################################################################
###                             Remote Access                               ###
###############################################################################
# HashiCorp Atlas
export ATLAS_TOKEN=''
# Homebrew / Github
export HOMEBREW_GITHUB_API_TOKEN=''

EOF

# Source-in and Display changes
#printInfo "token ~/.bashrc changes:"
#source "$myShellProfile" > /dev/null 2>&1 && tail -8 "$myShellrc"


###----------------------------------------------------------------------------
### HashiCorp: Terraform
###----------------------------------------------------------------------------
printHead "Installing Terraform..."
brew install hashicorp/tap/terraform
brew install graphviz

printHead "Configuring Terraform..."
cat << EOF >> "$myZSHExt"
###############################################################################
###                                Terraform                                ###
###############################################################################
alias tf="\$(whence -p terraform)"
complete -o nospace -C /usr/local/bin/terraform tf
export TF_VAR_AWS_PROFILE="\$AWS_PROFILE"
export TF_LOG='TRACE'
export TF_LOG_PATH='/tmp/terraform.log'

EOF


# Source-in and Display changes
#printInfo "terraform ~/.bashrc changes:"
#source "$myShellProfile" > /dev/null 2>&1 && tail -9 "$myShellrc"


###----------------------------------------------------------------------------
### HashiCorp: Packer
###----------------------------------------------------------------------------
printReq "Installing Packer..."
brew install hashicorp/tap/packer
brew install packer-completion

printHead "Configuring Packer..."
cat << EOF >> "$myZSHExt"
###############################################################################
###                                  Packer                                 ###
###############################################################################
export PACKER_HOME="\$HOME/vms/packer"
export PACKER_CONFIG="\$PACKER_HOME"
export PACKER_CACHE_DIR="\$PACKER_HOME/iso-cache"
export PACKER_BUILD_DIR="\$PACKER_HOME/builds"
export PACKER_LOG='yes'
export PACKER_LOG_PATH='/tmp/packer.log'
export PACKER_NO_COLOR='yes'

EOF

# Source-in and Display changes
#printInfo "packer ~/.bashrc changes:"
#source "$myShellProfile" > /dev/null 2>&1 && tail -10 "$myShellrc"


###----------------------------------------------------------------------------
### HashiCorp: Vagrant
###----------------------------------------------------------------------------
#printReq "Installing Vagrant..."
#brew install --cask vagrant
#brew install vagrant-completion
#
#printHead "Configuring Vagrant..."
#cat << EOF >> "$myShellrc"
################################################################################
####                                 Vagrant                                 ###
################################################################################
##export VAGRANT_LOG=debug
#export VAGRANT_HOME="\$HOME/vms/vagrant"
#export VAGRANT_BOXES="\$VAGRANT_HOME/boxes"
#export VAGRANT_DEFAULT_PROVIDER='virtualbox'
#
#EOF
#
# Source-in and Display changes
#printInfo "vagrant ~/.bashrc changes:"
#source "$myShellProfile" > /dev/null 2>&1 && tail -8 "$myShellrc"

# Handle Licensing
#printHead "Installing vagrant vmware-fusion license..."
#printInfo "Reparing plugins first..."
#vagrant plugin repair

#printInfo "Installing Fusion plugin..."
#vagrant plugin install vagrant-vmware-fusion

#printInfo "All plugins:"
#vagrant plugin list

#printInfo "Installing Vagrant license..."
#vagrant plugin license vagrant-vmware-fusion \
#    "$HOME/Documents/system/hashicorp/license-vagrant-vmware-fusion.lic"


###----------------------------------------------------------------------------
### Ansible
###----------------------------------------------------------------------------
# Boto is for some Ansible/AWS operations
printReq "Installing Ansible..."
#sudo -H python -m pip install ansible paramiko
pip3 install --upgrade ansible paramiko

printHead "Ansible Version Info:"
ansible --version

printHead "Configuring Ansible..."
cat << EOF >> "$myZSHExt"
###############################################################################
###                                 Ansible                                 ###
###############################################################################
export ANSIBLE_CONFIG="\$HOME/.ansible"

EOF

# Source-in and Display changes
#printInfo "ansible ~/.bashrc changes:"
#source "$myShellProfile" > /dev/null 2>&1 && tail -5 "$myShellrc"

# Create a home for Ansible
printInfo "Creating the Ansible directory..."
mkdir -p "$HOME/.ansible/roles"
touch "$HOME/.ansible/"{ansible.cfg,hosts}
cp -pv 'sources/ansible/ansible.cfg' ~/.ansible/ansible.cfg
cp -pv 'sources/ansible/hosts'       ~/.ansible/hosts


###----------------------------------------------------------------------------
### Docker
###----------------------------------------------------------------------------
printReq "Installing Docker, et al..."
# Includes completion
brew install --cask docker
brew install docker-compose docker-completion docker-clean \
    docker-credential-helper


# Create a vbox VM
#printHead "Creating the Docker VM..."
#docker-machine create --driver virtualbox default

printHead "Configuring Docker..."
cat << EOF >> "$myZSHExt"
###############################################################################
###                                 DOCKER                                  ###
###############################################################################
# command-completions for docker, et al.
#eval "\$(docker-machine env default)"

EOF

# Source-in and Display changes
#printInfo "Docker ~/.bashrc changes:"
#source "$myShellProfile" > /dev/null 2>&1 && tail -5 "$myShellrc"


###----------------------------------------------------------------------------
### Install the latest git with completions
###----------------------------------------------------------------------------
printReq "Installing Git..."
# Includes completion
brew install git

printReq "Configuring Git..."
cat << EOF >> "$myGitConfig"
###############################################################################
###                                  GIT                                    ###
###############################################################################
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

cat << EOF >> "$myGitIgnore"
# macOS Stuff
.DS_Store
# Ignore IDE Garbage
**/.idea/*
**/.vscode/*
EOF

# Source-in and Display changes
#printInfo "git ~/.bashrc changes:"
#source "$myShellProfile" > /dev/null 2>&1 && tail -5 "$myShellrc"


###----------------------------------------------------------------------------
### Install Kubernetes-related packages
###----------------------------------------------------------------------------
printReq "Installing Kubernetes-related packages..."
# Includes completion
brew install kubernetes-cli kubernetes-helm kind

# install helper packages
#brew tap azure/draft && brew install draft

# Install ktx; clone the ktx repo
git clone https://github.com/heptiolabs/ktx /tmp/ktx
cd /tmp/ktx || exit

# Install the bash function
cp ktx "${HOME}/.ktx"

# Add this to your "${HOME}/".bash_profile (or similar)
source "${HOME}/.ktx"

# Install the auto-completion
cp ktx-completion.sh "${HOME}/.ktx-completion.sh"

# Add this to your "${HOME}/".bash_profile (or similar)
source "${HOME}/.ktx-completion.sh"


printReq "Configuring kubectl, helm, et al..."
cat << EOF >> "$myZSHExt"
###############################################################################
###                              KUBERNETES                                 ###
###############################################################################
#alias kube='/usr/local/bin/kubectl'
#source <(kubectl completion bash | sed 's/kubectl/kube/g')
#source "\${HOME}/.ktx-completion.sh"
#source "\${HOME}/.ktx"
#source <(kubectl completion bash)
#source <(minikube completion bash)
# --------------------------------------------------------------------------- #
export HELM_HOME="\$HOME/.helm"
#source <(helm     completion bash)

EOF

# Source-in and Display changes
#printInfo "git ~/.bashrc changes:"
#source "$myShellProfile" > /dev/null 2>&1 && tail -15 "$myShellrc"


###----------------------------------------------------------------------------
### Install the CoreOS Operator SDK
###----------------------------------------------------------------------------
printReq "Installing the CoreOS Operator SDK..."
mkdir -p "$GOPATH/src/github.com/operator-framework"
cd "$GOPATH/src/github.com/operator-framework" || exit
git clone https://github.com/operator-framework/operator-sdk
cd operator-sdk || exit
git checkout master
make dep
make all

# move binary to $goBins
sudo mv "$GOPATH/bin/operator-sdk" "$goBins"
cd "$workDir" || exit

###----------------------------------------------------------------------------
### Install confd https://github.com/kelseyhightower/confd
###----------------------------------------------------------------------------
#printReq "Installing confd..."
#mkdir -p "$GOPATH/src/github.com/kelseyhightower"
#confdDir="$GOPATH/src/github.com/kelseyhightower/confd"
#
#git clone https://github.com/kelseyhightower/confd.git "$confdDir"
#cd  "$confdDir" || exit
#make
#cd || exit
#
## move binary to $goBins
#sudo mv "$confdDir/bin/confd" "$goBins"
#cd - || exit

###----------------------------------------------------------------------------
### Install Google Cloud Platform client
###----------------------------------------------------------------------------
printReq "Installing the Google Cloud SDK..."
# Includes completion
brew install --cask google-cloud-sdk


printReq "Configuring the Google Cloud SDK..."
cat << EOF >> "$myZSHExt"
###############################################################################
###                        Google Cloud Platform                            ###
###############################################################################
source "/usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/path.zsh.inc"
source "/usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/completion.zsh.inc"
# --------------------------------------------------------------------------- #

EOF

# Source-in and Display changes
#printInfo "git ~/.bashrc changes:"
#source "$myShellProfile" > /dev/null 2>&1 && tail -11 "$myShellrc"


###----------------------------------------------------------------------------
### Configure Vim
###----------------------------------------------------------------------------
### Pull the code
###---
printReq "Pulling the vimSimple repo..."
git clone --recursive -j10 "$vimSimpleGitRepo" "$vimSimpleLocal"

###----------------------------------------------------------------------------
### Modify 1-off configurations on current submodules
###---
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

####---
####  Set the hostname(s)
####---
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
# defaults read NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false
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
# defaults read com.apple.menuextra.battery ShowPercent
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
#printInfo "Display Day HH:MM AM format..."
#defaults write com.apple.menuextra.clock 'DateFormat' -string 'EEE MMM d  h:mm a'

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
# Set default Tile Size to 42px
defaults write com.apple.dock tilesize 42

### Auto-Hide the Dock
printInfo "Auto-hide The Dock..."
defaults write com.apple.dock autohide -bool true

### Optionally: adjust timing with these settings
#defaults write com.apple.dock autohide-delay -float 0
#defaults write com.apple.dock autohide-time-modifier -float 0

###----------------------------------------------------------------------------
### Configure Basic OS Security
###----------------------------------------------------------------------------
printHead "Configuring Basic OS Security:"

###---
### Disable Guest User at the Login Screen
###---
printInfo "Disable Guest User at the Login Screen..."
sudo defaults write /Library/Preferences/com.apple.loginwindow GuestEnabled -bool NO
# sudo defaults read /Library/Preferences/com.apple.loginwindow GuestEnabled
# OUTPUT: 0

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

# Set Author Name
printInfo "Setting author name..."
defaults write com.apple.TextEdit author "$myFullName"
# Use plain text not RichText
printInfo "Use plain text by default..."
defaults write com.apple.TextEdit RichText -int 0
# Set Font
printInfo "We'll use Courier as the font..."
defaults write com.apple.TextEdit NSFixedPitchFont 'Courier'
# Set Font Size
printInfo "Courier is set to 14pt..."
defaults write com.apple.TextEdit NSFixedPitchFontSize -int 14
# Default Window Size
printInfo "New Windows will open at H:45 x W:100..."
defaults write com.apple.TextEdit WidthInChars -int 100
defaults write com.apple.TextEdit HeightInChars -int 45
# Disable SmartDashes and SmartQuotes (defaut)
printInfo "Disabling SmartDashes and SmartQuotes..."
defaults write com.apple.TextEdit SmartDashes -int 0
defaults write com.apple.TextEdit SmartQuotes -int 0

printInfo "TextEdit Preferences: after:"
defaults read com.apple.TextEdit


###----------------------------------------------------------------------------
### Remove the Github Remote Host Key
###----------------------------------------------------------------------------
#printInfo "Removing the $hostRemote public key from our known_hosts file..."
#ssh-keygen -f "$knownHosts" -R "$hostRemote"


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

# move this garbage to log directory for posterity
sudo find "$HOME" -type f -name 'AT.postflight*' -exec mv {} "$adminLogs" \;

printInfo "Refreshing the Fonts directory..."
atsutil server -ping
sudo atsutil databases -remove
atsutil server -shutdown
atsutil server -ping

# FIXME
printInfo "Restoring the /etc/hosts file..."
if [[ "$myMBPisFor" == 'personal' ]]; then
    if [[ ! -f "$sysBackups/etc/hosts" ]]; then
        printInfo "Can't find $sysBackups/etc/hosts"
    else
        printInfo "Restoring the /etc/hosts file..."
        sudo cp "$sysBackups/etc/hosts" /etc/hosts
        sudo chown root:wheel /etc/hosts
    fi
fi

printInfo "Ensure correct ownership of ~/.viminfo file..."
if [[ -f ~/.viminfo ]]; then
    sudo chown "$USER:$myGroup" ~/.viminfo
fi

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

    4) Data Restoration:
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
gnuDate='/usr/local/opt/coreutils/libexec/gnubin/date'
timePost=$("$gnuDate" +'%T')
### Convert time to a duration
startTime=$("$gnuDate" -u -d "$timePre" +"%s")
endTime=$("$gnuDate" -u -d "$timePost" +"%s")
procDur="$("$gnuDate" -u -d "0 $endTime sec - $startTime sec" +"%H:%M:%S")"
printf '%s\n' """
    Process start at: $timePre
    Process end   at: $timePost
    Process duration: $procDur
"""


###----------------------------------------------------------------------------
### Configure the Shell: base options
###----------------------------------------------------------------------------
printReq "Pulling the latest Oh My Zsh..."
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"


###----------------------------------------------------------------------------
### Fin~
###----------------------------------------------------------------------------
printInfo
