{
	boot = {
		loader.grub = {
			enable = true;
			devices = [ "/dev/vda" ];
		};
		growPartition = true;
	};

	fileSystems = {
		"/" = {
			device = "/dev/disk/by-label/nixos";
			fsType = "ext4";
			options = [ "noatime" ];
			autoResize = true;
		};
	};

	system.nixos.tags = [ "generic" ];
}
