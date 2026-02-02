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
			autoResize = true;
			fsType = "ext4";
		};
	};
}
