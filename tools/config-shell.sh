#!/usr/bin/env zsh
# shellcheck disable=SC1071,SC1091,SC2154

###----------------------------------------------------------------------------
### Variables
###----------------------------------------------------------------------------
source './my-vars.env' > /dev/null 2>&1
ohmyzshMisc="$HOME/.oh-my-zsh/lib/misc.zsh"
gnuSed='/usr/local/opt/gnu-sed/libexec/gnubin/sed'

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

# source-in personal zsh configs
printf '\n%s\n' "Adding path to ZSH_CUSTOM settings..."
"$gnuSed" -i "/^#\ ZSH_CUSTOM/ s|^#\ ||g" "$myShellrc"
"$gnuSed" -i "/^ZSH_CUSTOM/ s|/path/to/new-custom-folder|$myZSHExt|g" "$myShellrc"


###----------------------------------------------------------------------------
### Configure: ~/.oh-my-zsh/lib/misc.zsh
###----------------------------------------------------------------------------
"$gnuSed" -i '/PAGER\|LESS/ s/^/#/g' "$ohmyzshMisc"


###----------------------------------------------------------------------------
### Post-configuration Steps
###----------------------------------------------------------------------------
printf '\n%s\n' "Securing $myShellrc..."
chmod 600 "$myShellrc"

