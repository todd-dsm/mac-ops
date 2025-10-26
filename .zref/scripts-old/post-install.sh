#!/usr/bin/env bash
#------------------------------------------------------------------------------
# PURPOSE: Post-install/reboot Installations and Confurations.
#------------------------------------------------------------------------------
# EXECUTE: ./post-install.sh
#------------------------------------------------------------------------------
#  AUTHOR: todd_dsm
#------------------------------------------------------------------------------
#    DATE: 2017/01/13
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
declare binPython="$(type -P python)"
#declare vsnPython="$(python --version)"
declare binPip="$(type -P pip)"
declare vsnPip="$(pip --version)"
#declare myBashProfile="$HOME/.bash_profile"
declare myBashrc="$HOME/.bashrc"
#declare sysPaths='/etc/paths'
#declare sysManPaths='/etc/manpaths'


###------------------------------------------------------------------------------
### FUNCTIONS
###------------------------------------------------------------------------------


###----------------------------------------------------------------------------A
### Verifications
###----------------------------------------------------------------------------
echo "Before we get started:"
echo "    PYTHONPATH : $PYTHONPATH"
echo "    Python Bin : $binPython"
echo "    Python Vers: python --version"
            python --version
echo "    Pip Bin    : $binPip"
echo "    Pip Version: $vsnPip"


###----------------------------------------------------------------------------
### PYTHON: pip and setuptools
###----------------------------------------------------------------------------
echo "Upgrading Python Pip and setuptools..."
pip install --upgrade pip setuptools


###----------------------------------------------------------------------------
### Ansible
###----------------------------------------------------------------------------
echo "Installing Ansible..."
pip install --upgrade ansible

echo "Ansible Version Info:"
ansible --version

echo "Configuring Ansible..."
cat << EOF >> "$myBashrc"
###############################################################################
###                                  Ansible                                ###
###############################################################################
export ANSIBLE_CONFIG="\$HOME/.ansible"

EOF

echo "Creating the Ansible directory..."
mkdir -p "$HOME/.ansible/roles"
touch $HOME/.ansible/{ansible.cfg,hosts}

###----------------------------------------------------------------------------
### Amazon AWS CLI
###----------------------------------------------------------------------------
echo "Installing the AWS CLI..."
pip install awscli

echo "Installing the AWS CLI Utilitiese..."
pip install --upgrade jmespath jmespath-terminal

echo "Setting the AWS User to your local account name..."
sed -i "/AWS_PROFILE/ s/awsUser/$USER/g" "$myBashrc"

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
       c) Uncomment this line
       d) Write the file and Quit: :wq
       e) Source-in the changes: source ~/.bashrc
"""
printf '%s\n' """
    2) Maybe some other stuff...

"""


###----------------------------------------------------------------------------
### Fin~
###----------------------------------------------------------------------------
exit 0
