{
	lib,
	stdenv,
	fetchurl,
	fetchzip,
	writeScriptBin,
	bash,
	rustPlatform,
	makeBinaryWrapper,
	pkg-config,
	unzip,
	glib,
	gdk-pixbuf,
	libxkbcommon,
	libxcb,
	libpulseaudio,
	libGL,
	wayland,
	mechanixSrc
}:
let
	impellerLibsVersion = "0.2.1";
	impellerLibsFetchArgs = {
		"aarch64-linux" = {
			url = "https://github.com/coderedart/impellers/releases/download/a_${impellerLibsVersion}/linux_arm64.zip";
			hashUrl = "sha256-mFS7SppNI994zSXp9hmQ6mDICg6vCEc4o+zvBqn/Slo=";
			hashZip = "sha256-spdmFAX4nzkVexbhSMZvgDqraC32eI9o7toDEi7Y9TQ=";
		};
		"x86_64-linux" = {
			url = "https://github.com/coderedart/impellers/releases/download/a_${impellerLibsVersion}/linux_x64.zip";
			hashUrl = "sha256-QjGSObru8xVNtaOK5EPOKRoJ0lCB+n0v0PrqV1jLr2w=";
			hashZip = "sha256-HsT82ZVUDX8Pn+QZ1Eo0tjAOE71LDexgfrugB+N4xXI=";
		};
	}.${stdenv.hostPlatform.system};
	impellerLibsZip = with impellerLibsFetchArgs; fetchurl { inherit url; hash = hashUrl; };
	impellerLibsSrc = with impellerLibsFetchArgs; fetchzip { inherit url; hash = hashZip; stripRoot = false; };
	fakeCurl = writeScriptBin "curl" ''#!${bash}/bin/bash
		if [ "$4" != "${impellerLibsFetchArgs.url}" ]
		then
			echo Unexpected url $4
			exit 1
		fi
		cp ${impellerLibsZip} $6
	'';
in
rustPlatform.buildRustPackage {
	pname = "mechanix-gui";
	version = "0.0.1";
	src = mechanixSrc;

	cargoLock = {
		lockFile = ./Cargo.lock;
		outputHashes = {
			"collections-0.1.0" = "sha256-aRwwOw5YRigd2lIz+VwzFIZhDHjt9fO0mPB9inE8TLY=";
			"xim-ctext-0.3.0" = "sha256-pRT4Sz1JU9ros47/7pmIW9kosWOGMOItcnNd+VrvnpE=";
			"zed-font-kit-0.14.1-zed" = "sha256-rxpumYP0QpHW+4e+J1qo5lEZXfBk1LaL/Y0APkUp9cg=";
			"zed-scap-0.0.8-zed" = "sha256-BihiQHlal/eRsktyf0GI3aSWsUCW7WcICMsC2Xvb7kw=";
			"zed-reqwest-0.12.15-zed" = "sha256-p4SiUrOrbTlk/3bBrzN/mq/t+1Gzy2ot4nso6w6S+F8=";
			"impellers-0.3.0" = "sha256-W+5qeb6QDW3bZakeSbZCqz+NygkN5mSZSjpECZum05k=";
		};
	};

	doCheck = false;

	nativeBuildInputs = [
		makeBinaryWrapper
		pkg-config
		fakeCurl
		unzip
	];

	buildInputs = [
		glib
		gdk-pixbuf
		libxkbcommon
		libxcb
		libpulseaudio
	];

	postPatch = ''
		cp ${./Cargo.lock} Cargo.lock
		chmod +w Cargo.lock

		substituteInPlace Cargo.toml \
			--replace-fail '"services/extensions",' "" \
			--replace-fail '"dbus/mechanix/extensions",' ""

		substituteInPlace $(grep /usr/share/mechanix/shell/assets -lr .) \
			--replace-fail /usr/share/mechanix/shell/assets $out/share/assets

		substituteInPlace shell/crates/settings/src/settings.rs \
			--replace-fail /usr/share/mechanix/shell/layouts $out/share/assets/layouts

		substituteInPlace services/search/apps/src/service.rs \
			--replace-fail /usr/share/applications /run/current-system/sw/share/applications

		substituteInPlace services/conf/src/main.rs \
			--replace-fail /usr/share/mxconf/schemas $out/share/mxconf/schemas

		substituteInPlace services/search/server/src/main.rs \
			--replace-fail /usr/share/mechanix/mxsearch/settings.toml $out/share/mxsearch/settings.toml
	'';

	postInstall = ''
		mkdir -p $out/share
		cp -r assets $out/share/assets
		mv $out/share/assets/{icons.example.toml,icons.toml}

		substituteInPlace $out/share/assets/settings.toml \
			--replace-fail assets/layouts/us.yaml $out/share/assets/layouts/us.yaml \
			--replace-fail 'anchor = ["top", "left", "right", "bottom"]' 'anchor = ["top", "left", "right"]'

		mkdir -p $out/etc/dbus-1/system.d
		cp services/system/system-dbus.conf $out/etc/dbus-1/system.d

		mkdir -p $out/share/mxconf/schemas
		cp services/conf/schemas/org.mechanix.desktop.toml $out/share/mxconf/schemas
		cp services/conf/schemas/default_profile.toml $out/share/mxconf

		mkdir -p $out/share/mxsearch
		substitute services/search/server/settings.toml.example $out/share/mxsearch/settings.toml \
			--replace-fail /usr/share/applications /run/current-system/sw/share/applications

		for bin in mechanix-launcher mechanix-keyboard
		do
			wrapProgram $out/bin/$bin \
				--suffix LD_LIBRARY_PATH : ${lib.makeLibraryPath [ libGL wayland impellerLibsSrc ]}
		done

		rm $out/bin/{homescreen,lockscreen,notifications,power_options,running_apps,settings_drawer,status_bar,volume_slider}
	'';
}
