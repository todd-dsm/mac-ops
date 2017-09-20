mac-ops
=====

Automation to build a great MBP Desktop with a base configurtion for DevOps people.

Before you can build anything, you first need the tools. `alias mac-ops='phase0';` Take a look at [phase1]

This is just my take on the Mac OS X setup. If you find value in it, please feel free to use it.

***

##Documentation
Before jumping in, you should probably check the [wiki] first. This may not be for you.

***

##Pre-Game
Assuming this is a fresh macOS, run the [install prep] script to:

* Get the latest OS Updates,
* Install the Xcode CLI Tools
* Make sure you have a Github account then attach your public ssh key to the account, and
* Save some details about apps that are currently installed.

```bash
curl -fsSL https://goo.gl/j2y1Dn 2>&1 | bash | tee /tmp/install-prep.out
```

If you need to backup first, check the [rsync-backups] page. The restore process (in this script) relies on a consistent backup ;-)

***

##Kick-off
Once you're all backed-up, auto-magically configure the new macOS:

Make sure you have your ssh keys restored from backup.

Clone the repo down to your laptop:

`git clone git@github.com:todd-dsm/mac-ops.git && cd mac-ops/`

***

# CONFIGURE THE VARIABLES

`vi my-vars.sh`

***

Kick off the script:

`./bootstrap.sh 2>&1 | tee ~/.config/admin/logs/mac-ops-config.out`


***

##Post-Game

 * Import your Terminal profile, if you have one.
 * Finish any outstanding System Preferences configurations.
 * Close all of your windows.
 * Reboot the system

Then you're ready to start.

[phase1]:https://github.com/todd-dsm/process-ph1
[install prep]:https://github.com/todd-dsm/mac-ops/wiki/Install-Prep
[wiki]:https://github.com/todd-dsm/mac-ops/wiki
[rsync-backups]:https://github.com/todd-dsm/rsync-backups
