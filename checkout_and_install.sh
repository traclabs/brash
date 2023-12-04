#!/usr/bin/env bash
set -e

# Fix "Dubious ownership" error when running from within Docker
# NOTE: This check does not work for podman
if grep -sq 'docker\|lxc' /proc/1/cgroup; then
    echo "I am running on Docker."
    git config --global safe.directory "*"
fi


mkdir -p src
vcs import src < https.repos
colcon build --symlink-install
