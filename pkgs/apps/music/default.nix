{
	mpv-unwrapped,
	makeDesktopItem,
	copyDesktopItems,
	mechanixSrc,
	buildApplication
}:
buildApplication {
	pname = "mechanix-music";
	version = "0.0.2";
	src = "${mechanixSrc}/apps/music";
	pubspecLock = ./pubspec.lock;
	depsHash = "sha256-s1DdxQif3IdJqFmB5t76yopdXLWNstnm7RCQDz5YbYo=";

	desktopItems = [
		(makeDesktopItem {
			name = "org.mechanix.music";
			desktopName = "Mechanix Music";
			genericName = "Mechanix Music";
			comment = "Music app";
			type = "Application";
			exec = "mechanix_music -w 540 -h 620 -k -s 1";
			icon = "mechanix_music";
			terminal = false;
			categories = [ "System" ];
		})
	];

	nativeBuildInputs = [
		copyDesktopItems
	];

	postInstall = ''
		mkdir -p $out/share/icons/hicolor/48x48/apps
		cp assets/mechanix_music.png $out/share/icons/hicolor/48x48/apps
	'';

	extraWrapProgramArgs = ''
		--prefix LD_LIBRARY_PATH : ${mpv-unwrapped}/lib \
		--set LC_ALL C
	'';
}
