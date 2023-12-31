# Atuin Demo PPA

This repository hosts Debian (+derivative) compatible debs. Much of the mechanisms are inspired by https://github.com/kanidm/kanidm_ppa/, used under the MPL 2.0 license and vice versa licensed as MPL 2.0.

WARNING: This repo is purely a demo that will go away and be replaced by a more official one, if successful. Do not rely on this one specifically!

## Install

The install process listed below adds a GPG public key that the packages are signed with and a repository entry for Atuin.
Your system is expected to have `curl` and `gpg` installed.

### Adding the repository
``` shell
set -o pipefail
sudo mkdir -p /etc/apt/trusted.gpg.d/
curl -s --compressed "https://jinnatar.github.io/atuin_demo_ppa/KEY.gpg" \
    | gpg --dearmor \
    | sudo tee /etc/apt/trusted.gpg.d/atuin_ppa.gpg >/dev/null

sudo curl -s --compressed "https://jinnatar.github.io/atuin_demo_ppa/atuin_ppa.list" \
    | sudo tee /etc/apt/sources.list.d/atuin_ppa.list

sudo apt update
```

### Installing Atuin
```shell
sudo apt install atuin
```
