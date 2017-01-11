#!/usr/bin/env bash
#------------------------------------------------------------------------------
# PURPOSE: Configure a base environment to get back to work quickly.
#------------------------------------------------------------------------------
# EXECUTE: curl -Lo- https://goo.gl/IjzNwV | bash | tee -ai mymac.log
#------------------------------------------------------------------------------
#  AUTHOR: todd_dsm
#------------------------------------------------------------------------------
#    DATE: 2015/07/11
#------------------------------------------------------------------------------
set -x

###------------------------------------------------------------------------------
### First, let's define who, where and what I am -  then make the announcement.
###------------------------------------------------------------------------------
### The 'Who'
###---
export myName="$(basename $0)"
if [[ -z "$myName" ]]; then
    echo "Something's gone wrong, exiting."
    exit 1
else
    echo ""
    echo "Hi, my name is $myName. I'll be your installer today :-)"
fi


###------------------------------------------------------------------------------
### VARIABLES
###------------------------------------------------------------------------------
declare myBashProfile="$HOME/.bash_profile"
declare myBashrc="$HOME/.bashrc"


###------------------------------------------------------------------------------
### FUNCTIONS
###------------------------------------------------------------------------------


###----------------------------------------------------------------------------
### Configure the Shell: base options
###----------------------------------------------------------------------------
echo "Configuring base shell options..."

cat << EOF >> "$myBashProfile"
# URL: https://www.gnu.org/software/bash/manual/bashref.html#Bash-Startup-Files
if [ -f ~/.bashrc ]; then
	. ~/.bashrc
fi

EOF


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

source "$myBashrc" && tail -26 "$myBashrc"


###----------------------------------------------------------------------------
### Install Homebrew
###----------------------------------------------------------------------------
echo "Installing Homebrew..."
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

echo "Updating Homebrew..."
brew update

echo "Running 'brew doctor'..."
brew doctor

echo "Tapping Homebrew binaries..."
brew tap homebrew/binary

echo "Opening up the cask room..."
brew install caskroom/cask/brew-cask


###----------------------------------------------------------------------------
### Prep for Homebrew: GNU Core Utils
###----------------------------------------------------------------------------
echo "Prepping for brewed GNU Core Utils..."

cat << EOF >> "$myBashrc"
###############################################################################
###                                 Homebrew                                ###
###############################################################################
export PATH="\$(brew --prefix coreutils)/libexec/gnubin:\$PATH"
export MANPATH="\$(brew --prefix coreutils)/libexec/gnuman:/usr/local/share/man:\$MANPATH"

EOF

source "$myBashrc" && tail -6 "$myBashrc"


###----------------------------------------------------------------------------
### Let's Get Open: Install GNU Tools
###----------------------------------------------------------------------------
echo "Installing and configuring GNU coreutils..."
brew install coreutils

cat << EOF >> "$myBashrc"
###############################################################################
###                                 coreutils                               ###
###############################################################################
function ll { ls --color -Al  "\$@" | egrep -v '.(DS_Store|CFUserTextEncoding)'; }
function la { ls --color -al  "\$@" | egrep -v '.(DS_Store|CFUserTextEncoding)'; }
function ld { ls --color -ld  "\$@" | egrep -v '.(DS_Store|CFUserTextEncoding)'; }
function lh { ls --color -alh "\$@" | egrep -v '.(DS_Store|CFUserTextEncoding)'; }
alias cp='cp -vp'
alias mv='mv -v'
alias hist='history | cut -c 21-'

EOF

source "$myBashrc" && tail -11 "$myBashrc"


###----------------------------------------------------------------------------
### Install GNU Tools and Languages
###----------------------------------------------------------------------------
echo "Installing and configuring GNU Tools..."
brew install ed --with-default-names
brew install gnu-sed --with-default-names
brew install gawk
brew install gnu-indent --with-default-names
brew install psgrep
brew install findutils --with-default-names
brew install gnu-which --with-default-names
brew install watch
brew install tree
brew install wget --with-pcre
# Both zip & unzip are in the same package
brew install homebrew/dupes/gzip
brew install gnu-tar --with-default-names
brew install homebrew/dupes/diffutils
brew install gnu-time --with-default-names
brew install homebrew/dupes/grep --with-default-names

echo "Configuring grep..."

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
### PYTHON
###----------------------------------------------------------------------------
echo "Installing and configuring Python..."
brew install python

echo "Upgrading pip..."
pip install --upgrade pip

cat << EOF >> "$myBashrc"
###############################################################################
###                                  Python                                 ###
###############################################################################
export PYTHONPATH="$(brew --prefix)/lib/python2.7/site-packages"

EOF

source "$myBashrc" && tail -5 "$myBashrc"


###----------------------------------------------------------------------------
### Bash
###----------------------------------------------------------------------------
echo "Installing Bash..."
brew install bash shellcheck

# Add the new version of Bash to system shells file
declare sysShells='/etc/shells'

grep ".*bash$" "$sysShells"
sudo sed -i "/.*bash$/ i\/usr/local/bin/bash" "$sysShells"
grep ".*bash$" "$sysShells"

cat << EOF >> "$myBashrc"
###############################################################################
###                                   Bash                                  ###
###############################################################################
export SHELL='/usr/local/bin/bash'
# ShellCheck: Ignore: https://goo.gl/n9W5ly
export SHELLCHECK_OPTS="-e SC2155"

EOF

source "$myBashrc" && tail -7 "$myBashrc"


###----------------------------------------------------------------------------
### Vim: The Power and the Glory
###----------------------------------------------------------------------------
# Verify before install
vim --version | egrep --color 'VIM|Compiled|python|ruby|perl|tcl'

# Install it
echo "Installing Vim..."
brew install vim --override-system-vi --without-nls \
    --with-lua --with-mzscheme --with-tcl

# We should evaluate Neovim
echo "Installing Neovim..."
brew install neovim/neovim/neovim

echo "Configuring Vim..."
# +Python (2; default)
# +Ruby   (default)
# w/o NLS (National Language Support)

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
echo "The Real version of Vim:"
vim --version | egrep --color 'VIM|Compiled|python|ruby|perl|tcl'


###----------------------------------------------------------------------------
### HashiCorp: ATLAS    (get TOKEN(s) from your backups)
###----------------------------------------------------------------------------
echo "Configuring ATLAS..."

cat << EOF >> "$myBashrc"
###############################################################################
###                                  Atlas                                  ###
###############################################################################
export ATLAS_TOKEN=''
export HOMEBREW_GITHUB_API_TOKEN=''

EOF

source "$myBashrc" && tail -6 "$myBashrc"


###----------------------------------------------------------------------------
### HashiCorp: Terraform
###----------------------------------------------------------------------------
echo "Installing Terraform..."
brew install terraform terraform-inventory

cat << EOF >> "$myBashrc"
###############################################################################
###                              Terraform                                  ###
###############################################################################
alias tf='/usr/local/bin/terraform'
export TF_LOG='DEBUG'
export TF_LOG_PATH='/tmp/terraform.log'

EOF

source "$myBashrc" && tail -7 "$myBashrc"

###----------------------------------------------------------------------------
### HashiCorp: Packer
###----------------------------------------------------------------------------
# Homebrew is occasionally a version behind. Just download it from the site.
echo "Installing Packer..."
brew install packer

echo "Configuring Packer..."
cat << EOF >> "$myBashrc"
###############################################################################
###                                  Packer                                 ###
###############################################################################
export PACKER_LOG='yes'
export PACKER_HOME="\$HOME/vms/packer"
export PACKER_CACHE_DIR="\$PACKER_HOME/vms/packer/iso-cache/"
export PACKER_BUILD_DIR="\$PACKER_HOME/builds"
export PACKER_LOG_PATH='/tmp/packer.log'

EOF

source "$myBashrc" && tail -9 "$myBashrc"


###----------------------------------------------------------------------------
### HashiCorp: Vagrant
###----------------------------------------------------------------------------
# Homebrew is occasionally a version behind. Just download it from the site.
echo "Installing Vagrant..."
brew cask install vagrant

echo "Configuring Vagrant..."
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
echo "Installing Ansible..."
brew install ansible

echo "Configuring Ansible..."
cat << EOF >> "$myBashrc"
###############################################################################
###                                 Ansible                                 ###
###############################################################################
export ANSIBLE_HOSTS='/etc/ansible/hosts'
export ANSIBLE_HOSTS='/usr/local/etc/ansible/hosts'

EOF

source "$myBashrc" && tail -6 "$myBashrc"


###----------------------------------------------------------------------------
### Docker
###----------------------------------------------------------------------------
echo "Installing Docker..."
brew install docker docker-machine

# Create a vbox VM
docker-machine create --driver virtualbox default

echo "Configuring Docker..."
cat << EOF >> "$myBashrc"
###############################################################################
###                                 DOCKER                                  ###
###############################################################################
eval "\$(docker-machine' 'env)"
export DOCKER_TLS_VERIFY="1"
export DOCKER_HOST="tcp://192.168.99.100:2376"
export DOCKER_CERT_PATH="\$HOME/.docker/machine/machines/default"
export DOCKER_MACHINE_NAME="default"

EOF

source "$myBashrc" && tail -9 "$myBashrc"

###----------------------------------------------------------------------------
### Amazon AWS CLI
###----------------------------------------------------------------------------
echo "Installing the AWS CLI..."
pip install awscli

echo "Configuring Docker..."
cat << EOF >> "$myBashrc"
###############################################################################
###                                 Amazon                                  ###
###############################################################################
complete -C "\$(type -P aws_completer)" aws
export AWS_PROFILE='awsUser'
export AWS_CONFIG_FILE="\$HOME/.aws/config"

EOF

source "$myBashrc" && tail -7 "$myBashrc"


###----------------------------------------------------------------------------
### Useful System Utilities
###----------------------------------------------------------------------------
echo "Installing some system utilities..."

brew install git nmap ssh-copy-id gnupg
brew reinstall wget --with-iri


###----------------------------------------------------------------------------
### Install the Casks (GUI Apps)
###----------------------------------------------------------------------------
echo "Installing some utilities..."
brew cask install \
    gfxcardstatus google-chrome java vagrant vmware-fusion7 \
    virtualbox wireshark tcl android-file-transfer flux osxfuse

brew install homebrew/fuse/sshfs


###----------------------------------------------------------------------------
### Adobe CS6 Web & Design Premium (4.5GB)
###----------------------------------------------------------------------------
#brew cask install adobe-cs6-design-web-premium


###----------------------------------------------------------------------------
### Post-configuration Steps
###----------------------------------------------------------------------------
echo "Securing ~/.bashrc ..."
chmod 600 "$myBashrc"


###----------------------------------------------------------------------------
### Last-minute Instructions
###----------------------------------------------------------------------------
echo "NOTES:"
echo "  Verify PYTHONPATH: vi ~/.bashrc"
echo "  Verify chruby default version."

###----------------------------------------------------------------------------
### Fin~
###----------------------------------------------------------------------------
exit 0
