pkgs:
let
	nixos-hardware = pkgs.fetchFromGitHub {
		owner = "NixOS";
		repo = "nixos-hardware";
		rev = "a351494b0e35fd7c0b7a1aae82f0afddf4907aa8";
		hash = "sha256-QEDtctEkOsbx8nlFh4yqPEOtr4tif6KTqWwJ37IM2ds=";
	};
in
{
	comet-imx8mp = import ./comet-imx8mp { inherit pkgs nixos-hardware; };
}
