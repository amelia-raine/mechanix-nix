{
	stdenvNoCC,
	fetchFromGitHub
}:
stdenvNoCC.mkDerivation {
	pname = "iw61x-firmware";
	version = "lf-6.12.20_2.0.0";

	src = fetchFromGitHub {
		owner = "nxp-imx";
		repo = "imx-firmware";
		# lf-6.12.20_2.0.0
		rev = "d31ea8aaba67e188ba0071a90da0364e3946c83a";
		hash = "sha256-EB+/+Hg247yPdegs79hv+qTC+CeI+OuWXd21ydt1fVw=";
	};

	phases = [ "unpackPhase" "installPhase" ];

	installPhase = ''
		mkdir -p $out/lib/firmware/nxp
		cp nxp/FwImage_IW612_SD/* $out/lib/firmware/nxp
	'';

	meta = {
		license = import ./nxp-license.nix;
	};
}
