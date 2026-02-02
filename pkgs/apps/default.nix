{
	pkgs,
	mechanixSrc
}:
{
	settings = pkgs.callPackage ./settings { inherit mechanixSrc; };
	files = pkgs.callPackage ./files { inherit mechanixSrc; };
	music = pkgs.callPackage ./music { inherit mechanixSrc; };
	camera = pkgs.callPackage ./camera { inherit mechanixSrc; };
	notes = pkgs.callPackage ./notes { inherit mechanixSrc; };
}
