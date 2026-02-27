{
	pkgs ? import <nixpkgs> {}
}:
let
	mechanixSrc = pkgs.fetchFromGitHub {
		owner = "mecha-org";
		repo = "mechanix-gui";
		rev = "209b6f58a443bda5b912618b8e34c398cdce53cf";
		hash = "sha256-9Of+PmRlUX3pSIXknuHRmi6Sx1hfqs7yvOplpbA0qUo=";
	};
in
rec {
	gui = pkgs.callPackage ./gui { inherit mechanixSrc; };
	extension-service = pkgs.callPackage ./extension-service { inherit mechanixSrc; };
	apps = import ./apps { inherit pkgs mechanixSrc; };
	jay = pkgs.callPackage ./jay.nix { inherit jay-config; };
	jay-config = pkgs.callPackage ./jay-config {};
	phoc = pkgs.callPackage ./phoc.nix {};
	hardware = import ./hardware pkgs;
}
