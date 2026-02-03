{
	lib,
	flutter332,
	libpulseaudio,
	makeDesktopItem,
	copyDesktopItems,
	mechanixSrc
}:
flutter332.buildFlutterApplication {
	pname = "mechanix-settings";
	version = "0.0.3";
	src = "${mechanixSrc}/apps/settings";
	pubspecLock = lib.importJSON ./pubspec.lock.json;

	gitHashes = {
		widgets = "sha256-5qEPc6qiF+kCbjLrufkmYvMa9wknNNgmFNSCWljPKzo=";
	};

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

	patchPhase = ''
		cp -r ${../common/linux} linux
		chmod +w -R linux
		substituteInPlace linux/CMakeLists.txt \
			--replace-fail '@name@' settings
		substituteInPlace linux/runner/my_application.cc \
			--replace-fail '@prettyName@' Settings

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
