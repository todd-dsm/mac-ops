# Why We mac-ops

This is all about time but - what isn't?

```shell
¯\_(ツ)_/¯
```

In short, this helps to avoid the tedium of configuring the thousands of settings on a new MacBook that make it a joy to use. And, if you forget just one of those settings, it's ***super annoying***. Use this if you are:

* a consultant that needs to configure client laptops on an adequetly annoying basis.
* a new user and trying to learn Platform Engineering.
  * fighting on 2 fronts (workstation and systems) is a great learning experience but is really just a distraction from work.

## Ansible Begins with Sequoia

Previous versions of this were all written in shell; that's an 's' followed by *hell*. Beginning with Sequoia, system changes are managed with Ansible. Things are idempotent, predictable and easy to test. That said:

> *I - AM NOT - AN ANSIBLE PERSON.*

I was able to learn just enough to make this work. But it works great. I'm always open to learning from others that know more though. If you have a good idea, don't be shy. I have limited time so:

* PRs are probably better
* Always test before submitting

## Assumptions

This build assumes: 2 pre-conditions, either:

1. you are peeling the cellophane off the new MacBook Pro box with Apple defaults, or
2. you are backing up a currently-configured system and applying this automation

In either case, you are covered. In the second case your current configs will be backed up (locally) and replacedl; you lose nothing. Backups are located here: `~/.config/admin/backup`.

### Caveat

* These backups assume standard files with standard names in standard locations, like `~/.vimrc`, etc.
* If you have aliases in a file called poop.booger, stored in a weird location, then
  * the relevant mac-ops configs may conflict with your settings
  * 99% of the work is done for you; the last 1% is on you. Figure it out, or

> *If your job requires much different tools then perhaps a fork is best?*

### Self-guided Backups

A backup procedure is ***always*** recommended; check the [rsync-backups] page; notes:

* A restore process is coming shortly; mostly because I need it.
* If this is a new `macOS` laptop/install for work, there's no reason for a backup, unless...
  * this is an upgrade from an old work laptop to a new one.

## Write Issues

All that said, if you see something, say something. I've been at this 30 years; this configuration is exhaustively tested. However, if you find anything that's less than perfect - *write an issue*.

---

## Documentation

If you're generally good with everything to this point, continue on. If not...

Maybe it's worth check the [wiki] first. I should include the wiki material is super old and it may not be rellevant any longer but I *am* getting to it.

<!-- docs/refs -->

[wiki]:https://github.com/todd-dsm/mac-ops/wiki
[rsync-backups]:https://github.com/todd-dsm/rsync-backups
