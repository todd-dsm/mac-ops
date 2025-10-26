#!/usr/bin/env bash
# shellcheck disable=SC2034,SC2154
# This is sourced by my-vars.env; these definitions likely won't change.
# -----------------------------------------------------------------------------
# EXEC: source lib/system-vars.sh
# -----------------------------------------------------------------------------
# System-specific variables required before running the automation.
# -----------------------------------------------------------------------------
set -x


# -----------------------------------------------------------------------------
# This stuff rarely-ever changes
# -----------------------------------------------------------------------------
# macOS Build
export myPath=''
export myMans=''
export configDir="${HOME}/.config"
export adminDir="${configDir}/admin"
export shellConfig="${configDir}/shell"
export adminLogs="${adminDir}/logs"
export backup_dir="${adminDir}/backup"
export termDir="${configDir}/term"
export myShellDir="${configDir}/shell"
export sourceDir='sources'
export nvimDir="$configDir/nvim"
export sysShells='/etc/shells'
export gnuSed='/usr/local/opt/gnu-sed/libexec/gnubin/sed'
export gnuDate='/usr/local/opt/coreutils/libexec/gnubin/date'
export host_remote='github.com'
export rawGHContent='https://raw.githubusercontent.com'
export myAnsibleDir="$HOME/.ansible"
export myAnsibleCFG="$myAnsibleDir/ansible.cfg"
export myAnsibleHosts="$myAnsibleDir/hosts"
export termStuff="$myDownloads"
export solarizedGitRepo='git@github.com:altercation/solarized.git'
#------------------------------------------------------------------------------
export myShellProfile="$HOME/.zprofile"
export myShellrc="$HOME/.zshrc"
export myZSHExt="${myShellDir}/environment.zsh"
export myZSHAlias="${myShellDir}/aliases.zsh"
export myZSHFuncts="${myShellDir}/functions.zsh"
export OMZSH="$HOME/.oh-my-zsh"
export myShellEnv="${OMZSH}/custom"
export omzsh_lib="${OMZSH}/lib"
#------------------------------------------------------------------------------
export myGitConfig="$HOME/.gitconfig"
export myGitIgnore="$HOME/.gitignore"
export sysPaths='/etc/paths'
export sysManPaths='/etc/manpaths'
# Vim -------------------------------------------------------------------------
export knownHosts="$HOME/.ssh/known_hosts"
export vimSimpleTag='" vimSimple configuration'
export vimSimpleLocal="$myCode/vimsimple"
export vimSimpleGitRepo='https://github.com/todd-dsm/vimSimple.git'
export pymodConfig="$vimSimpleLocal/vim/bundle/python-mode/plugin/pymode.vim"
export jsonIndent="$vimSimpleLocal/vim/bundle/vim-json/indent/json.vim"
export jsonIndREGEX='" =================$'
export jsonAppendStr='autocmd filetype json set et ts=2 sw=2 sts=2'
export # Configure macOS
export dirScreenshot="$myPics/screens"
export linkScreens="$myDesktop/screens"
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
