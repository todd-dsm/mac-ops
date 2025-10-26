# -------------------------------------|------------------------------------- #
#                                   Packer                                    #
# --------------------------------------------------------------------------- #
complete -o nospace -C /opt/homebrew/bin/packer packer
export PACKER_LOG='yes'
export PACKER_LOG_PATH='/tmp/packer.log'
export PACKER_NO_COLOR='yes'
# Parameters supporting local builds
#export PACKER_HOME="$HOME/vms/packer"
#export PACKER_CONFIG="$PACKER_HOME"
#export PACKER_CACHE_DIR="$PACKER_HOME/iso-cache"
#export PACKER_BUILD_DIR="$PACKER_HOME/builds"
