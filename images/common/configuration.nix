{ pkgs, lib, config, ... }:
{
	imports = [
		./hardware-configuration.nix
		<mechanix>
	];

	mechanix = {
		mechanix-shell.enable = false;
		mechanix-apps.enable = true;
		phosh.enable = true;
		user = "mecha";
	};

	environment.systemPackages = with pkgs; [
		alacritty
	];

	users.users = {
		mecha = {
			isNormalUser = true;
			extraGroups = [ "wheel" "networkmanager" ];
			initialPassword = "comet";
		};
		root = {
			initialPassword = null;
		};
	};

	networking.hostName = "comet";

	hardware.bluetooth.enable = true;

	hardware.graphics.enable = true;
	programs.xwayland.enable = true;

	services.pipewire = {
		enable = true;
		audio.enable = true;
		alsa.enable = true;
		pulse.enable = true;
	};

	zramSwap = {
		enable = true;
		algorithm = "lz4";
	};

	# WiFi firmware is unfree
	nixpkgs.config.allowUnfree = true;

	system.stateVersion = "26.05";
}
