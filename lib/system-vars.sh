#!/usr/bin/env bash
# shellcheck disable=SC2034,SC2154
# WE'RE EITHER TESTING OR WE AINT: IF NOT 'TEST' THEN 'LIVE' IS ASSUMED.
# -----------------------------------------------------------------------------
# EXEC: source my-vars.env <TEST|[no-argument]>
# -----------------------------------------------------------------------------
# User-specific variables required before running the automation.
# WARNING: YOU MUST SET THESE VARIABLES FIRST. DO NOT RUN bootstrap.sh WITHOUT
#          HAVING CONFIGURED THESE PARAMETERS.
# -----------------------------------------------------------------------------
# FIXME:
# 1) restores are disabled for now; in a time pinch.
# 2) add options for everything
# -----------------------------------------------------------------------------
set -x

# -----------------------------------------------------------------------------
# This stuff rarely-ever changes
# -----------------------------------------------------------------------------
# macOS Build
myPath=''
myMans=''
configDir="${HOME}/.config"
adminDir="${configDir}/admin"
shellConfig="${configDir}/shell"
adminLogs="${adminDir}/logs"
backupDir="${adminDir}/backup"
termDir="${configDir}/term"
myShellDir="${configDir}/shell"
sourceDir='sources'
nvimDir="$configDir/nvim"
sysShells='/etc/shells'
gnuSed='/usr/local/opt/gnu-sed/libexec/gnubin/sed'
gnuDate='/usr/local/opt/coreutils/libexec/gnubin/date'
hostRemote='github.com'
rawGHContent='https://raw.githubusercontent.com'
myAnsibleDir="$HOME/.ansible"
myAnsibleCFG="$myAnsibleDir/ansible.cfg"
myAnsibleHosts="$myAnsibleDir/hosts"
termStuff="$myDownloads"
solarizedGitRepo='git@github.com:altercation/solarized.git'
#------------------------------------------------------------------------------
myShellProfile="$HOME/.zprofile"
myShellrc="$HOME/.zshrc"
myZSHExt="${myShellDir}/environment.zsh"
myZSHAlias="${myShellDir}/aliases.zsh"
myZSHFuncts="${myShellDir}/functions.zsh"
myShellEnv="$HOME/.oh-my-zsh/custom"
#------------------------------------------------------------------------------
myGitConfig="$HOME/.gitconfig"
myGitIgnore="$HOME/.gitignore"
sysPaths='/etc/paths'
sysManPaths='/etc/manpaths'
# Configure Vim
knownHosts="$HOME/.ssh/known_hosts"
vimSimpleTag='" vimSimple configuration'
vimSimpleLocal="$myCode/vimsimple"
vimSimpleGitRepo='https://github.com/todd-dsm/vimSimple.git'
pymodConfig="$vimSimpleLocal/vim/bundle/python-mode/plugin/pymode.vim"
jsonIndent="$vimSimpleLocal/vim/bundle/vim-json/indent/json.vim"
jsonIndREGEX='" =================$'
jsonAppendStr='autocmd filetype json set et ts=2 sw=2 sts=2'
# Configure macOS
dirScreenshot="$myPics/screens"
linkScreens="$myDesktop/screens"
set +x

# Test the last variable
if [[ -z "$linkScreens" ]]; then
    printf '%s\n' "Crap! something is jacked."
    exit 1
else
    printf '\n%s\n' """
    Backup/Restores are temporarily disabled but...
    Initial configs look good. Let's do this!
    """
fi

