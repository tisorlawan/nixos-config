#!/usr/bin/env bash

export SXHKD_SHELL=/bin/sh
pkill -u $USER -x sxhkd
sxhkd
