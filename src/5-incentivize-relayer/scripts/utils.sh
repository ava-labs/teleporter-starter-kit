#!/usr/bin/env bash
# Copyright (C) 2023, Ava Labs, Inc. All rights reserved.
# See the file LICENSE for licensing terms.

function getBlockchainIDHex() {
    python3 -c "import base58,sys; sys.stdout.write(base58.b58decode(b'$1').hex()[:-8])";
}

function parseContractAddress() {
    echo $1 | $grepcmd -o -P 'Deployed to: .{42}' | sed 's/^.\{13\}//';
}

# use ggrep on arm64 otherwise grep -P returns error.
# set ARCH before calling this function
function setGrep() {
    if [ "$ARCH" = 'arm64' ]; then
        export grepcmd="ggrep"
    else
        export grepcmd="grep"
    fi
}

# Set ARCH env so as a container executes without issues in a portable way
# Should be amd64 for linux/macos x86 hosts, and arm64 for macos M1
# It is referenced in the docker composer yaml, and then passed as a Dockerfile ARG
function setARCH() {
    export ARCH=$(uname -m)
    [ $ARCH = x86_64 ] && ARCH=amd64
    echo "ARCH set to $ARCH"
}

function convertToLower() {
    if [ "$ARCH" = 'arm64' ]; then
        echo $1 | perl -ne 'print lc'
    else
        echo $1 | sed -e 's/\(.*\)/\L\1/'
    fi
}