{
	pkgs,
	lib,
	buildPackages,
	fetchFromGitHub,
	fetchzip,
	stdenvNoCC,
	runCommandLocal,
	autoPatchelfHook,
	libGL,
	libgbm,
	libdrm,
	libinput,
	which,
	git,
	cmake,
	clang,
	bintools
}:
let
	targetArchName = {
		x86_64-linux = "x64";
		aarch64-linux = "arm64";
	}.${stdenvNoCC.targetPlatform.system};

	flutter329 = buildPackages.flutter329;

	fakeGit = pkgs.writeShellScriptBin "git" ''
		if [ "$1" = "--version" ]
		then
			echo git version 2.51.2
		elif [ "$2" = "rev-parse" ]
		then
			echo true
		elif [ "$2" = "rev-list" ]
		then
			echo "$4"
		else
			${git}/bin/git "$@"
		fi
	'';

	artifact = {
		x86_64-linux = fetchzip {
			url = "https://github.com/sony/flutter-embedded-linux/releases/download/cf56914b32/elinux-x64-release.zip";
			hash = "sha256-ZnJXGxBHHFIbkaZWeMfM3dqE1WyBuS7YYebTgxKDSDw=";
			stripRoot = false;
		};
		aarch64-linux = (import pkgs.path { crossSystem = "aarch64-linux"; }).callPackage (
			{
				stdenvNoCC,
				autoPatchelfHook,
				libGL,
				libgbm,
				libdrm,
				libinput,
				gcc-unwrapped,
				libxkbcommon,
				fontconfig,
				wayland
			}:
			stdenvNoCC.mkDerivation {
				name = "elinux-artifact-aarch64";

				preferLocalBuild = true;

				src = fetchzip {
					url = "https://github.com/sony/flutter-embedded-linux/releases/download/cf56914b32/elinux-arm64-release.zip";
					hash = "sha256-XaFSqIKUdIMpQwJ0NkvEhlp1VUfc9+1HVWck+/XbnwQ=";
					stripRoot = false;
				};

				nativeBuildInputs = [
					autoPatchelfHook
				];

				buildPhase = ''
					mkdir $out
					cp -r * $out
				'';

				preFixup = ''
					addAutoPatchelfSearchPath ${libGL}/lib
					addAutoPatchelfSearchPath ${libgbm}/lib
					addAutoPatchelfSearchPath ${libdrm}/lib
					addAutoPatchelfSearchPath ${libinput.out}/lib
					addAutoPatchelfSearchPath ${gcc-unwrapped.lib}/lib
					addAutoPatchelfSearchPath ${libxkbcommon}/lib
					addAutoPatchelfSearchPath ${fontconfig.lib}/lib
					addAutoPatchelfSearchPath ${wayland}/lib
				'';
			}
		) {};
	}.${stdenvNoCC.targetPlatform.system};

	artifactCommon = fetchzip {
		url = "https://github.com/sony/flutter-embedded-linux/releases/download/cf56914b32/elinux-common.zip";
		hash = "sha256-QRsSNPoYmTBld8ngH1DSVgTangtaEhiOf3VszKpzthA=";
		stripRoot = false;
	};

	targetPrefix = bintools.targetPrefix;
	flutterBuildDeps = runCommandLocal "flutter-build-deps" {} ''
		mkdir -p $out/bin
		cd $out/bin
		ln -s ${clang}/bin/${targetPrefix}clang++ clang++
		ln -s ${bintools}/bin/${targetPrefix}ld ld
		ln -s ${bintools}/bin/${targetPrefix}ar ar
	'';

	sdkSourceBuilders = {
		"flutter" =
			name:
			runCommandLocal "flutter-sdk-${name}" { passthru.packageRoot = "."; } ''
				for path in '${flutter329}/packages/${name}' '${flutter329}/bin/cache/pkg/${name}'; do
					if [ -d "$path" ]; then
						ln -s "$path" "$out"
						break
					fi
				done

				if [ ! -e "$out" ]; then
					echo 1>&2 'The Flutter SDK does not contain the requested package: ${name}!'
					exit 1
				fi
			'';
		"dart" =
			name:
			runCommandLocal "dart-sdk-${name}" { passthru.packageRoot = "."; } ''
				for path in '${flutter329.dart}/pkg/${name}'; do
					if [ -d "$path" ]; then
						ln -s "$path" "$out"
						break
					fi
				done

				if [ ! -e "$out" ]; then
					echo 1>&2 'The Dart SDK does not contain the requested package: ${name}!'
					exit 1
				fi
			'';
	};

	src = stdenvNoCC.mkDerivation {
		name = "flutter-elinux-src";

		preferLocalBuild = true;
		allowSubstitutes = false;

		src = fetchFromGitHub {
			owner = "sony";
			repo = "flutter-elinux";
			rev = "cdc9622651ee7b217697258cd5ca0b8963f1d6a4";
			hash = "sha256-c+pgboYSKh+r6iM5cumbERBRKYNMoriz2Upst9nx3aU=";
		};

		installPhase = ''
			mkdir $out
			cp -r * $out
			cd $out
			mkdir -p flutter/packages flutter/bin/cache
			cp -r ${flutter329}/packages/flutter_tools flutter/packages/flutter_tools
			chmod +w -R flutter/packages/flutter_tools
			rm flutter/packages/flutter_tools/lib/src/cache.dart
			substitute ${flutter329}/packages/flutter_tools/lib/src/cache.dart flutter/packages/flutter_tools/lib/src/cache.dart \
				--replace-fail '_lockEnabled = true' '_lockEnabled = false'
		'';
	};
in
buildPackages.buildDartApplication {
	pname = "flutter-elinux";
	version = "3.29.3";
	inherit src sdkSourceBuilders;

	pubspecLock = lib.importJSON ./pubspec.lock.json;

	nativeBuildInputs = [
		autoPatchelfHook
	];

	dartEntryPoints = {
		"bin/flutter-elinux" = "bin/flutter_elinux.dart";
	};
	dartCompileFlags = [ "--define=NIX_FLUTTER_HOST_PLATFORM=${stdenvNoCC.hostPlatform.system}" ];

	dontAutoPatchelf = true;

	postInstall = ''
		mkdir $out/flutter
		ln -s ${flutter329}/* $out/flutter
		rm $out/flutter/bin
		mkdir $out/flutter/bin
		ln -s ${flutter329}/bin/* $out/flutter/bin
		rm $out/flutter/bin/cache
		cp -r ${flutter329}/bin/cache $out/flutter/bin/cache
		chmod +w -R $out/flutter/bin/cache
		cp -r ${artifact} $out/flutter/bin/cache/artifacts/engine/elinux-${targetArchName}-release
		chmod +w -R $out/flutter/bin/cache/artifacts/engine/elinux-${targetArchName}-release
		ln -s ${artifactCommon} $out/flutter/bin/cache/artifacts/engine/elinux-common
	'';

	postFixup = ''
		addAutoPatchelfSearchPath ${libGL}/lib
		addAutoPatchelfSearchPath ${libgbm}/lib
		addAutoPatchelfSearchPath ${libdrm}/lib
		addAutoPatchelfSearchPath ${libinput.out}/lib
		autoPatchelf $out/flutter/bin/cache
	'';

	extraWrapProgramArgs = "--inherit-argv0 --prefix PATH : ${lib.makeBinPath [ which fakeGit cmake flutterBuildDeps ]}";
}
