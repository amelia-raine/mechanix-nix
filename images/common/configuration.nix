{ ... }:
{
	imports = [
		./hardware-configuration.nix
		./mechanix.nix
	];

	networking.hostName = "comet";

	users.users = {
		root.initialPassword = "comet";
		mecha = {
			isNormalUser = true;
			extraGroups = [ "wheel" "networkmanager" ];
			initialPassword = "comet";
		};
	};

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

	system.stateVersion = "25.11";
}
