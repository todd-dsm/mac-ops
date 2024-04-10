#!/usr/bin/env zsh
# shellcheck disable=SC1071,SC1091,SC2154

###----------------------------------------------------------------------------
### Variables
###----------------------------------------------------------------------------
source my-vars.env > /dev/null 2>&1
ohmyzshMisc="$HOME/.oh-my-zsh/lib/misc.zsh"


###----------------------------------------------------------------------------
### Configure the Shell: base options
###----------------------------------------------------------------------------
# Backup the default file
printf '\n%s\n' "Backing up the $myShellrc file..."
cp "$myShellrc" "${backupDir}/zshrc"

# Bounce the default theme
printf '\n%s\n' "Disabling default theme..."
"$gnuSed" -i 's/^ZSH_THEME/#ZSH_THEME/g' "$myShellrc"

# Default to NO THEME
printf '\n%s\n' "Enabling NO theme..."
"$gnuSed" -i "\|^#ZSH_THEME|a ZSH_THEME=''" "$myShellrc"


###----------------------------------------------------------------------------
### Configure: ~/.oh-my-zsh/lib/misc.zsh
###----------------------------------------------------------------------------
"$gnuSed" -i '/PAGER\|LESS/ s/^/#/g' "$ohmyzshMisc"


###----------------------------------------------------------------------------
### Post-configuration Steps
###----------------------------------------------------------------------------
printf '\n%s\n' "Securing $myShellrc..."
chmod 600 "$myShellrc"

