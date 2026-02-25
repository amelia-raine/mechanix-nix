{
	pkgs,
	nixos-hardware
}:
let
	mwifiexSrc = pkgs.fetchFromGitHub {
		owner = "nxp-imx";
		repo = "mwifiex";
		rev = "7a8beaa1605cb0870dc7ba3312c76df91cb0d6cf";
		hash = "sha256-jRGBwIUfC0eelAmMbQ/VcHYtPb3sYuYm54DL03GoCVA=";
	};
in
(pkgs.callPackage "${nixos-hardware}/nxp/common/bsp/imx-linux-builder.nix" {} {
	pname = "linux-comet-imx8mp";
	version = "6.12.20+mecha";

	src = pkgs.fetchFromGitHub {
		owner = "mecha-org";
		repo = "linux";
		rev = "e7bc1e11a7a25a23d9b6751c097ba2035f5d876d";
		hash = "sha256-puKyFLLHjTQ1NDlGZ8KL8cZViVYZ9CNANInqA0uPe6s=";
	};

	defconfig = "mecha_v8_defconfig";

	# https://github.com/NixOS/nixpkgs/pull/366004
	# introduced a breaking change that if a module is declared but it is not being used it will faill.
	ignoreConfigErrors = true;
}).overrideAttrs {
	prePatch = ''
		cp -r ${mwifiexSrc} drivers/staging/mwifiex
		chmod +w -R drivers/staging/mwifiex
	'';
}
