{
	pkgs,
	mechanixSrc
}:
let
	buildApplication = pkgs.callPackage ../flutter-elinux/build-application.nix {};
in
{
	settings = pkgs.callPackage ./settings { inherit mechanixSrc buildApplication; };
	files = pkgs.callPackage ./files { inherit mechanixSrc buildApplication; };
	music = pkgs.callPackage ./music { inherit mechanixSrc buildApplication; };
	notes = pkgs.callPackage ./notes { inherit mechanixSrc buildApplication; };
}
