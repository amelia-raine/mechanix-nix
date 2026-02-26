rec {
	src = builtins.fetchTarball {
		url = "https://github.com/amelia-raine/mechanix-nix/archive/fbf59d5aa5ae4ca4e236449f64a587387ea6c619.tar.gz";
		sha256 = "0cwshv5km6rpkapcgwhqjda5d8jnsrqbj4b8qa0vw6w0xh60ymj7";
	};
	module = import src;
	pkgs = import "${src}/pkgs";
}
