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
export myName=$(basename "$0")
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
declare sysPaths='/etc/paths'
declare sysManPaths='/etc/manpaths'


###------------------------------------------------------------------------------
### FUNCTIONS
###------------------------------------------------------------------------------


###----------------------------------------------------------------------------
### Configure the Shell: base options
###----------------------------------------------------------------------------
echo "Configuring base shell options..."

echo "  Configuring $myBashProfile ..."
cat << EOF >> "$myBashProfile"
# URL: https://www.gnu.org/software/bash/manual/bashref.html#Bash-Startup-Files
if [ -f ~/.bashrc ]; then
	. ~/.bashrc
fi

EOF


echo "  Configuring $myBashrc ..."
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
yes | /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

echo "Updating Homebrew..."
brew update

echo "Running 'brew doctor'..."
brew doctor

echo "Tapping Homebrew binaries..."
brew tap homebrew/binary

echo "Current paths:"
cat "$sysPaths"

echo "Current man paths:"
cat "$sysManPaths"

###----------------------------------------------------------------------------
### Set $PATH
###----------------------------------------------------------------------------
# Set new Variables
declare pathHomeBrew="$(brew --prefix)"
declare pathGNU_CORE="$(brew --prefix coreutils)"

# Set path for the GNU Coreutils
sudo sed -i "\|/usr/local/bin|i $pathGNU_CORE/libexec/gnubin" "$sysPaths"

# Set path for the GNU Coreutils Manuals
# FIX: MANPATH: no one seems to reliably know how it works; more later.
sudo sed -i "\|/usr/share/man|i $pathGNU_CORE/libexec/gnuman" "$sysManPaths"

# Verify the new paths have been set
echo "New paths:"
cat "$sysPaths"

echo "New man paths:"
cat "$sysManPaths"

###----------------------------------------------------------------------------
### Configuring some base shell functionality
###----------------------------------------------------------------------------
echo "Configuring basic shell behavior..."
cat << EOF >> "$myBashrc"
###############################################################################
###                                   shell                                 ###
###############################################################################
export MANPATH="\$manGNUCoreUtils:\$manBrewProgs:\$manSystemProgs"
# Filesystem Operational Behavior
function ll { ls -G Al  "\$@" | egrep -v '.(DS_Store|CFUserTextEncoding)'; }
function la { ls -G al  "\$@" | egrep -v '.(DS_Store|CFUserTextEncoding)'; }
function ld { ls -G ld  "\$@" | egrep -v '.(DS_Store|CFUserTextEncoding)'; }
function lh { ls -G alh "\$@" | egrep -v '.(DS_Store|CFUserTextEncoding)'; }
alias cp='cp -vp'
alias mv='mv -v'

EOF

source "$myBashrc" && tail -16 "$myBashrc"


###----------------------------------------------------------------------------
### PYTHON
###----------------------------------------------------------------------------
echo "Installing Python..."
brew install python

echo "Configuring Python..."
cat << EOF >> "$myBashrc"
###############################################################################
###                                  Python                                 ###
###############################################################################
export PYTHONPATH="$pathHomeBrew/lib/python2.7/site-packages"

EOF

source "$myBashrc" && tail -5 "$myBashrc"


###----------------------------------------------------------------------------
### Fin~
###----------------------------------------------------------------------------
exit 0
