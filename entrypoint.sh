#!/bin/sh
set -eo pipefail

error() {
    echo -e "\x1b[1;31m${1}\e[0m ${2}"
}

log() {
    echo -e "\x1b[1;32m${1}\e[0m ${2}"
}

filename="/github/workspace/${1}"

log "File Name:" "${filename}"

if [ -z "${2}" ]; then
    placeholder="\${VERSION}"
else
    placeholder=${2}
fi

log "Placeholder:" "${placeholder}"

if test -f "${filename}"; then
    content=$(cat "${filename}")
else
    error "Version file not found! Looked for:" "${filename}"
    exit 1;
fi

git fetch --tags --force
latestVersionTag=$(git describe --exact-match --tags 2> /dev/null || git rev-parse --short HEAD)
userTag="$(date -u +'%Y%m%d')-${latestVersionTag}"

log "Replacing placeholder with: ${userTag}"

updatedContent=$(< "$filename" sed "s/${placeholder}/${userTag}/g")
echo "${updatedContent}" > "${filename}"
