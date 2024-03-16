# How to cut a new repository update

1. Have access to the signing keys the repository is signed with and imported into GnuPG. This is outside the scope of this document. 
2. Find your signing key ID, for example via `gpg --list-keys`. If you're not sure which is the right key, you could do `gpg --armor --export $GPG_KEY_ID` and check the output against `KEY.gpg`
3. If you have a Debian based computer at your disposal, run `./install_requirements.sh` to make sure you have the required tools and skip to step 5.
4. If no personal Debian installation is available, from this repo root launch the provided container image and continue there. An example run is included below that you may need to tune to your specifics, such as where your GnuGPG directory is:
   ```shell
    docker run --rm -it -v $HOME/.gnupg:/root/.gnupg -v $PWD:/srv ghcr.io/jinnatar/atuin_demo_ppa:latest
   ```
5. Run the following command in the Debian environment, at the root of the repository:
   ```shell
    GPG_KEY_ID=yourSigningKeyIDHere ./update.sh
   ```
6. If in the container environment, you can exit it now with `exit`.
7. Verify that the `debian/` folder now has uncommitted changes, `git diff debian/Packages` can be helpful there.
8. Once happy, `git add debian/`, `git commit` and `git push`!

GitHub Pages takes a minute or two to propagate the new changes out to their CDN, but after that the release is done. Follow the `README.md` guidance to install the repo, for example in the same Debian environment used above and verify all is good.
