{
	libpulseaudio,
	makeDesktopItem,
	copyDesktopItems,
	mechanixSrc,
	buildApplication
}:
buildApplication {
	pname = "mechanix-settings";
	version = "0.0.3";
	src = "${mechanixSrc}/apps/settings";
	pubspecLock = ./pubspec.lock;
	depsHash = "sha256-pYIxJIV0c6zMBytszIjmtt+5doAxRpGg+nz8rCi4kF0=";

	desktopItems = [
		(makeDesktopItem {
			name = "org.mechanix.settings";
			desktopName = "Mechanix Settings";
			genericName = "Mechanix Settings";
			comment = "Settings app";
			type = "Application";
			exec = "mechanix_settings -w 540 -h 620 -k -s 1";
			icon = "mechanix_settings";
			terminal = false;
			categories = [ "System" ];
		})
	];

	nativeBuildInputs = [
		copyDesktopItems
	];

	postPatch = ''
		substituteInPlace lib/load_settings.dart \
			--replace-fail /usr/share/backgrounds/lock-screen $out/share/assets/images
	'';

	postInstall = ''
		mkdir -p $out/share
		cp -r assets $out/share/assets

		mkdir -p $out/share/icons/hicolor/48x48/apps
		cp assets/mechanix_settings.png $out/share/icons/hicolor/48x48/apps
	'';

	extraWrapProgramArgs = "--prefix LD_LIBRARY_PATH : ${libpulseaudio}/lib";
}
