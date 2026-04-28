{
	makeDesktopItem,
	copyDesktopItems,
	mechanixSrc,
	buildApplication
}:
buildApplication {
	pname = "mechanix-notes";
	version = "0.0.4";
	src = "${mechanixSrc}/apps/notes";
	pubspecLock = ./pubspec.lock;
	depsHash = "sha256-GzQ7bLwbdl41uNc7TGGlLkAaWCLyKW5UU/mP0HAB3c8=";

	desktopItems = [
		(makeDesktopItem {
			name = "org.mechanix.notes";
			desktopName = "Notes";
			genericName = "Mechanix Notes";
			comment = "Notes app";
			type = "Application";
			exec = "mechanix_notes -w 540 -h 620 -k -s 1";
			icon = "mechanix_notes";
			terminal = false;
			noDisplay = false;
			categories = [ "Utility" ];
		})
	];

	nativeBuildInputs = [
		copyDesktopItems
	];

	postInstall = ''
		mkdir -p $out/share/icons/hicolor/48x48/apps
		cp assets/mechanix_notes.png $out/share/icons/hicolor/48x48/apps
	'';
}
