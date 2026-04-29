{
	pkgs ? import <nixpkgs> {}
}:
let
	mechanixSrc = pkgs.fetchFromGitHub {
		owner = "mecha-org";
		repo = "mechanix-gui";
		rev = "661cd5f05bac200c8e9f5be42598a236057f5c70";
		hash = "sha256-JByntJM3LF4sVeH0oUeqlUMXvNLlxYP2PbovZhFlMlg=";
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
