#!/usr/bin/env bash
# shellcheck disable=SC1091,SC2154

###----------------------------------------------------------------------------
### Variables
###----------------------------------------------------------------------------
theENV="$1"
source './my-vars.env' "$theENV"


###----------------------------------------------------------------------------
### Configure the Shell: base options
###----------------------------------------------------------------------------
# Bounce the default theme
sed -i 's/^ZSH_THEME/#ZSH_THEME/g' "$myShellrc"

# Default to NO THEME
sed -i "\|^#ZSH_THEME|a ZSH_THEME=''" "$myShellrc"

# source-in personal zsh configs
sed -i "|^#\ ZSH_CUSTOM| s|^#\ ||g" "$myShellrc"
sed -i "/^ZSH_CUSTOM/ s|/path/to/new-custom-folder|$myZSHExt|g" "$myShellrc"

cat << EOF >> "$myShellrc"
###############################################################################
###                            OLD BASH SETTINGS                            ###
###############################################################################
source "\$HOME/.config/shell/mystuff.env"
EOF


###----------------------------------------------------------------------------
### Post-configuration Steps
###----------------------------------------------------------------------------
printReq "Securing $myShellrc..."
chmod 600 "$myShellrc"

