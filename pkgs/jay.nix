{
	jay,
	jay-config,
	fetchFromGitHub,
	makeBinaryWrapper
}:
jay.overrideAttrs (prev: {
	pname = "mechanix-jay";
	src = fetchFromGitHub {
		owner = "amelia-raine";
		repo = "mechanix-jay";
		rev = "25edf62858f89b218c68950aae72617eafa3ebba";
		hash = "sha256-SU7OT6Y7G0npAXUjCVgYQ/JQV8FZMtYsSUGIZNNi2hc=";
	};

	nativeBuildInputs = prev.nativeBuildInputs ++ [
		makeBinaryWrapper
	];

	postInstall = ''
		install -D etc/mechanix-jay.portal $out/share/xdg-desktop-portal/portals/mechanix-jay.portal
		install -D etc/mechanix-jay-portals.conf $out/share/xdg-desktop-portal/mechanix-jay-portals.conf

		wrapProgram $out/bin/mechanix-jay \
			--set-default JAY_CONFIG_SO ${jay-config}/lib/libmechanix_jay_config.so
	'';

	meta.mainProgram = "mechanix-jay";
})
