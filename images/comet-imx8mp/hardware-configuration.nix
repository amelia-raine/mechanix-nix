{ pkgs, ... }:
let
	mechanix-pkgs = (import ./mechanix.nix).pkgs { inherit pkgs; };
in
{
	boot = {
		loader = {
			grub.enable = false;
			systemd-boot.enable = true;
			efi.canTouchEfiVariables = true;
		};
		initrd.includeDefaultModules = false;
		kernelPackages = pkgs.linuxPackagesFor mechanix-pkgs.hardware.comet-imx8mp.linux;
		growPartition = true;
	};

	fileSystems = {
		"/" = {
			device = "/dev/disk/by-label/nixos";
			fsType = "ext4";
			autoResize = true;
		};
		"/boot" = {
			device = "/dev/disk/by-label/ESP";
			fsType = "vfat";
		};
	};

	hardware = {
		deviceTree = {
			enable = true;
			filter = "imx8mp-*.dtb";
			name = "freescale/imx8mp-mecha-comet.dtb";
		};
		firmware = [ mechanix-pkgs.hardware.iw61x-firmware ];
	};

	system.nixos.tags = [ "comet-imx8mp" ];
}
