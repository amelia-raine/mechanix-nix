{
	lib,
	flutter332,
	makeDesktopItem,
	copyDesktopItems,
	mechanixSrc
}:
flutter332.buildFlutterApplication {
	pname = "mechanix-camera";
	version = "0.0.2";
	src = "${mechanixSrc}/apps/camera";
	pubspecLock = lib.importJSON ./pubspec.lock.json;

	desktopItems = [
		(makeDesktopItem {
			name = "org.mechanix.camera";
			desktopName = "Mechanix Camera";
			genericName = "Mechanix Camera";
			comment = "Camera app";
			type = "Application";
			exec = "mechanix_camera -w 540 -h 620 -k -s 1";
			icon = "mechanix_camera";
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
			--replace-fail '@name@' camera
		substituteInPlace linux/runner/my_application.cc \
			--replace-fail '@prettyName@' Camera
	'';

	postInstall = ''
		mkdir -p $out/share/icons/hicolor/48x48/apps
		cp assets/mechanix_camera.png $out/share/icons/hicolor/48x48/apps
	'';
}
