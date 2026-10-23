{
	boot = {
		loader.grub = {
			enable = true;
			devices = [ "/dev/vda" ];
		};
	};

	fileSystems = {
		"/" = {
			device = "/dev/disk/by-label/nixos";
			fsType = "ext4";
			options = [ "noatime" ];
		};
	};

	system.nixos.tags = [ "generic" ];
}
