#!/bin/bash
# Pulls the latest release files

set -o pipefail

# Override to test with a fork
REPO=${REPO:-atuinsh/atuin}
DISTRO="debian"

if [ -z "${GPG_KEY_ID}" ]; then
    echo "Ensure the GPG_KEY_ID environment variable is set!"
    exit 1
fi

if [ "$(which gpg | wc -l )" -eq 0 ]; then
    echo "gpg not found, please install gpg"
    exit 1
fi

if [ "$(gpg --list-keys --with-subkey-fingerprints | grep -c "${GPG_KEY_ID}")" -ne 1 ]; then
    find . -name '*.gpg' -exec gpg --import {} \;
    find . -name '*.asc' -exec gpg --import {} \;
    if [ "$(gpg --list-keys | grep -c "${GPG_KEY_ID}")" -ne 1 ]; then
        echo "Don't have GPG key ${GPG_KEY_ID}, can't continue!"
        exit 1
    fi
fi

if [ "$(which jq | wc -l )" -eq 0 ]; then
    echo "jq not found, please install jq"
    exit 1
fi

if [ "$(which curl | wc -l )" -eq 0 ]; then
    echo "curl not found, please install curl"
    exit 1
fi

if [ "$(which git-lfs | wc -l )" -eq 0 ]; then
    echo "git-lfs not found, please install git-lfs"
    exit 1
fi


cd "$DISTRO" || exit 1

if [ -z "${SKIP_DOWNLOAD}" ]; then
API_URL="https://api.github.com/repos/${REPO}/releases/latest"
echo "Finding the latest release from $API_URL"
RELEASE_URL="$(curl -qLs "$API_URL" | jq -r '.assets_url')"

if [ -z "${RELEASE_URL}" ]; then
    echo "Failed to find a valid release"
    exit 1
fi

echo "Fetching release info from ${RELEASE_URL}"
urls=($(curl -qLs "$RELEASE_URL" | jq '.[] | .browser_download_url' | grep "\.deb" | tr -d \"))
if [ $? -ne 0 ]; then
    echo "Release doesn't have any files for $DISTRO"
    exit 1
else
    echo "Release has ${#urls[@]} files for $DISTRO"
fi
for url in "${urls[@]}"; do
    ../download.sh "$url" || exit 1
done
else
echo "Skipping download..."
fi

echo "Running dpkg-scanpackages"
dpkg-scanpackages --multiversion . > Packages

echo "Compressing Packages"
gzip -k -f Packages

echo "Generating release file"
apt-ftparchive release . > Release

echo "Signing release file"
gpg --default-key "${GPG_KEY_ID}" -abs -o - Release > Release.gpg
gpg --default-key "${GPG_KEY_ID}" --clearsign -o - Release > InRelease

echo "Done with $DISTRO!"
