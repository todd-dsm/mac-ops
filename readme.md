# mac-ops - Tahoe

Sequoia (`macOS v15.x`) marks the rebirth of mac-ops. Tahoe is tested and ready for business.

## TL;DR

You need the tools before you can build anything. Herein lies automation to configure a full-featured (and highly opinionated) macOS that aims to support **Platform Engineering** (SRE/DevOps) work. Read the [full breakdown] if you care.

In all likelihood, you'll probably want to fork/customize to suit your needs.

## Pre-Game

Update macOS to the latest major or minor (patch) version.

> *I will test to the latest current patch version, within a short time of release.*

IF you don't already have ssh keys, create them:

1. [generate a new SSH key] if necessary
2. [associate the SSH key] with your GitHub account
3. Test it out:

```shell
% ssh -T git@github.com
Hi yourUserName! You've successfully authenticated, but GitHub does not provide shell access.
```

Clone the repo down to your laptop:

```shell
git clone git@github.com:todd-dsm/mac-ops.git && cd mac-ops/
```

If this is a new macOS, this will trigger the install of the Xcode CLI Tools; install it.

Or, if you're a returning contestant:

```shell
gclonecd git@github.com:todd-dsm/mac-ops.git
```

Grant Terminal [Full Disk Access] so mac-ops can configure all system areas.

### CONFIGURE *YOUR* VARIABLES

`vi my-vars.env` (or however you edit files)

---

Run the phase-1 automation; this will install some foundational tools and prep your system for the next phase.

```shell
tools/install-prep.sh 2>&1 | tee /tmp/install-prep.log
```

This is all over in `~02:11`; at the end, you will see:

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
./bootstrap.sh 2>&1 | tee ~/.config/admin/logs/mac-ops-config.log
```

This step lasts `<15:00`; again, follow the ons-screen instructions, or continue to [post-install] steps.

Now you're ready to start working.

<!-- docs/refs -->

[full breakdown]:https://github.com/todd-dsm/mac-ops/blob/main/docs/why-we-macops.md
[generate a new SSH key]:https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent#generating-a-new-ssh-key
[associate the SSH key]:https://docs.github.com/en/authentication/connecting-to-github-with-ssh/adding-a-new-ssh-key-to-your-github-account
[Full Disk Access]:https://www.alfredapp.com/help/troubleshooting/indexing/terminal-full-disk-access/
[post-install]:https://github.com/todd-dsm/mac-ops/blob/main/docs/post-install.md
