{
	lib,
	flutter332,
	makeDesktopItem,
	copyDesktopItems,
	mechanixSrc
}:
flutter332.buildFlutterApplication {
	pname = "mechanix-notes";
	version = "0.0.4";
	src = "${mechanixSrc}/apps/notes";
	pubspecLock = lib.importJSON ./pubspec.lock.json;

	gitHashes = {
		widgets = "sha256-6HCbCEIFS37aXMYWUAvkDow8tJ5v8yys3iewm50hWNU=";
	};

	desktopItems = [
		(makeDesktopItem {
			name = "org.mechanix.notes";
			desktopName = "Mechanix Notes";
			genericName = "Mechanix Notes";
			comment = "Notes app";
			type = "Application";
			exec = "mechanix_notes -w 540 -h 620 -k -s 1";
			icon = "mechanix_notes";
			terminal = false;
			categories = [ "System" ];
		})
	];

	nativeBuildInputs = [
		copyDesktopItems
	];

	patchPhase = ''
		cp -r ${../common/linux} linux
		chmod +w -R linux
		substituteInPlace linux/CMakeLists.txt \
			--replace-fail '@name@' notes
		substituteInPlace linux/runner/my_application.cc \
			--replace-fail '@prettyName@' Notes
	'';

	postInstall = ''
		mkdir -p $out/share/icons/hicolor/48x48/apps
		cp assets/mechanix_notes.png $out/share/icons/hicolor/48x48/apps
	'';
}
