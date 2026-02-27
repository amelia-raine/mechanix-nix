rec {
	src = builtins.fetchTarball {
		url = "https://github.com/amelia-raine/mechanix-nix/archive/b97c071a7f266dea6acc449347f77368dccec84e.tar.gz";
		sha256 = "19db4zwngvr1vrgmgdjnkzh7bji2392qvbdjx59c65nyampi95dz";
	};
	module = import src;
	pkgs = import "${src}/pkgs";
}
