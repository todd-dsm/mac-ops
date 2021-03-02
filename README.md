# mac-ops

=====

Automation to build a great MBP with a base configurtion for DevOps. Before you can build anything, you first need the tools.

This needs refactoring but its still better than starting from scratch. If you find value in it, please feel free to fork/use it.

***

## Documentation

Before jumping in, you should probably check the [wiki] first. This may not be for you.

***

## Pre-Game

Assuming this is a fresh macOS, run the [install prep] script to:

* Get the latest OS Updates,
* Install the Xcode CLI Tools
* Make sure you have a Github account then attach your public ssh key to the account, and
* Save some details about apps that are currently installed.

```zsh
curl -fsSL  t.ly/TuKH  2>&1 | zsh | tee /tmp/install-prep.out
```

If you need to backup first, check the [rsync-backups] page. The restore process in the `bootstrap.sh` script relies on a consistent backup ;-)

***

## Kick-off

Once you're all backed-up, auto-magically configure the new macOS:

Make sure you have your ssh keys restored from backup.

Clone the repo down to your laptop:

`git clone git@github.com:todd-dsm/mac-ops.git && cd mac-ops/`

***

## CONFIGURE THE VARIABLES

`vi my-vars.env`

***

Kick off the script:

`./bootstrap.sh TEST 2>&1 | tee ~/.config/admin/logs/mac-ops-config.out`

*NOTE: remove the argument "TEST" when you're ready.*

***

## Post-Game

Configure the shell

`tools/config-shell.sh TEST`

* Import your Terminal profile, if you have one.
* Finish any outstanding System Preferences configurations.
* Close all of your windows.
* Reboot the system

Then you're ready to start working.

[phase1]:https://github.com/todd-dsm/process-ph1
[install prep]:https://github.com/todd-dsm/mac-ops/wiki/Install-Prep
[wiki]:https://github.com/todd-dsm/mac-ops/wiki
[rsync-backups]:https://github.com/todd-dsm/rsync-backups
