# mac-ops - Sonoma

## DO NOT USE - THIS IS PEAK BROKEN!

> The rebirth begins with Sequoia (macOS v15.x); ***start there***.

---

Before you can build anything, you first need the tools. Herein lies automation to build a great (opinionated) MBP with a base configuration to support **_Systems Engineering_** (SRE/DevOps) work.

This always needs refactoring but it's still better than starting from scratch. If you find value in it, please feel free to fork/use it.

## Attention! This may not be for you.

## Documentation

Before jumping in, you should probably check the docs in the [wiki] first.

If this is your _personal_ laptop that also serves as your work machine, a backup procedure is strongly recommended; check the [rsync-backups] page. The restore process in the `bootstrap.sh` script relies on a consistent backup. If this is a new `macOS` laptop/install for work, you can safely skip the `rsync` step.

***

## Pre-Game

Make sure the ssh keys associated with your GitHub account work as expected:

```shell
% ssh -T git@github.com
Hi yourUserName! You've successfully authenticated, but GitHub does not provide shell access.
```

Clone the repo down to your laptop:

`git clone git@github.com:todd-dsm/mac-ops.git && cd mac-ops/`

### CONFIGURE _YOUR_ VARIABLES

`vi my-vars.env`

***

Assuming this is a fresh macOS, run the [install prep] script to:
* Get the latest OS Updates
* Configure `sudo` _properly_
* Installs include:
  * Homebrew
    * The Xcode CLI Tools are installed as a dependency
  * The GNU variants of common programs (`sed`, `bash`, `find`, `awk`, etc.)
    * Configures the system to
      * favor the GNU programs.
      * display man pages for these programs
* Afterwards, the install log is saved with some other app-related details.

```shell
tools/install-prep.sh 2>&1 | tee /tmp/install-prep.out
```

When it's all over, you will see something like:

```shell
         __                                     __
  ____  / /_     ____ ___  __  __   ____  _____/ /_
 / __ \/ __ \   / __ `__ \/ / / /  /_  / / ___/ __ \
/ /_/ / / / /  / / / / / / /_/ /    / /_(__  ) / / /
\____/_/ /_/  /_/ /_/ /_/\__, /    /___/____/_/ /_/
                        /____/                       ....is now installed!
```

To back out of the new Oh My ZSH shell just press: `CTRL+d`

The messages should advise you to reboot.

***

## Kick-off

Once you're all backed-up, auto-magically configure the new macOS.

Kick off the script: (`~32` minutes to complete)

`./bootstrap.sh TEST 2>&1 | tee ~/.config/admin/logs/mac-ops-config.out`

*NOTE: remove the argument `TEST` to go live.*

***

## Post-Game

* Import your Terminal profile, if you have one.
* Finish any outstanding System Preferences configurations.
* Close all of your windows.
* Reboot the system

Then you're ready to start working.

[phase1]:https://github.com/todd-dsm/process-ph1
[install prep]:https://github.com/todd-dsm/mac-ops/wiki/Install-Prep
[wiki]:https://github.com/todd-dsm/mac-ops/wiki
[rsync-backups]:https://github.com/todd-dsm/rsync-backups
