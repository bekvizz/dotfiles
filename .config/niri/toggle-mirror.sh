#!/usr/bin/env bash

if pkill -x wl-mirror; then
    exit 0
fi

INTERNAL_OUTPUT="eDP-1"

wl-mirror "$INTERNAL_OUTPUT"