#!/usr/bin/env zsh
# shellcheck disable=SC1071,SC1091,SC2154

###----------------------------------------------------------------------------
### Variables
###----------------------------------------------------------------------------
source my-vars.env > /dev/null 2>&1
source lib/printer.func > /dev/null 2>&1
omzsh_misc="${omzsh_lib}/misc.zsh"


###----------------------------------------------------------------------------
### Configure the Shell: base options
###----------------------------------------------------------------------------
print_goal "Configure Shell Basic Options"

# Backup the default file
print_req "Backing up the $myShellrc file..."
cp -v "$myShellrc" "${backup_dir}/zshrc"

# Bounce the default theme
print_info "Disabling the default theme..."
sed -i '' 's/^ZSH_THEME=/# &/' "$myShellrc"

# Add new empty line after it
sed -i '' '/^# ZSH_THEME=/a\
ZSH_THEME=""
' "$myShellrc"


###----------------------------------------------------------------------------
### Configure: ~/.oh-my-zsh/lib/misc.zsh
###   THIS DOESN'T APPEAR TO BE NECESSARY ANY MORE
###----------------------------------------------------------------------------
#print_req "Configuring the default pager..."
#sed -i'' '/PAGER\|LESS/ s/^/#/' "$omzsh_misc"


###----------------------------------------------------------------------------
### Post-configuration Steps
###----------------------------------------------------------------------------
print_req "Securing $myShellrc..."
chmod 600 "$myShellrc"

