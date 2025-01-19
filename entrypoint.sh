#!/bin/sh
set -eo pipefail

# Mark the workspace as a safe directory for Git
git config --global --add safe.directory /github/workspace

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

if [ -z "${3}" ]; then
    NO_DATE='false'
else
    NO_DATE=${3}
fi

if [ -z "${4}" ]; then
    WITH_BRANCH='false'
else
    WITH_BRANCH=${4}
fi

log "Placeholder:" "${placeholder}"
log "NO Date:" "${NO_DATE}"
log "Branch Prefix:" "${WITH_BRANCH}"

if test -f "${filename}"; then
    content=$(cat "${filename}")
else
    error "Version file not found! Looked for:" "${filename}"
    exit 1
fi

git fetch --tags --force
latestVersionTag=$(git describe --exact-match --tags 2>/dev/null || git rev-parse --short HEAD)

if [ "${NO_DATE}" = 'true' ]; then
    userTag="${latestVersionTag}"
else
    userTag="$(date -u +'%Y%m%d')-${latestVersionTag}"
fi

# If branch prefixing is enabled, retrieve the branch name and prefix the userTag.
if [ "${WITH_BRANCH}" = 'true' ]; then
    branchName=$(echo "$GITHUB_REF" | sed 's#refs/heads/##')
    userTag="${branchName}-${userTag}"
fi

log "Replacing placeholder with: ${userTag}"

# Use sed to replace the placeholder with the new tag.
updatedContent=$(sed "s/${placeholder}/${userTag}/g" "$filename")
echo "${updatedContent}" >"${filename}"
