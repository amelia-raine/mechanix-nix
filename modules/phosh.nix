{ lib, config, ... }:
let
	cfg = config.mechanix.phosh;
in
{
	options = {
		mechanix.phosh = {
			enable = lib.mkEnableOption "Phosh";
		};
	};
	config = lib.mkIf cfg.enable {
		networking.networkmanager.enable = true;

		services.xserver.desktopManager.phosh = {
			enable = true;
			user = "mecha";
			group = "users";
			phocConfig.xwayland = "immediate";
		};

		programs.dconf = {
			enable = true;
			profiles.user.databases = [{
				lockAll = true;
				settings = {
					"sm/puri/phosh/lockscreen".require-unlock = false;
				};
			}];
		};
	};
}
