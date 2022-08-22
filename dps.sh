#!/bin/sh
command -v sudo > /dev/null && ROOTCOMMAND=sudo || ROOTCOMMAND=doas
[ "$ROOTCOMMAND" = "sudo" ] && MAKECOMMAND=make|| MAKECOMMAND=gmake

finalize() {
	cd ..
	mkdir -p final-src
	cp -r dwm-flexipatch dwm-flexipatch-bak
	cd flexipatch-finalizer
	./flexipatch-finalizer.sh --run --directory ../dwm-flexipatch --output ../final-src
	cd ..
	rm -rf dwm-flexipatch
	mv dwm-flexipatch-bak dwm-flexipatch
	cd final-src
	$MAKECOMMAND && $ROOTCOMMAND $MAKECOMMAND install
	printf -- "\033[1;32mDone!\n"
}

cd dwm-flexipatch
[ -f patches.list ] || grep ".*PATCH [0-1]" patches.def.h > patches.list
sed -i 's/_PATCH 1/_PATCH 0/g' patches.list

grep "_PATCH [0-1]" patches.list | sed 's/#define //g' | sed 's/_PATCH 0//g' | tr '[:upper:]' '[:lower:]' | fzf --multi | tr '[:lower:]' '[:upper:]' | sed 's/$/_PATCH 1/g' | sed 's/^/#define /g' > patches.def.h
grep -v "$(cat patches.def.h)" patches.list >> patches.def.h
sed -i 's/BAR_LTSYMBOL_PATCH 0/BAR_LTSYMBOL_PATCH 1/' patches.def.h
sed -i 's/BAR_STATUS_PATCH 0/BAR_STATUS_PATCH 1/' patches.def.h
sed -i 's/BAR_TAGS_PATCH 0/BAR_TAGS_PATCH 1/' patches.def.h
sed -i 's/BAR_WINTITLE_PATCH 0/BAR_WINTITLE_PATCH 1/' patches.def.h

printf "Finalize build and strip flexipatch components? (y/n): "
read FINALIZE

case "$FINALIZE" in
	y) finalize && exit ;;
	n) $MAKECOMMAND && $ROOTCOMMAND $MAKECOMMAND install && printf "\-\-\-\-\nDone\n\-\-\-\-\n" ;;
	*) printf "Invalid input, exiting...\n" ;;
esac
