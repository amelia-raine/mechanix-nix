{
	lib,
	flutter332,
	alsa-lib,
	mpv-unwrapped,
	libass,
	ffmpeg,
	libplacebo,
	libunwind,
	shaderc,
	vulkan-loader,
	lcms,
	libdovi,
	libdvdnav,
	libdvdread,
	mujs,
	libbluray,
	lua,
	rubberband,
	libuchardet,
	zimg,
	openal,
	pipewire,
	libpulseaudio,
	libcaca,
	libdrm,
	libdisplay-info,
	libgbm,
	libxscrnsaver,
	libxpresent,
	nv-codec-headers-11,
	libva,
	libvdpau,
	makeDesktopItem,
	copyDesktopItems,
	mechanixSrc
}:
flutter332.buildFlutterApplication {
	pname = "mechanix-files";
	version = "0.0.8";
	src = "${mechanixSrc}/apps/files";
	pubspecLock = lib.importJSON ./pubspec.lock.json;

	gitHashes = {
		widgets = "sha256-5qEPc6qiF+kCbjLrufkmYvMa9wknNNgmFNSCWljPKzo=";
	};

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

	buildInputs = [
		alsa-lib
		mpv-unwrapped
		libass
		ffmpeg
		libplacebo
		libunwind
		shaderc
		vulkan-loader
		lcms
		libdovi
		libdvdnav
		libdvdread
		mujs
		libbluray
		lua
		rubberband
		libuchardet
		zimg
		openal
		pipewire
		libpulseaudio
		libcaca
		libdrm
		libdisplay-info
		libgbm
		libxscrnsaver
		libxpresent
		nv-codec-headers-11
		libva
		libvdpau
	];

	patchPhase = ''
		cp -r ${../common/linux} linux
		chmod +w -R linux
		substituteInPlace linux/CMakeLists.txt \
			--replace-fail '@name@' files
		substituteInPlace linux/runner/my_application.cc \
			--replace-fail '@prettyName@' Files
	'';

	preInstall = ''
		patchelf \
			--set-rpath "$(patchelf --print-rpath build/linux/x64/release/bundle/lib/libpdfrx.so | grep -Po '(/nix/store/[^\/]+/lib:?)+'):$out/app/mechanix-files/lib" \
			build/linux/x64/release/bundle/lib/libpdfrx.so
	'';

	postInstall = ''
		mkdir -p $out/share/icons/hicolor/48x48/apps
		cp assets/mechanix_files.png $out/share/icons/hicolor/48x48/apps
	'';
}
