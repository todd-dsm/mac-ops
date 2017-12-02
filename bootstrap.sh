#!/usr/bin/env bash
# shellcheck disable=SC1090,SC1091,SC2059,SC2154,SC2116
#------------------------------------------------------------------------------
# PURPOSE:  A quick and dirty script to configure a base environment so I can
#           get back to work quickly. It will be replaced by Ansible automation
#           as soon as possible.
#------------------------------------------------------------------------------
# EXECUTE:  ./bootstrap.sh 2>&1 | tee ~/.config/admin/logs/mac-ops-config.out
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


###----------------------------------------------------------------------------
### FUNCTIONS
###----------------------------------------------------------------------------
getNewPaths() {
    declare PATH=''
    ### Construct new paths
    printf '\n\n%s\n' "Constructing the \$PATH environment variable..."
    while IFS= read -r binPath; do
        printf '%s\n' "  Adding: $binPath"
        if [[ -z "$myPath" ]]; then
           declare "myPath=$binPath"
       else
           declare myPath="$myPath:$binPath"
        fi
    done < "$sysPaths"

    export PATH="$myPath"


    ### Construct new manpaths
    printf '\n%s\n' "Constructing the \$MANPATH environment variable..."
    while IFS= read -r manPath; do
        printf '%s\n' "  Adding: $manPath"
        if [[ -z "$myMans" ]]; then
           declare "myMans=$manPath"
       else
           declare myMans="$myMans:$manPath"
        fi
    done < "$sysManPaths"

    export MANPATH="$myMans"
}


###----------------------------------------------------------------------------
### The Setup
###----------------------------------------------------------------------------
### Backup some files before we begin
###---
if [[ "$theENV" == 'TEST' ]]; then
    printf '\n%s\n' "Backing up the /etc directory before we begin..."
    sudo rsync -aE /private/etc "$backupDir/" 2> /tmp/rsync-err-etc.out
fi

###---
### Add the Github key to the knownhosts file
###---
printf '\n%s\n' "Checking to see if we have the Github public key..."
if ! grep "^$hostRemote" "$knownHosts"; then
    printf '%s\n' "  We don't, pulling it now..."
    ssh-keyscan -t 'rsa' "$hostRemote" >> "$knownHosts"
else
    printf '\n%s\n' "  We have the Github key, all good."
fi

###---
### Pull some stuff for the Terminal
###---
printf '\n%s\n' "Pulling Terminal stuff..."
#printf '\n%s\n' "  Cloning $solarizedGitRepo..."
git clone "$solarizedGitRepo" "$termStuff/solarized"

# Pull the settings back
if [[ ! -d "$myBackups" ]]; then
    printf '\n%s\n' "There are no 'settings' to restore."
else
    printf '\n%s\n' "Restoring Terminal (and other) settings..."
    rsync -aEv  "$myBackups/Documents/system" "$myDocs/" 2> /tmp/rsync-err-system.out
fi

###----------------------------------------------------------------------------
### Configure the Shell: base options
###----------------------------------------------------------------------------
printf '\n\n%s\n' "Configuring base shell options..."

printf '%s\n' "  Configuring $myBashProfile ..."
cat << EOF >> "$myBashProfile"
# URL: https://www.gnu.org/software/bash/manual/bashref.html#Bash-Startup-Files
if [ -f ~/.bashrc ]; then
	. ~/.bashrc
fi

EOF


printf '%s\n' "  Configuring $myBashrc ..."
cat << EOF >> "$myBashrc"
# shellcheck disable=SC2148,SC1090,SC1091,SC2012,SC2139
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
export PROMPT_COMMAND="history -a; \$PROMPT_COMMAND"
# If you want the last command ran immediately available to all currently open
# shells then comment the one above and uncomment the two below.
#shopt -s histappend
#export PROMPT_COMMAND="history -a; history -c; history -r; \$PROMPT_COMMAND"
export HISTCONTROL=ignoredups
export HISTTIMEFORMAT="%a%l:%M %p  "
export HISTIGNORE='ls:bg:fg:history'

EOF

# Source-in and Display changes
printf '\n%s\n' "System ~/.bashrc changes:"
source "$myBashProfile" && tail -18 "$myBashrc"


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

printf '\n%s\n' "Configuring Homebrew..."
cat << EOF >> "$myBashrc"
###############################################################################
###                                Homebrew                                 ###
###############################################################################
source /usr/local/etc/bash_completion.d/brew

EOF

# Source-in and Display changes
printf '\n%s\n' "homebrew ~/.bashrc changes:"
source "$myBashProfile" && tail -5 "$myBashrc"


###----------------------------------------------------------------------------
### Display some defaults for the log
### For some reason Homebrew triggers a set -x; counter that
###----------------------------------------------------------------------------
set +x
printf '\n%s\n' "Default macOS paths:"
printf '%s\n' "System Paths:"
cat "$sysPaths"
printf '%s\n\n' "\$PATH=$PATH"

printf '%s\n' "System man paths:"
cat "$sysManPaths"
if [[ -z "$MANPATH" ]]; then
    printf '%s\n\n' "MANPATH is empty!"
else
    printf '%s\n\n' "\$MANPATH=$MANPATH"
fi


###----------------------------------------------------------------------------
### Install the font: Hack
### Hack is a solid font for programmers; version 2.010 is the golden-age.
### If you want the latest version then:
###   *delete the mkdir and tar lines
###   *uncomment the brew lines.
###----------------------------------------------------------------------------
printf '\n%s\n' "Installing font: Hack..."
mkdir "$HOME/Library/Fonts"
tar xzvf "$myDocs/system/Hack-v2_010-ttf.tgz" -C "$HOME/Library/Fonts"
#brew tap caskroom/fonts
#brew cask install font-hack


###----------------------------------------------------------------------------
### Let's Get Open: GNU Coreutils
###----------------------------------------------------------------------------
printf '\n\n%s\n' "Let's get open..."

printf '%s\n' "Installing sed - the stream editor..."
brew install gnu-sed --with-default-names

printf '%s\n' "  Installing GNU Coreutils..."
brew install coreutils


###----------------------------------------------------------------------------
### Set new Variables
###----------------------------------------------------------------------------
declare pathGNU_CORE="$(brew --prefix coreutils)"

# Set path for the GNU Coreutils
sudo sed -i "\|/usr/local/bin|i $pathGNU_CORE/libexec/gnubin" "$sysPaths"

# Set path for the GNU Coreutils Manuals
sudo sed -i "\|/usr/share/man|i $pathGNU_CORE/libexec/gnuman" "$sysManPaths"

# Move system manpaths down 1 line
sudo sed -i -n '2{h;n;G};p' "$sysManPaths"


###---
#### Verify the new paths have been set
###---
getNewPaths

###----------------------------------------------------------------------------
### PATHs
###   * System:  /usr/bin:/bin:/usr/sbin:/sbin
###   * Homebrew: anything under /usr/local
###----------------------------------------------------------------------------
printf '\n%s\n' "The new paths:"
printf '%s\n' "\$PATH:"
cat "$sysPaths"
printf '%s\n\n' "$PATH"

###----------------------------------------------------------------------------
### MANPATHs
###   * System:   /usr/share/man
###   * Homebrew: /usr/local/share/man
###----------------------------------------------------------------------------
printf '%s\n' "\$MANPATH:"
cat "$sysManPaths"
if [[ -z "$MANPATH" ]]; then
    printf '%s\n\n' "MANPATH is empty!"
else
    printf '%s\n\n' "\$MANPATH=$MANPATH"
fi


### Configure coreutils
printf '\n%s\n' "Configuring GNU Coreutils..."
cat << EOF >> "$myBashrc"
###############################################################################
###                                coreutils                                ###
###############################################################################
export MANPATH=$MANPATH
# Filesystem Operational Behavior
function ll { ls --color -l   "\$@" | egrep -v '.(DS_Store|CFUserTextEncoding)'; }
function la { ls --color -al  "\$@" | egrep -v '.(DS_Store|CFUserTextEncoding)'; }
function ld { ls --color -ld  "\$@" | egrep -v '.(DS_Store|CFUserTextEncoding)'; }
function lh { ls --color -alh "\$@" | egrep -v '.(DS_Store|CFUserTextEncoding)'; }
alias cp='cp -rfvp'
alias mv='mv -v'
# FIX: alias for GNU zip/unzip do not work
alias zip='/usr/local/bin/gzip'
alias unzip='/usr/local/bin/gunzip'
alias hist='history | cut -c 21-'

EOF

# Source-in and Display changes
printf '\n%s\n' "coreutils ~/.bashrc changes:"
source "$myBashProfile" && tail -16 "$myBashrc"


###----------------------------------------------------------------------------
### Install GNU Tools and Languages
###----------------------------------------------------------------------------
printf '\n%s\n' "Installing and configuring additional GNU programs..."
brew install homebrew/dupes/ed --with-default-names
brew install gnu-indent --with-default-names
brew install findutils --with-default-names
brew install gnu-which --with-default-names
brew install wget --with-pcre
brew install gnu-tar --with-default-names
brew install gnu-time --with-default-names
brew install homebrew/dupes/grep --with-default-names
brew install gnupg2 --with-readline --without-dirmngr
brew install homebrew/dupes/gzip gawk homebrew/dupes/diffutils

printf '\n%s\n' "Configuring grep and find..."
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

# Source-in and Display changes
printf '\n%s\n' "grep/find ~/.bashrc changes:"
source "$myBashProfile" && tail -38 "$myBashrc"


###----------------------------------------------------------------------------
### Install the Casks (GUI Apps)
###----------------------------------------------------------------------------
printf '\n%s\n' "Installing GUI (cask) Apps..."
brew cask install \
    atom android-file-transfer flux java wireshark osxfuse \
    virtualbox virtualbox-extension-pack

printf '%s\n' "  Installing Google Chrome..."
brew cask install google-chrome
#mkdir -p "$HOME/Library/Application\ Support/Google/Chrome"
#chown -R vagrant:staff "/Users/vagrant/Library/Application Support"/


###---
### Install the latest version of VMware Fusion
### Using older versions of Fusion on current macOS never seems to work.
###---
printf '%s\n' "  Installing VMware Fusion: 7..."
brew cask install vmware-fusion

###---
### VirtualBox configurations
###---
printf '\n%s\n' "Configuring VirtualBox..."
printf '%s\n' "  Setting the machinefolder property..."
vboxmanage setproperty machinefolder "$HOME/vms/vbox"

printf '\n%s\n' "Configuring VirtualBox..."
cat << EOF >> "$myBashrc"
###############################################################################
###                                VirtualBox                               ###
###############################################################################
export VBOX_USER_HOME="\$HOME/vms/vbox"

EOF


###---
### VMware configurations
###---
printf '\n%s\n' "Configuring VMware..."
cat << EOF >> "$myBashrc"
###############################################################################
###                                  VMware                                 ###
###############################################################################
export VMWARE_STORAGE="\$HOME/vms/vmware"

EOF

tail -10 "$myBashrc"


###----------------------------------------------------------------------------
### Useful System Utilities
###----------------------------------------------------------------------------
printf '\n\n%s\n' "Installing system utilities..."
brew install \
    git nmap homebrew/dupes/rsync ssh-copy-id watch tree pstree psgrep  \
    sipcalc whatmask ipcalc dos2unix testdisk homebrew/fuse/sshfs       \
    homebrew/dupes/openssh

### Seperate installs for programs with options
printf '%s\n' "  Installing tcl-tk with options..."
brew install homebrew/dupes/tcl-tk --with-threads

### Include path for tcl-tk
printf '%s\n' "  Opening up /usr/local/opt/tcl-tk/bin so we can see tcl..."
sudo sed -i "\|/usr/bin|i /usr/local/opt/tcl-tk/bin"   "$sysPaths"

printf '%s\n' "  Installing tcpdump with options..."
brew install homebrew/dupes/tcpdump --with-libpcap

printf '%s\n' "  Installing tmux with options..."
brew install tmux --with-utf8proc

### Include path for tcpdump
printf '%s\n' "  Opening up /usr/local/sbin so we can see tcpdump..."
sudo sed -i "\|/usr/bin|i /usr/local/sbin"             "$sysPaths"


###----------------------------------------------------------------------------
### PYTHON
###----------------------------------------------------------------------------
printf '\n\n%s\n' "Installing Python..."
printf '%s\n' """
    ####    ####    ####    ####    ####     ####     ####     ####     ####

        You can safely ignore the message 'echo export PATH' message from
                  the installer. THIS IS NOT NECESSARY.

    ####    ####    ####    ####    ####     ####     ####     ####     ####
    """

brew install python python3

printf '\n%s\n' "Upgrading Python Pip and setuptools..."
pip  install --upgrade pip setuptools neovim
pip3 install --upgrade pip setuptools wheel neovim \
    ipython simplejson requests boto


printf '\n%s\n' "Configuring Python..."
cat << EOF >> "$myBashrc"
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
printf '%s\n' "Configuring pip..."
printf '%s\n' "  Creating pip home..."
if [[ ! -d "$myConfigs/python" ]]; then
    mkdir -p "$myConfigs/python"
fi

printf '%s\n' "  Creating the pip config file..."
cat << EOF >> "$myConfigs/python/pip.conf"
# pip configuration
[list]
format=columns

EOF

###---
### Configure autoenv
###---
printf '%s\n' "Configuring autoenv..."

printf '%s\n' "  Creating the autoenv file..."
touch "$myConfigs/python/autoenv_authorized"


# Source-in and Display changes
printf '\n%s\n' "python ~/.bashrc changes:"
source "$myBashProfile" && tail -5 "$myBashrc"

printf '\n%s\n' "Testing pip config..."
pip list


###----------------------------------------------------------------------------
### Ruby
###----------------------------------------------------------------------------
printf '\n\n%s\n' "Installing Ruby..."
brew install ruby chruby

###---
### Update/Install Gems
###---
printf '%s\n' "Updating all Gems..."
gem update "$(gem list | cut -d' ' -f1)"

printf '%s\n' "  Installing new Gems to test..."
gem install neovim


printf '\n%s\n' "Configuring Ruby..."
cat << EOF >> "$myBashrc"
###############################################################################
###                                   Ruby                                  ###
###############################################################################
#source /usr/local/opt/chruby/share/chruby/chruby.sh
#source /usr/local/opt/chruby/share/chruby/auto.sh

EOF

# Source-in and Display changes
printf '\n%s\n' "ruby ~/.bashrc changes:"
source "$myBashProfile" && tail -6 "$myBashrc"


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

# Source-in and Display changes
printf '\n%s\n' "golang ~/.bashrc changes:"
source "$myBashProfile" && tail -6 "$myBashrc"


###----------------------------------------------------------------------------
### Bash
###----------------------------------------------------------------------------
printf '\n%s\n' "Installing Bash..."
brew install bash shellcheck dash bash-completion@2

# Configure GNU Bash for the system and current $USER
printf '\n%s\n' "  Configuring Bash..."

printf '%s\n' "  Creating a softlink from sh to dash..."
ln -sf '/usr/local/bin/dash' '/usr/local/bin/sh'

printf '\n%s\n' "System Shells default:"
grep '^\/' "$sysShells"
sudo sed -i "\|^.*bash$|i /usr/local/bin/bash" "$sysShells"
sudo sed -i "\|local|a /usr/local/bin/sh"      "$sysShells"
printf '\n%s\n' "System Shells new:"
grep '^\/' "$sysShells"

printf '\n%s\n' "$USER's default shell:"
dscl . -read "$HOME" UserShell

printf '\n%s\n' "Configuring $USER's shell..."
sudo chpass -s "$(which bash)" "$USER"

printf '\n%s\n' "$USER's new shell:"
dscl . -read "$HOME" UserShell

cat << EOF >> "$myBashrc"
###############################################################################
###                                   Bash                                  ###
###############################################################################
export SHELL='/usr/local/bin/bash'
export BASH_VERSION="\$(bash --version | head -1 | awk -F " " '{print \$4}')"
# ShellCheck: Ignore: https://goo.gl/n9W5ly
export SHELLCHECK_OPTS="-e SC2155"

EOF

# Source-in and Display changes
printf '\n%s\n' "bash ~/.bashrc changes:"
source "$myBashProfile" && tail -8 "$myBashrc"


###----------------------------------------------------------------------------
### nodejs and npm
###----------------------------------------------------------------------------
printf '\n%s\n' "Installing the Node.js and npm..."
brew reinstall node --with-full-icu

# Create the code path
#printf '\n%s\n' "  Creating the \$GOPATH directory..."
#mkdir -p "$HOME/code/gocode"

printf '\n%s\n' "  Configuring npm..."
cat << EOF >> "$myBashrc"
###############################################################################
###                                  npm                                    ###
###############################################################################
source /usr/local/etc/bash_completion.d/npm

EOF

# Source-in and Display changes
printf '\n%s\n' "npm ~/.bashrc changes:"
source "$myBashProfile" && tail -5 "$myBashrc"


###----------------------------------------------------------------------------
### Vim: The Power and the Glory
###----------------------------------------------------------------------------
printf '\n%s\n' "Upgrading to full-blown Vim..."

# Verify before install
printf '\n%s\n' "Checking Apple's Vim..."
vim --version | grep  -E --color 'VIM|Compiled|python|ruby|perl|tcl'

# Install Vim with support for:
#   Use this version over the system one
#   w/o NLS (National Language Support)
#   +Python   (v2; default)
#   +Ruby     (default)
#   +Lua      (broke)
#   +mzscheme (broke)

printf '\n\n%s\n' "Installing Vim..."
brew install vim --with-override-system-vi --without-nls --with-python3 \
#    --with-lua --with-mzscheme --with-tcl

# We should evaluate Neovim
printf '\n%s\n' "Installing Neovim..."
brew install neovim/neovim/neovim

printf '\n%s\n' "Configuring Vim..."
cat << EOF >> "$myBashrc"
###############################################################################
###                                   Vim                                   ###
###############################################################################
export EDITOR='/usr/local/bin/vim'
alias vi="\$EDITOR"
alias nim='/usr/local/bin/nvim'

EOF

# Source-in and Display changes
printf '\n%s\n' "vim ~/.bashrc changes:"
source "$myBashProfile" && tail -8 "$myBashrc"


# Verify after install
printf '\n%s\n' "The Real version of Vim:"
vim --version | grep  -E --color 'VIM|Compiled|python|ruby|perl|tcl'


###----------------------------------------------------------------------------
### Amazon AWS CLI
###----------------------------------------------------------------------------
printf '\n\n%s\n' "Installing the AWS CLI..."
pip3 install awscli

printf '%s\n' "  Installing some AWS CLI Utilitiese..."
pip install --upgrade jmespath jmespath-terminal

brew tap jmespath/jmespath
brew install jp jq

printf '\n%s\n' "Configuring the AWS CLI..."
cat << EOF >> "$myBashrc"
###############################################################################
###                                 Amazon                                  ###
###############################################################################
complete -C "\$(type -P aws_completer)" aws
#export AWS_REGION='yourRegion'
#export AWS_PROFILE='awsUser'
export AWS_CONFIG_FILE="\$HOME/.aws/config"

EOF

printf '%s\n' "  Setting the AWS User to your local account name..."
sed -i "/AWS_PROFILE/ s/awsUser/$USER/g" "$myBashrc"

# Restore the AWS configs if there are any
if [[ ! -d "$myBackups" ]]; then
    printf '%s\n' "There are no AWS settings to restore."
else
    printf '%s\n' "  Restoring AWS directory..."
    rsync -aEv "$myBackups/.aws" "$HOME/"
    sudo chown -R "$USER:staff" "$HOME/.aws"
fi

# Source-in and Display changes
printf '\n%s\n' "aws ~/.bashrc changes:"
source "$myBashProfile" && tail -7 "$myBashrc"


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

# Source-in and Display changes
printf '\n%s\n' "token ~/.bashrc changes:"
source "$myBashProfile" && tail -8 "$myBashrc"


###----------------------------------------------------------------------------
### HashiCorp: Terraform
###----------------------------------------------------------------------------
printf '\n%s\n' "Installing Terraform..."
brew install terraform terraform-inventory graphviz

printf '\n%s\n' "Configuring Terraform..."
cat << EOF >> "$myBashrc"
###############################################################################
###                                Terraform                                ###
###############################################################################
alias tf='/usr/local/bin/terraform'
export TF_VAR_AWS_PROFILE="\$AWS_PROFILE"
export TF_LOG='DEBUG'
export TF_LOG_PATH='/tmp/terraform.log'

EOF

# Source-in and Display changes
printf '\n%s\n' "terraform ~/.bashrc changes:"
source "$myBashProfile" && tail -8 "$myBashrc"


###----------------------------------------------------------------------------
### HashiCorp: Packer
###----------------------------------------------------------------------------
printf '\n%s\n' "Installing Packer..."
brew install packer packer-completion

printf '\n%s\n' "Configuring Packer..."
cat << EOF >> "$myBashrc"
###############################################################################
###                                  Packer                                 ###
###############################################################################
source /usr/local/etc/bash_completion.d/packer
export PACKER_HOME="\$HOME/vms/packer"
# leave PACKER_CONFIG commented till you need it
#export PACKER_CONFIG="\$PACKER_HOME"
export PACKER_CACHE_DIR="\$PACKER_HOME/iso-cache"
export PACKER_BUILD_DIR="\$PACKER_HOME/builds"
export PACKER_LOG='yes'
export PACKER_LOG_PATH='/tmp/packer.log'
export PACKER_NO_COLOR='yes'

EOF

# Source-in and Display changes
printf '\n%s\n' "packer ~/.bashrc changes:"
source "$myBashProfile" && tail -10 "$myBashrc"


###----------------------------------------------------------------------------
### HashiCorp: Vagrant
###----------------------------------------------------------------------------
printf '\n%s\n' "Installing Vagrant..."
brew cask install vagrant
brew install vagrant-completion

printf '\n%s\n' "Configuring Vagrant..."
cat << EOF >> "$myBashrc"
###############################################################################
###                                 Vagrant                                 ###
###############################################################################
source /usr/local/etc/bash_completion.d/vagrant
#export VAGRANT_LOG=debug
export VAGRANT_HOME="\$HOME/vms/vagrant"
export VAGRANT_BOXES="\$VAGRANT_HOME/boxes"
export VAGRANT_DEFAULT_PROVIDER='virtualbox'

EOF

# Source-in and Display changes
printf '\n%s\n' "vagrant ~/.bashrc changes:"
source "$myBashProfile" && tail -8 "$myBashrc"

printf '\n%s\n' "Installing vagrant vmware-fusion license..."
printf '%s\n'   "  Reparing plugins first..."
vagrant plugin repair

printf '%s\n'   "  Installing Fusion plugin..."
vagrant plugin install vagrant-vmware-fusion

printf '%s\n'   "  All plugins:"
vagrant plugin list

printf '%s\n'   "  Installing Vagrant license..."
vagrant plugin license vagrant-vmware-fusion \
    "$HOME/Documents/system/hashicorp/license-vagrant-vmware-fusion.lic"


###----------------------------------------------------------------------------
### Ansible
###----------------------------------------------------------------------------
# Boto is for some Ansible/AWS operations
printf '\n%s\n' "Installing Ansible..."
pip install --upgrade ansible boto

printf '\n%s\n' "  Ansible Version Info:"
ansible --version

printf '\n%s\n' "Configuring Vagrant..."
cat << EOF >> "$myBashrc"
###############################################################################
###                                 Ansible                                 ###
###############################################################################
export ANSIBLE_CONFIG="\$HOME/.ansible"

EOF

# Source-in and Display changes
printf '\n%s\n' "ansible ~/.bashrc changes:"
source "$myBashProfile" && tail -5 "$myBashrc"

# Create a home for Ansible
printf '%s\n' "  Creating the Ansible directory..."
mkdir -p "$HOME/.ansible/roles"
touch "$HOME/.ansible/"{ansible.cfg,hosts}
cp -pv 'sources/ansible/ansible.cfg' ~/.ansible/ansible.cfg
cp -pv 'sources/ansible/hosts'       ~/.ansible/hosts


###----------------------------------------------------------------------------
### Docker
###----------------------------------------------------------------------------
printf '\n%s\n' "Installing Docker, et al..."
brew install docker docker-machine docker-compose

# Create a vbox VM
#printf '%s\n' "  Creating the Docker VM..."
#docker-machine create --driver virtualbox default

printf '\n%s\n' "Configuring Docker..."
cat << EOF >> "$myBashrc"
###############################################################################
###                                 DOCKER                                  ###
###############################################################################
# command-completions for docker, et al.
source /usr/local/etc/bash_completion.d/docker
source /usr/local/etc/bash_completion.d/docker-compose
source /usr/local/etc/bash_completion.d/docker-machine.bash
source /usr/local/etc/bash_completion.d/docker-machine-wrapper.bash
#eval "\$(docker-machine env default)"

EOF

# Source-in and Display changes
printf '\n%s\n' "Docker ~/.bashrc changes:"
source "$myBashProfile" && tail -5 "$myBashrc"


###----------------------------------------------------------------------------
### Git is already installed; this is only configuration
###----------------------------------------------------------------------------
printf '\n%s\n' "Configuring Git..."
cat << EOF >> "$myBashrc"
###############################################################################
###                                  GIT                                    ###
###############################################################################
source /usr/local/etc/bash_completion.d/git-completion.bash

EOF

# Source-in and Display changes
printf '\n%s\n' "git ~/.bashrc changes:"
source "$myBashProfile" && tail -5 "$myBashrc"


###----------------------------------------------------------------------------
### Post-configuration Steps
###----------------------------------------------------------------------------
printf '\n\n%s\n' "Securing ~/.bashrc ..."
chmod 600 "$myBashrc"


###----------------------------------------------------------------------------
### Configure Vim
###----------------------------------------------------------------------------
### Pull the code
###---
printf '\n%s\n\n' "Pulling the vimSimple repo..."
git clone --recursive -j10 "$vimSimpleGitRepo" "$vimSimpleLocal"

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

### Make softlinks to the important files
printf '\n%s\n\n' "Creating softlinks for ~/.vim and ~/.vimrc"
ln -s "$vimSimpleLocal/vimrc" ~/.vimrc
ln -s "$vimSimpleLocal/vim"   ~/.vim

ls -dl ~/.vimrc ~/.vim


###----------------------------------------------------------------------------
### Nvim Configurations
###----------------------------------------------------------------------------
printf '\n%s\n' "Neovim post-install configurations:"
printf '%s\n' "  Saving default \$TERM details > ~/config/term/..."
mkdir "$termDir"
infocmp "$TERM" > "$termDir/$TERM.ti"
infocmp "$TERM" | sed 's/kbs=^[hH]/kbs=\\177/' > "$termDir/$TERM-nvim.ti"

printf '%s\n' "  Compiling terminfo for Neovim warning..."
tic "$termDir/$TERM-nvim.ti"

printf '%s\n' "  Linking to existing .vim directory..."
ln -s "$vimSimpleLocal/vim" "$nvimDir"

printf '%s\n' "  Linking to existing .vimrc file..."
ln -s "$vimSimpleLocal/vimrc" "$nvimDir/init.vim"


###----------------------------------------------------------------------------
### Configure The macOS
###----------------------------------------------------------------------------
### Configure the System
###---
printf '\n%s\n' "Configuring the System:"

###---
###  Set the hostname(s)
###---
printf '\n%s\n' "Configuring the hostname(s)..."
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
### Stop Photos from opening automatically when plugging in iPhone [TEST]
###---
printf '%s\n' "  Stop Photos from opening automatically..."
defaults -currentHost write com.apple.ImageCapture disableHotPlug -bool true

###---
### TextEdit
###---
printf '%s\n' "  TextEdit Preferences: before:"
defaults read com.apple.TextEdit

# Set Author Name
printf '%s\n' "  Setting autor name..."
defaults write com.apple.TextEdit author "$myFullName"
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

### Create a link to the log file
ln -s ~/.config/admin/logs/mac-ops-config.out config-output.log


###----------------------------------------------------------------------------
### Restore Personal Data
###----------------------------------------------------------------------------
if [[ ! -d "$myBackups" ]]; then
    printf '\n%s\n' "There are no Documents to restore."
else
    printf '\n%s\n' "Restoring files..."
    tools/restore-my-stuff.sh 2> /tmp/rsycn-errors.out
fi


###----------------------------------------------------------------------------
### Some light housework
###----------------------------------------------------------------------------
printf '\n%s\n' "Cleaning up a bit..."
sudo find "$HOME" -type f -name 'AT.postflight*' -exec mv {} "$adminLogs" \;

printf '%s\n' "  Refreshing the Fonts directory..."
fc-cache -frv "$HOME/Library/Fonts"

printf '%s\n' "  Restoring the /etc/hosts file..."
sudo cp "$sysBackups/etc/hosts" /etc/hosts
sudo chown root:wheel /etc/hosts

printf '%s\n' "  Ensure correct ownership of ~/.viminfo file..."
if [[ -f ~/.viminfo ]]; then
    sudo chown "$USER:staff" ~/.viminfo
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
declare gnuDate='/usr/local/opt/coreutils/libexec/gnubin/date'
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
### Fin~
###----------------------------------------------------------------------------
exit 0
