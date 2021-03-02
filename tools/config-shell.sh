#!/usr/bin/env zsh
# shellcheck disable=SC1071,SC1091,SC2154

###----------------------------------------------------------------------------
### Variables
###----------------------------------------------------------------------------
theENV="$1"
source './my-vars.env' "$theENV"
gnuSed='/usr/local/opt/gnu-sed/libexec/gnubin/sed'


###----------------------------------------------------------------------------
### Configure the Shell: base options
###----------------------------------------------------------------------------
# Bounce the default theme
"$gnuSed" -i 's/^ZSH_THEME/#ZSH_THEME/g' "$myShellrc"

# Default to NO THEME
"$gnuSed" -i "\|^#ZSH_THEME|a ZSH_THEME=''" "$myShellrc"

# source-in personal zsh configs
"$gnuSed" -i "|^#\ ZSH_CUSTOM| s|^#\ ||g" "$myShellrc"
"$gnuSed" -i "/^ZSH_CUSTOM/ s|/path/to/new-custom-folder|$myZSHExt|g" "$myShellrc"

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

