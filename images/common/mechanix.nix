rec {
	src = builtins.fetchTarball {
		url = "https://github.com/amelia-raine/mechanix-nix/archive/4c18094e3c70bcb9ac68df986edb1ed5872b9b62.tar.gz";
		sha256 = "0112rpvw91g4adpi8wbj1jqyj2ngibfaxrksyd538sbi6dak6ig7";
	};
	module = import src;
	pkgs = import "${src}/pkgs";
}
