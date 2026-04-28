{
	lib,
	buildPackages,
	stdenvNoCC,
	cacert,
	makeWrapper,
	autoPatchelfHook,
	writableTmpDirAsHomeHook
}:
let
	hostArchName = {
		x86_64-linux = "x64";
		aarch64-linux = "arm64";
	}.${stdenvNoCC.hostPlatform.system};

	flutter-elinux = buildPackages.callPackage ./flutter-elinux.nix {};
in
lib.extendMkDerivation {
	constructDrv = stdenvNoCC.mkDerivation;
	extendDrvArgs =
		finalAttrs:
		args @ {
			pname,
			version,
			src,
			pubspecLock,
			depsHash,
			nativeBuildInputs ? [],
			extraWrapProgramArgs ? "",
			...
		}:
		let
			deps = stdenvNoCC.mkDerivation {
				pname = "${pname}-deps";
				inherit version src;

				preferLocalBuild = true;

				outputHashMode = "recursive";
				outputHash = depsHash;

				nativeBuildInputs = [
					flutter-elinux
				];

				env.GIT_SSL_CAINFO = "${cacert}/etc/ssl/certs/ca-bundle.crt";

				dontFixup = true;

				patchPhase = ''
					cp ${pubspecLock} pubspec.lock
				'';

				buildPhase = ''
					HOME=$PWD flutter-elinux --suppress-analytics pub get --enforce-lockfile
				'';

				installPhase = ''
					rm -r .pub-cache/hosted/*/.cache
					rm -r .pub-cache/git/cache/*/*
					for dir in .pub-cache/git/*-*/.git
					do
						pushd $dir
						mv pub-packages ../pub-packages
						rm -r *
						mv ../pub-packages pub-packages
						popd
					done
					mkdir $out
					cp -r .pub-cache $out/pub-cache
				'';
			};
		in
		{
			nativeBuildInputs = nativeBuildInputs ++ [
				flutter-elinux
				makeWrapper
				autoPatchelfHook
				writableTmpDirAsHomeHook
			];

			env.PUB_CACHE = "${deps}/pub-cache";

			patchPhase = args.patchPhase or ''
				runHook prePatch

				cp ${pubspecLock} pubspec.lock

				runHook postPatch
			'';

			buildPhase = args.buildPhase or ''
				runHook preBuild

				flutter-elinux --suppress-analytics pub get --offline --enforce-lockfile
				LDFLAGS="$NIX_LDFLAGS" flutter-elinux --suppress-analytics build elinux --target-arch ${hostArchName}

				runHook postBuild
			'';

			installPhase = args.installPhase or ''
				runHook preInstall

				mkdir -p $out/bundle $out/bin
				mv build/elinux/${hostArchName}/release/bundle/*/ $out/bundle
				mv build/elinux/${hostArchName}/release/bundle/* $out/bin
				wrapProgram $out/bin/* \
					--add-flags "-b $out/bundle" \
					${extraWrapProgramArgs}

				runHook postInstall
			'';
		};
}
