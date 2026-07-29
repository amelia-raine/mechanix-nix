{
	pkgs,
	nixos-hardware
}:
pkgs.callPackage "${nixos-hardware}/nxp/common/bsp/imx-linux-builder.nix" {} {
	pname = "linux-comet-imx8mp";
	version = "7.1.0";

	src = pkgs.fetchFromGitHub {
		owner = "mecha-org";
		repo = "linux";
		rev = "fd642caaca85d8fa8e9d2391cfb6f9fe38bfb4be";
		hash = "sha256-J9tVJ6Ysax0ofAQ+3xQvqw7cLsGYVxiHQWNlYDtp+SE=";
	};

	defconfig = "mecha_v8_defconfig";

	# https://github.com/NixOS/nixpkgs/pull/366004
	# introduced a breaking change that if a module is declared but it is not being used it will fail.
	ignoreConfigErrors = true;
}
