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
	lock_path=/tmp/mechanix-gui/apps/$name/pubspec.lock
	fmm_version=$(yq '.packages.flutter_media_metadata.version' $lock_path)
	if [ "$fmm_version" = "null" ]
	then
		yq --no-colors --output-format json $lock_path > $path"pubspec.lock.json"
	else
		if [ "$fmm_version" != "1.0.0+1" ]
		then
			echo "Unexpected flutter_media_metadata version found in $name app"
			exit 1
		fi
		yq --no-colors --output-format json '.packages.flutter_media_metadata.source = "git" | .packages.flutter_media_metadata.description = {"path": ".", "ref": "c31041ac1ac8ed0580c0ac4c443dcefc2db49a61", "resolved-ref": "c31041ac1ac8ed0580c0ac4c443dcefc2db49a61", "url": "https://github.com/alexmercerind/flutter_media_metadata.git"}' $lock_path > $path"pubspec.lock.json"
	fi
	echo Wrote $path"pubspec.lock.json"
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
