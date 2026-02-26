rec {
	src = builtins.fetchTarball {
		url = "https://github.com/amelia-raine/mechanix-nix/archive/36deef567140e35204c721546fb6df84effa3199.tar.gz";
		sha256 = "1wsgi18dwi9514j39rrm8nlarq2b3nl2r296snk2xggbybjb7c01";
	};
	module = import src;
	pkgs = import "${src}/pkgs";
}
