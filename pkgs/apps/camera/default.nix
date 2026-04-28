{
	pkg-config,
	glib,
	libsysprof-capture,
	pcre2,
	gst_all_1,
	autoPatchelfHook,
	makeDesktopItem,
	copyDesktopItems,
	mechanixSrc,
	buildApplication
}:
buildApplication {
	pname = "mechanix-camera";
	version = "0.0.1";
	src = "${mechanixSrc}/apps/camera";
	pubspecLock = ./pubspec.lock;
	depsHash = "sha256-6PL7dFw6mSwDMpN/mhVS12p8fcibyP0B2WBx3TaHUus=";

	desktopItems = [
		(makeDesktopItem {
			name = "org.mechanix.camera";
			desktopName = "Camera";
			genericName = "Mechanix Camera";
			comment = "Camera app";
			type = "Application";
			exec = "mechanix_camera -w 540 -h 620 -k -s 1";
			icon = "mechanix_camera";
			terminal = false;
			noDisplay = false;
			categories = [ "AudioVideo" ];
		})
	];

	nativeBuildInputs = [
		pkg-config
		autoPatchelfHook
		copyDesktopItems
	];

	buildInputs = [
		glib
		libsysprof-capture
		pcre2
		gst_all_1.gstreamer
	];

	dontAutoPatchelf = true;

	postInstall = ''
		mkdir -p $out/share/icons/hicolor/48x48/apps
		cp assets/mechanix_camera.png $out/share/icons/hicolor/48x48/apps
	'';

	preFixup = ''
		addAutoPatchelfSearchPath $out/bundle/lib
		autoPatchelf $out/bundle/lib
		autoPatchelf $out/bin
	'';
}
