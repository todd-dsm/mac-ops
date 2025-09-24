#!/usr/bin/env zsh
# shellcheck disable=SC1071,SC1091,SC2154

###----------------------------------------------------------------------------
### Variables
###----------------------------------------------------------------------------
source my-vars.env > /dev/null 2>&1
set -x
ohmyzshMisc="$HOME/.oh-my-zsh/lib/misc.zsh"

###----------------------------------------------------------------------------
### Configure the Shell: base options
###----------------------------------------------------------------------------
# Backup the default file
printf '\n%s\n' "Backing up the $myShellrc file..."
cp "$myShellrc" "${backupDir}/zshrc"

# Bounce the default theme
printf '\n%s\n' "Disabling default theme..."
sed -i '' 's/^ZSH_THEME/#ZSH_THEME/g' "$myShellrc"

# Default to NO THEME
printf '\n%s\n' "Enabling NO theme..."
sed -i '' '/^#ZSH_THEME="robbyrussell"/a\
ZSH_THEME=""
' "$myShellrc"


###----------------------------------------------------------------------------
### Configure: ~/.oh-my-zsh/lib/misc.zsh
###----------------------------------------------------------------------------
cp "$ohmyzshMisc" "${backupDir}/omzsh-misc.zsh"
sed -i '' -e '/PAGER/s/^/#/' -e '/LESS/s/^/#/' "$ohmyzshMisc"


###----------------------------------------------------------------------------
### Post-configuration Steps
###----------------------------------------------------------------------------
printf '\n%s\n' "Securing $myShellrc..."
chmod 600 "$myShellrc"

