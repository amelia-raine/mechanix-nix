{
	pdfium-binaries,
	mpv-unwrapped,
	makeDesktopItem,
	copyDesktopItems,
	mechanixSrc,
	buildApplication
}:
buildApplication {
	pname = "mechanix-files";
	version = "0.0.8";
	src = "${mechanixSrc}/apps/files";
	pubspecLock = ./pubspec.lock;
	depsHash = "sha256-Mf1JRqXR61PymalH4q/yw0gQqAgsGMFdPYpY8eP1r4k=";

	desktopItems = [
		(makeDesktopItem {
			name = "org.mechanix.files";
			desktopName = "Files";
			genericName = "Mechanix Files";
			comment = "Files app";
			type = "Application";
			exec = "mechanix_files -w 540 -h 620 -k -s 1";
			icon = "mechanix_files";
			terminal = false;
			noDisplay = false;
			categories = [ "Utility" ];
		})
	];

	nativeBuildInputs = [
		copyDesktopItems
	];

	postPatch = ''
		substituteInPlace lib/src/commons/constants.dart \
			--replace-fail /usr/lib64/libpdfium.so ${pdfium-binaries}/lib/libpdfium.so
	'';

	postInstall = ''
		mkdir -p $out/share/icons/hicolor/48x48/apps
		cp assets/mechanix_files.png $out/share/icons/hicolor/48x48/apps
	'';

	extraWrapProgramArgs = "--prefix LD_LIBRARY_PATH : ${mpv-unwrapped}/lib";
}
