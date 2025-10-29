#!/usr/bin/env zsh
# shellcheck disable=SC2317
#  PURPOSE: Detect truly unused exported variables in mac-ops project
# -----------------------------------------------------------------------------
#  PREREQS: a) ZSH 5.9 or later
#           b) lib/printer.func file must be available in the lib/ directory
#           c) Oh My ZSH environment (macOS)
# -----------------------------------------------------------------------------
#  EXECUTE: tools/find-unused-vars.zsh
# -----------------------------------------------------------------------------
set -eu
setopt pipefail

###----------------------------------------------------------------------------
### VARIABLES
###----------------------------------------------------------------------------
### ENV Stuff
configFiles=("my-vars.env" "lib/system-vars.env")
searchPaths=("ansible/" "tools/" "bootstrap.sh")
reportFile='/tmp/key-removal'

### Data
unusedCount=0
declare -a unusedVars=()
allVars=""

###----------------------------------------------------------------------------
### FUNCTIONS
###----------------------------------------------------------------------------
### Use this while developing
function pMsg() {
    theMessage="$1"
    printf '%s\n' "$theMessage"
}

### Loads print functions: print_goal, print_req, print_pass, print_error
source lib/printer.func

###----------------------------------------------------------------------------
### MAIN PROGRAM
###----------------------------------------------------------------------------
### Announce the goal
###---
print_goal "Detecting unused exported variables in the project"

###---
### Verify configuration files exist
###---
print_req "Verifying configuration files exist..."

for configFile in "${configFiles[@]}"; do
    if [[ ! -f "$configFile" ]]; then
        print_error "Configuration file not found: $configFile"
        exit 1
    fi
done

print_pass

###---
### Extract all exported variable names from config files
###---
print_req "Extracting exported variables from: ${configFiles[*]}"

allVars=$(grep -hv "^[[:space:]]*#" "${configFiles[@]}" | \
          grep "^[[:space:]]*export " | \
          sed 's/^[[:space:]]*export[[:space:]]*//' | \
          cut -d'=' -f1 | \
          sort -u)

if [[ -z "$allVars" ]]; then
    print_error "No exported variables found in configuration files"
    exit 1
fi

print_pass

###---
### Report number of variables found
###---
totalVars=$(echo "$allVars" | wc -l | tr -d ' ')
print_req "Found $totalVars exported variables to analyze"
print_pass

###---
### Initialize report file with header
###---
print_req "Initializing report file: $reportFile"

{
    printf '%s\n' "# Unused Variables Report"
    printf '%s\n' "# Generated: $(date)"
    printf '%s\n' ""
    printf '%s\n' "# Checking variables from: ${configFiles[*]}"
    printf '%s\n' "# Searching in: ${searchPaths[*]}"
    printf '%s\n' ""
    printf '%s\n' "# Analyzing variables..."
    printf '%s\n' ""
} > "$reportFile"

print_pass

###---
### Check each variable for usage in search paths
###---
print_req "Searching for variable usage in: ${searchPaths[*]}"

while IFS= read -r var; do
    # Skip empty lines
    if [[ -z "$var" ]]; then
        continue
    fi

    # Search for usage patterns:
    #   $var or ${var} - Direct shell usage
    #   ansible_env.var - Ansible template usage
    if ! grep -rq "\$${var}\|ansible_env\.${var}" "${searchPaths[@]}" 2>/dev/null; then
        unusedVars+=("$var")
        ((unusedCount++)) || true
    fi
done <<< "$allVars"

print_pass

###---
### Write results to report file
###---
print_req "Writing results to report..."

if [[ $unusedCount -gt 0 ]]; then
    {
        printf '%s\n' "# The following variables are defined but never used:"
        printf '%s\n' ""
        for var in "${unusedVars[@]}"; do
            printf '%s\n' "$var"
        done
    } >> "$reportFile"
else
    printf '%s\n' "# All variables are in use!" >> "$reportFile"
fi

{
    printf '%s\n' ""
    printf '%s\n' "# Total unused variables: $unusedCount"
    printf '%s\n' "# Total checked variables: $totalVars"
} >> "$reportFile"

print_pass

###---
### Display summary
###---
print_req "Analysis complete!"
printf '\n%s\n' "  Total variables checked: $totalVars"
printf '%s\n' "  Unused variables found: $unusedCount"
printf '%s\n' "  Report location: $reportFile"
printf '\n'

###---
### fin~
###---
exit 0
