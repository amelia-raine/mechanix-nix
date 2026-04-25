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
	depsHash = "sha256-RFiZJTVStXZWapS5WILVSRINrPopZKER34t1odJAolY=";

	desktopItems = [
		(makeDesktopItem {
			name = "org.mechanix.files";
			desktopName = "Mechanix Files";
			genericName = "Mechanix Files";
			comment = "Files app";
			type = "Application";
			exec = "mechanix_files -w 540 -h 620 -k -s 1";
			icon = "mechanix_files";
			terminal = false;
			categories = [ "System" ];
		})
	];

	nativeBuildInputs = [
		copyDesktopItems
	];

	postInstall = ''
		rm $out/bundle/lib/libpdfium.so
		ln -s ${pdfium-binaries}/lib/libpdfium.so $out/bundle/lib/libpdfium.so

		mkdir -p $out/share/icons/hicolor/48x48/apps
		cp assets/mechanix_files.png $out/share/icons/hicolor/48x48/apps
	'';

	extraWrapProgramArgs = "--prefix LD_LIBRARY_PATH : ${mpv-unwrapped}/lib";
}
