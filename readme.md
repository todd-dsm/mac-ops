# mac-ops - Sequoia

Sequoia (`macOS v15.x`) marks the rebirth of mac-ops.

## TL;DR

Before you can build anything, you first need the tools. Herein lies automation to configure a full-featured (and highly opinionated) macOS that aims to support **Platform Engineering_** (SRE/DevOps) work. Read the [full breakdown] if you care.

## Pre-Game

1. [generate a new SSH key] if necessary
2. [associate the SSH key] with your GitHub account
3. Test it out:

```shell
% ssh -T git@github.com
Hi yourUserName! You've successfully authenticated, but GitHub does not provide shell access.
```

Clone the repo down to your laptop:

`git clone git@github.com:todd-dsm/mac-ops.git && cd mac-ops/`

### CONFIGURE *YOUR* VARIABLES

`vi my-vars.env` (or however you edit files)

---

Manually:

* Update macOS to the latest major or minor (patch) version
* Install the Xcode CLI Tools
* then run `install-prep.sh` to:

```shell
tools/install-prep.sh 2>&1 | tee /tmp/install-prep.out
# duration: ~03:30
```

When it's all over, you will see:

```shell
         __                                     __
  ____  / /_     ____ ___  __  __   ____  _____/ /_
 / __ \/ __ \   / __ `__ \/ / / /  /_  / / ___/ __ \
/ /_/ / / / /  / / / / / / /_/ /    / /_(__  ) / / /
\____/_/ /_/  /_/ /_/ /_/\__, /    /___/____/_/ /_/
                        /____/                       ....is now installed!
```

To back out of the new Oh My ZSH shell just press: `CTRL+d`

Then follow the ons-screen instructions.

---

## The mac-ops Config

This is the final step.

```shell
./bootstrap.sh ANSIBLE_NOCOLOR=True 2>&1 | tee ~/.config/admin/logs/mac-ops-config.out
# duration: ~14:30
```

Again, follow the ons-screen instructions.

Then you're ready to start working.

<!-- docs/refs -->

[full breakdown]:
[generate a new SSH key]:https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent#generating-a-new-ssh-key
[associate the SSH key]:https://docs.github.com/en/authentication/connecting-to-github-with-ssh/adding-a-new-ssh-key-to-your-github-account
[Oh My ZSH]:https://ohmyz.sh/
[phase1]:https://github.com/todd-dsm/process-ph1
[install prep]:https://github.com/todd-dsm/mac-ops/wiki/Install-Prep
