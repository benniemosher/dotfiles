#!/bin/sh

GNUPG_HOME="$HOME/.gnupg"
if [ -f "$GNUPG_HOME" ]; then
    if [ "$(stat -c %a "$GNUPG_HOME")" != "700" ] ; then
        chmod 700 "$GNUPG_HOME"
    fi
fi

HOSTNAME=$(hostname -s)
keybase --pinentry=none login $KEYBASE_USERNAME --paperkey "$KEYBASE_PAPERKEY" --devicename "$HOST"

gpgconf --kill gpg-agent

keybase pgp export -q "$KEYBASE_KEY_ID" | gpg --import

keybase --pinentry=none pgp export -q "$KEYBASE_KEY_ID" --secret | gpg --allow-secret-key-import --import
