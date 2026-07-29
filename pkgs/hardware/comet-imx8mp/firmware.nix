{
	stdenvNoCC,
	fetchFromGitHub
}:
stdenvNoCC.mkDerivation {
	name = "comet-imx8mp-firmware";

	src = fetchFromGitHub {
		owner = "mecha-org";
		repo = "mecha-make";
		rev = "1fbdba0a965454fdc8ce8bab4da7552f5236850c";
		hash = "sha256-+IMG+/OHlNqjGRiI2+8IIDm+Bjkdzq0eLKHUaVMSyOE=";
	};

	phases = [ "unpackPhase" "installPhase" ];

	installPhase = ''
		mkdir -p $out/lib/firmware
		cp -r mkosi.extra/lib/firmware/* $out/lib/firmware
	'';

	meta = {
		license = import ../nxp-license.nix;
	};
}
