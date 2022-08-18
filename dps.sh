#!/bin/sh
command -v sudo > /dev/null && ROOTCOMMAND=sudo || ROOTCOMMAND=doas
cd src
[ -f patches.full ] || grep ".*PATCH [0-1]" > patches.list

grep ".*PATCH [0-1]" patches.list | sed 's/#define //g' | sed 's/[0-1]//g' | fzf --multi | sed 's/$/1/g' | sed 's/^/#define /g' > patches.def.h

make
