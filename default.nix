{ lib, ... }:
{
	imports = [
		modules/mechanix-shell.nix
		modules/mechanix-apps.nix
		modules/phosh.nix
	];

	options = {
		mechanix = {
			user = lib.mkOption {
				type = lib.types.str;
			};
		};
	};
}
