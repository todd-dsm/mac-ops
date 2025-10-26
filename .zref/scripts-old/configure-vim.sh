#!/usr/bin/env bash
#------------------------------------------------------------------------------
# PURPOSE: Download and Configure the vimSimple project
#------------------------------------------------------------------------------
# EXECUTE: ./configure-vim.sh
#------------------------------------------------------------------------------
# PREREQS: 1) ssh keys must be on the new system for Github clones
#          2)
#------------------------------------------------------------------------------
#  AUTHOR: todd_dsm
#------------------------------------------------------------------------------
#    DATE: 2017/01/19
#------------------------------------------------------------------------------
set -x

###------------------------------------------------------------------------------
### VARIABLES
###------------------------------------------------------------------------------
declare hostRemote='github.com'
declare knownHosts="$HOME/.ssh/known_hosts"
declare vimSimpleTag='" vimSimple configuration'
declare vimSimpleGitDir="$HOME/code/vimsimple"
declare vimSimpleGitRepo='https://github.com/todd-dsm/vimSimple.git'
declare pymodConfig="$vimSimpleGitDir/vim/bundle/python-mode/plugin/pymode.vim"
declare jsonIndent="$vimSimpleGitDir/vim/bundle/vim-json/indent/json.vim"
declare jsonIndREGEX='" =================$'
declare jsonAppendStr='autocmd filetype json set et ts=2 sw=2 sts=2'


###------------------------------------------------------------------------------
### FUNCTIONS
###------------------------------------------------------------------------------


###------------------------------------------------------------------------------
### MAIN PROGRAM
###------------------------------------------------------------------------------
### Add the Github key to the knownhosts file
###---
printf '\n%s\n\n' "Adding the Github public key to our known_hosts file..."
ssh-keyscan -t 'rsa' "$hostRemote" >> "$knownHosts"


###---
### Pull the code
###---
printf '\n%s\n\n' "Pulling the vimSimple repo..."
git clone --recursive -j10 "$vimSimpleGitRepo" "$vimSimpleGitDir"

### Make softlinks to the important files
printf '\n%s\n\n' "Creating softlinks for ~/.vim and ~/.vimrc"
ln -s "$vimSimpleGitRepo/vimrc" .vimrc
ln -s "$vimSimpleGitRepo/vim"   .vim


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
### Remove the Github Remote Host Key
###----------------------------------------------------------------------------
printf '\n%s\n' "Removing the $hostRemote public key from our known_hosts file..."
ssh-keygen -f "$knownHosts" -R "$hostRemote"


###----------------------------------------------------------------------------
### Fin~
###----------------------------------------------------------------------------
exit 0
