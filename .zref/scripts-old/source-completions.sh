#!/usr/bin/env bash

printf '\n%s\n' "Sourcing-in completions for:"

while read -r compFile; do
    printf '%s\n' "  ${compFile##*/}"
    source "$compFile"
done <<< "$(find /usr/local/etc/bash_completion.d -type l)"
