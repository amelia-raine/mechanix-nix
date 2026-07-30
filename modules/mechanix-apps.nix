{ pkgs, lib, config, ... }:
let
	cfg = config.mechanix.mechanix-apps;
	mechanix-pkgs = import ../pkgs { inherit pkgs; };
in
{
	options = {
		mechanix.mechanix-apps = {
			enable = lib.mkEnableOption "the Mechanix Apps";
		};
	};

	config = {
		environment.systemPackages = lib.optionals cfg.enable (lib.attrValues mechanix-pkgs.apps);
	};
}
