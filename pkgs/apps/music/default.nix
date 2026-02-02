{
	lib,
	flutter332,
	libmediainfo,
	mpv-unwrapped,
	makeDesktopItem,
	copyDesktopItems,
	mechanixSrc
}:
flutter332.buildFlutterApplication {
	pname = "mechanix-music";
	version = "0.0.2";
	src = "${mechanixSrc}/apps/music";
	pubspecLock = lib.importJSON ./pubspec.lock.json;

	gitHashes = {
		widgets = "sha256-6HCbCEIFS37aXMYWUAvkDow8tJ5v8yys3iewm50hWNU=";
		flutter_media_metadata = "sha256-GmmqWuvcgrSf+PqwYNQS2Rgxv+56ZKbOFADUebWNNFk=";
	};

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

	buildInputs = [
		libmediainfo
	];

	patchPhase = ''
		cp -r ${../common/linux} linux
		chmod +w -R linux
		substituteInPlace linux/CMakeLists.txt \
			--replace-fail '@name@' music
		substituteInPlace linux/runner/my_application.cc \
			--replace-fail '@prettyName@' Music
	'';

	postInstall = ''
		mkdir -p $out/share/icons/hicolor/48x48/apps
		cp assets/mechanix_music.png $out/share/icons/hicolor/48x48/apps
	'';

	extraWrapProgramArgs = ''
		--prefix LD_LIBRARY_PATH : ${mpv-unwrapped}/lib \
		--set LC_ALL C
	'';
}
