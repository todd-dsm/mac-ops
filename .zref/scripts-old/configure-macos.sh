#!/usr/bin/env bash
#------------------------------------------------------------------------------
# PURPOSE: Configure macOS with these default Settings.
#------------------------------------------------------------------------------
# EXECUTE: ./configure-macos.sh
#------------------------------------------------------------------------------
# PREREQS: 1)
#          2)
#------------------------------------------------------------------------------
#  AUTHOR: todd_dsm
#------------------------------------------------------------------------------
#    DATE: 2017/01/19
#------------------------------------------------------------------------------
#set -x

###----------------------------------------------------------------------------
### VARIABLES
###----------------------------------------------------------------------------
declare theENV='TEST'
# Configure macOS
if [[ "$theENV" == 'TEST' ]]; then
    declare myHostName='macos.ptest.us'
else
    declare myHostName='tbook.ptest.us'
fi
declare dirScreenshot="$HOME/Pictures/screens"
declare linkScreens="$HOME/Desktop/screens"


###----------------------------------------------------------------------------
### FUNCTIONS
###----------------------------------------------------------------------------


###----------------------------------------------------------------------------
### MAIN PROGRAM
###----------------------------------------------------------------------------
### Configure the System
###---
printf '\n%s\n' "Configuring the System:"

###---
###  Set the hostname(s)
###---
printf '%s\n' "  Configuring the hostname(s)..."
### Configure the network hostname
printf '%s\n' "  Configuring network hostname..."
sudo scutil --set ComputerName "$myHostName"

### Configure the Terminal hostname
printf '%s\n' "  Configuring Terminal hostname..."
sudo scutil --set HostName "${myHostName%%.*}"

### Configure the AirDrop hostname
printf '%s\n' "  Configuring AirDrop hostname..."
sudo scutil --set LocalHostName "${myHostName%%.*}"


###---
### Storage
###---
printf '\n%s\n' "Configuring Storage:"
printf '%s\n' "  Save to disk by default (not to iCloud)..."
# defaults read NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false
defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false


###---
### Disable smart quotes and dashes system-wide
###---
printf '\n%s\n' "Disabling smart quotes and dashes system-wide:"
### Disable smart quotes
printf '%s\n' "  Disabling smart quotes..."
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false
### Disable smart dashes
printf '%s\n' "  Disabling smart dashes..."
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false


###----------------------------------------------------------------------------
### The Finder
###----------------------------------------------------------------------------
### Display all folders in List View
###---
printf '\n%s\n' "Setting Finder Preferences:"
printf '%s\n'     "  Display all windows in List View..."
defaults write com.apple.finder FXPreferredViewStyle Nlsv


###---
### Enable sidebar directories
###---
# Add $HOME
printf '%s\n'     "  Adding \$HOME to sidebar..."
sfltool add-item com.apple.LSSharedFileList.FavoriteItems "file:///$HOME"
# Add Pictures
printf '\n%s\n'     "  Adding Pictures to sidebar..."
sfltool add-item com.apple.LSSharedFileList.FavoriteItems "file:///$HOME/Pictures"
# Add Music
printf '\n%s\n'     "  Adding Music to sidebar..."
sfltool add-item com.apple.LSSharedFileList.FavoriteItems "file:///$HOME/Music"
# Add Movies
printf '\n%s\n'     "  Adding Movies to sidebar..."
sfltool add-item com.apple.LSSharedFileList.FavoriteItems "file:///$HOME/Movies"


###---
### New window displays home
###---
printf '%s\n' "  Display the home directory by default..."
defaults write com.apple.finder NewWindowTarget -string "PfLo"
defaults write com.apple.finder NewWindowTargetPath -string "file://${HOME}/"


###---
### Show status bar in Finder
###---
printf '%s\n' "  Display status bar in Finder..."
defaults write com.apple.finder ShowStatusBar -bool true


###---
### Search the current folder by default
###---
printf '%s\n' "  Search the current folder by default..."
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"


###---
### Display all file extensions in Finder
###---
printf '%s\n' "  Display all extensions by default..."
defaults write NSGlobalDomain AppleShowAllExtensions -bool true


###---
### Screenshot behavior
###---
printf '%s\n' "  Save screenshots to a specified location..."
if [[ ! -d "$dirScreenshot" ]]; then
    mkdir -p "$dirScreenshot"
    defaults write com.apple.screencapture location "$dirScreenshot"
fi

### Create a softlink on the Desktop
if [[ ! -h "$linkScreens" ]]; then
    ln -s "$dirScreenshot" "$linkScreens"
fi

### Set screenshots without window shadows
printf '%s\n' "  Save screenshots without window shadows..."
defaults write com.apple.screencapture disable-shadow -bool true

###---
### Show battery percentage
###---
printf '%s\n' "  Show battery percentage..."
# defaults read com.apple.menuextra.battery ShowPercent
defaults write com.apple.menuextra.battery ShowPercent -string 'YES'


###---
### Display Date/Time formatted: 'EEE MMM d  h:mm a'
###---
printf '%s\n' "  Display Day HH:MM AM format..."
defaults write com.apple.menuextra.clock 'DateFormat' -string 'EEE MMM d  h:mm a'


###---
### Network Shares
###---
printf '%s\n' "  Do NOT create .DS_Store files on network volumes..."
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true


###---
### Dialog Box behavior
###---

### The Save Dialog Box
printf '%s\n' "  Expand Save panel by default..."
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true


### The Print Dialog Box [TEST]
printf '%s\n' "  Expand Print panel by default..."
# defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true
# defaults write NSGlobalDomain PMPrintingExpandedStateForPrint2 -bool true


###----------------------------------------------------------------------------
### The Dock
###----------------------------------------------------------------------------
printf '\n%s\n' "Setting Dock Preferences:"
printf '%s\n' "  Display The Dock at 46px..."
# Set default Tile Size to 42px
defaults write com.apple.dock tilesize 42

### Auto-Hide the Dock
printf '%s\n' "  Auto-hide The Dock..."
defaults write com.apple.dock autohide -bool true

### Optionally: adjust timing with these settings
#defaults write com.apple.dock autohide-delay -float 0
#defaults write com.apple.dock autohide-time-modifier -float 0


###----------------------------------------------------------------------------
### Configure Basic OS Security
###----------------------------------------------------------------------------
printf '\n%s\n' "Configuring Basic OS Security:"

###---
### Disable Guest User at the Login Screen
###---
printf '%s\n' "  Disable Guest User at the Login Screen..."
sudo defaults write /Library/Preferences/com.apple.loginwindow GuestEnabled -bool NO
# sudo defaults read /Library/Preferences/com.apple.loginwindow GuestEnabled
# OUTPUT: 0


###---
### Apple File Protocol
###---
printf '%s\n' "  Disable AFP Guest Access..."
defaults write com.apple.AppleFileServer.plist AllowGuestAccess -int 0


###----------------------------------------------------------------------------
### Configure Application Behavior
###----------------------------------------------------------------------------
printf '\n%s\n\n' "Configuring Application Preferences:"

###---
### TextEdit
###---
printf '%s\n' "  TextEdit Preferences: before:"
defaults read com.apple.TextEdit

# Set Author Name
printf '%s\n' "  Setting autor name..."
defaults write com.apple.TextEdit author 'Todd E Thomas' # FIX
# Use plain text not RichText
printf '%s\n' "  Use plain text by default..."
defaults write com.apple.TextEdit RichText -int 0
# Set Font
printf '%s\n' "  We'll use Courier as the font..."
defaults write com.apple.TextEdit NSFixedPitchFont 'Courier'
# Set Font Size
printf '%s\n' "  Courier is set to 14pt..."
defaults write com.apple.TextEdit NSFixedPitchFontSize -int 14
# Default Window Size
printf '%s\n' "  New Windows will open at H:45 x W:100..."
defaults write com.apple.TextEdit WidthInChars -int 100
defaults write com.apple.TextEdit HeightInChars -int 45
# Disable SmartDashes and SmartQuotes
printf '%s\n' "  Disabling SmartDashes and SmartQuotes..."
defaults write com.apple.TextEdit SmartDashes -int 0
defaults write com.apple.TextEdit SmartQuotes -int 0

printf '\n%s\n' "  TextEdit Preferences: after:"
defaults read com.apple.TextEdit


###---
### Stop Photos from opening automatically when plugging in iPhone
###---
printf '%s\n' "  Stop Photos from opening automatically..."
defaults -currentHost write com.apple.ImageCapture disableHotPlug -bool true


###----------------------------------------------------------------------------
### Fin~
###----------------------------------------------------------------------------
exit 0
