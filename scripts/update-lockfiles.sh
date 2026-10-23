#!/usr/bin/env nix-shell
#!nix-shell -i bash -p stdenv git yq-go cargo

set -e

source $stdenv/setup

new_rev=$1

rm -rf /tmp/mechanix-gui
git clone --revision $new_rev --depth 1 https://github.com/mecha-org/mechanix-gui.git /tmp/mechanix-gui

for path in pkgs/apps/*/
do
	name=$(basename $path)
	if [ "$name" = "common" ]
	then
		continue
	fi
	cp /tmp/mechanix-gui/apps/$name/pubspec.lock $path"pubspec.lock"
	echo Wrote $path"pubspec.lock"
done

mv /tmp/mechanix-gui/{,original_}Cargo.toml

substitute /tmp/mechanix-gui/{original_,}Cargo.toml \
	--replace-fail '"services/extensions",' '' \
	--replace-fail '"dbus/mechanix/extensions",' ''
rm /tmp/mechanix-gui/Cargo.lock
(cd /tmp/mechanix-gui && cargo generate-lockfile)
cp /tmp/mechanix-gui/Cargo.lock pkgs/gui/Cargo.lock
echo Wrote pkgs/gui/Cargo.lock

substitute /tmp/mechanix-gui/{original_,}Cargo.toml \
	--replace-fail '"services/desktop",' '' \
	--replace-fail '"services/conf",' '' \
	--replace-fail '"services/system",' '' \
	--replace-fail '"services/search/*",' '' \
	--replace-fail '"shell/crates/*",' '' \
	--replace-fail '"shared/hw-buttons",' '' \
	--replace-fail '"dbus/freedesktop/*",' '' \
	--replace-fail '"dbus/mechanix/mxconf",' '' \
	--replace-fail '"dbus/mechanix/desktop",' '' \
	--replace-fail '"dbus/mechanix/extensions",' '' \
	--replace-fail '"dbus/mechanix/system",' ''
rm /tmp/mechanix-gui/Cargo.lock
(cd /tmp/mechanix-gui && cargo generate-lockfile)
cp /tmp/mechanix-gui/Cargo.lock pkgs/extension-service/Cargo.lock
echo Wrote pkgs/extension-service/Cargo.lock

rm -rf /tmp/mechanix-gui
