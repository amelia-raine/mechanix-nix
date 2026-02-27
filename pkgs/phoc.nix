{
	phoc,
	fetchFromGitHub
}:
phoc.overrideAttrs {
	pname = "mechanix-phoc";
	version = "0.51.0";
	src = fetchFromGitHub {
		# TODO: update owner to mecha-org when it gets uploaded there
		owner = "mineshp-mecha";
		repo = "phoc";
		rev = "80117bb34360b341b8730015b95547a99ecdf567";
		hash = "sha256-g1RFv3VTjofPnOGlSb0epQww4wYE6nDDN6mpit1pAHk=";
	};
}
