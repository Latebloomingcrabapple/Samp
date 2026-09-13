#!/usr/bin/env sh
set -eu

PAWNCC=${PAWNCC:-pawncc}
"$PAWNCC" OneCityRP.pwn -ipawno/include -oOneCityRP.amx
