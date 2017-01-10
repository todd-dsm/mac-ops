#!/usr/bin/env bash
#------------------------------------------------------------------------------
# PURPOSE: Configure a base environment to get back to work quickly.
#------------------------------------------------------------------------------
# EXECUTE: curl -Lo- https://goo.gl/IjzNwV | bash | tee -ai mymac.log
# EXECUTE: curl -Lo- https://goo.gl/mQwC09 | bash | tee -ai mymac.log OLD
#------------------------------------------------------------------------------
#  AUTHOR: todd_dsm
#------------------------------------------------------------------------------
#    DATE: 2015/07/11
#------------------------------------------------------------------------------
#set -x

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


###---
### The 'Where'
###---
#if [[ "$USER" = 'vagrant' ]]; then
#    export myLoc='/vagrant'            # For a 'vagrant'  install'
#else
#    export myLoc="$PWD"                # For a 'standard' install'
#fi


###---
### Verify the payload before beginning
###---
#if [[ ! -d "$myLoc/payload" ]]; then
#    echo "Something's gone wrong; there is no payload, exiting."
#    exit 1
#else
#    echo "We will be executing from $myLoc"
#fi


###------------------------------------------------------------------------------
### VARIABLES
###------------------------------------------------------------------------------
declare myBashProfile="$HOME/.bash_profile"
declare myBashrc="$HOME/.bashrc"


###------------------------------------------------------------------------------
### FUNCTIONS
###------------------------------------------------------------------------------
#source "$instLib/start.sh"
#source "$instLib/finish.sh"
#source "$instLib/printfmsg.sh"


###----------------------------------------------------------------------------
### Configure the Shell: base options
###----------------------------------------------------------------------------
echo "Configuring base shell options..."

cat << EOF >> "$myBashProfile"
# URL: https://www.gnu.org/software/bash/manual/bashref.html#Bash-Startup-Files
if [ -f ~/.bashrc ]; then . ~/.bashrc; fi

EOF


cat << EOF >> "$myBashrc"
###############################################################################
###                                  System                                 ###
###############################################################################
export HISTFILESIZE=
export HISTSIZE=
export PROMPT_COMMAND='history -a'
export HISTCONTROL=ignoredups
export HISTTIMEFORMAT="%a%l:%M %p  "
export HISTIGNORE='ls:bg:fg:history'

EOF


###----------------------------------------------------------------------------
### Install Homebrew
###----------------------------------------------------------------------------
echo "Installing Homebrew..."
ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

echo "Updating Homebrew..."
brew update

echo "Running 'brew doctor'..."
brew doctor

echo "Tapping Homebrew binaries..."
brew tap homebrew/binary


###----------------------------------------------------------------------------
### Prep for Homebrew: GNU Core Utils
###----------------------------------------------------------------------------
echo "Prepping for brewed GNU Core Utils..."

cat << EOF >> "$myBashrc"
###############################################################################
###                                 Homebrew                                ###
###############################################################################
export PATH="\$(brew --prefix coreutils)/libexec/gnubin:/usr/local/bin:\$PATH"
export MANPATH="\$(brew --prefix coreutils)/libexec/gnuman:$MANPATH"

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

EOF

source "$myBashrc" && tail -7 "$myBashrc"


###----------------------------------------------------------------------------
### Install GNU Tools and Languages
###----------------------------------------------------------------------------
echo "Installing and configuring GNU Tools..."
brew install ed --default-names
brew install gnu-sed --with-default-names
brew install gawk
brew install gnu-indent --with-default-names
brew install psgrep
brew install findutils --with-default-names
brew install gnu-which --with-default-names
brew install watch
brew install tree
brew install wget
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

EOF

source "$myBashrc" && tail -7 "$myBashrc"


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

source "$myBashrc" && tail -4 "$myBashrc"


###----------------------------------------------------------------------------
### Bash
###----------------------------------------------------------------------------
echo "Installing Bash..."
brew install bash

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

EOF

source "$myBashrc" && tail -5 "$myBashrc"


###----------------------------------------------------------------------------
### Vim: The Power and the Glory
###----------------------------------------------------------------------------
# Verify before install
echo "The Apple version of Vim:"
vim --version | egrep --color 'VIM|Compiled|python|ruby|perl|tcl'

echo "Installing and configuring Vim..."
brew install vim --override-system-vim --with-features=huge --disable-nls --enable-interp=tcl,lua,ruby,perl,python


cat << EOF >> "$myBashrc"
###############################################################################
###                                   Vim                                   ###
###############################################################################
export EDITOR='/usr/local/bin/vim'
alias vi='/usr/local/bin/vim'
alias vim='/usr/local/bin/vim'

EOF

source "$myBashrc" && tail -6 "$myBashrc"


# Verify after install
echo "The Real version of Vim:"
vim --version | egrep --color 'VIM|Compiled|python|ruby|perl|tcl'


###----------------------------------------------------------------------------
### HashiCorp: Packer
###----------------------------------------------------------------------------
# Homebrew is occasionally a version behind. Just download it from the site.

packerDownloads="$(stat -f ~/Downloads/packer_0/)" &> /dev/null
if [[ ! -z "$packerDownloads" ]]; then
    echo "Installing Packer..."
    mkdir -p "$HOME/.packer"
    mv "$packerDownloads/*" "$HOME/.packer/"
else
    echo "You forgot to download Packer; do that while I finish:"
    echo "    https://packer.io/downloads.html"
fi


echo "Configuring Packer..."
cat << EOF >> "$myBashrc"
###############################################################################
###                                  Packer                                 ###
###############################################################################
export PACKER_LOG='yes'
export PACKER_CACHE_DIR='/tmp/packer_cache'
export PACKER_LOG_PATH='/tmp/packer.log'

EOF

source "$myBashrc" && tail -7 "$myBashrc"


###----------------------------------------------------------------------------
### HashiCorp: Vagrant
###----------------------------------------------------------------------------
# Homebrew is occasionally a version behind. Just download it from the site.

echo "Configuring Vagrant..."
cat << EOF >> "$myBashrc"
###############################################################################
###                                 Vagrant                                 ###
###############################################################################
export VAGRANT_HOME="\$HOME/vms/vagrant/"
#export VAGRANT_LOG=debug

EOF

source "$myBashrc" && tail -6 "$myBashrc"


###----------------------------------------------------------------------------
### Nginx
###----------------------------------------------------------------------------
echo "Installing and configuring Nginx..."
brew install nginx --with-debug --with-spdy

cat << EOF >> "$myBashrc"
###############################################################################
###                                  Nginx                                  ###
###############################################################################
alias docroot='cd /usr/local/var/www'

EOF

source "$myBashrc" && tail -5 "$myBashrc"


###----------------------------------------------------------------------------
### Open the Cask Room / Install sshfs
###----------------------------------------------------------------------------
echo "Opening up the cask room..."

brew install caskroom/cask/brew-cask


###----------------------------------------------------------------------------
### Useful System Utilities
###----------------------------------------------------------------------------
echo "Installing some system utilities..."

brew install git nmap ssh-copy-id gnupg
brew reinstall wget --with-iri


###----------------------------------------------------------------------------
### sshfs
###----------------------------------------------------------------------------
brew cask search sshfs
brew cask install sshfs


###----------------------------------------------------------------------------
### MariaDB
###----------------------------------------------------------------------------
echo "Installing and configuring MariaDB..."
brew install mariadb --with-tests --with-local-infile

cat << EOF >> "$myBashrc"
###############################################################################
###                                 MariaDB                                 ###
###############################################################################
export MARIADB_TCP_PORT='3306'

EOF

source "$myBashrc" && tail -5 "$myBashrc"

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
