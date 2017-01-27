#!/usr/bin/env bash
# PURPOSE:  This script finds all large files that do not fit the prune
#           parameters; also, these files and directories are omitted from
#           normal backups:
#             * ~/.docker
#             * ~/.docker-volumes
#             * ~/Downloads/isos
#set -ux

printf '\n%s\n' "Finding files +40MB but not more than 100MB..."
find "$HOME"    \
    -name '*Pictures*' -prune , -name '*Library*' -prune , \
    -name '*Music*' -prune , -name '*vms*' -prune , \
    -type f -size +40M -size -100M \
    -exec ls -lh {} \; | awk '{ print $5 ": " $9 }'


printf '\n%s\n' "Finding  the big files +1GB..."
find "$HOME"    \
    -name '*Pictures*' -prune , -name '*Library*' -prune , \
    -name '*Music*' -prune , -name '*vms*' -prune , \
    -type f -size +10G \
    -exec ls -lh {} \; | awk '{ print $5 ": " $9 }'


