{ pkgs, lib, config, ... }:
let
	commonConfig = import ../common/configuration.nix { inherit pkgs lib config; };
	makeDiskImage = import <nixpkgs/nixos/lib/make-disk-image.nix> {
		inherit pkgs lib config;
		baseName = "nixos-mechanix-${config.system.nixos.label}-${pkgs.stdenv.hostPlatform.system}";
		diskSize = 4096;
		format = "raw";
		partitionTableType = "efi";
		contents = [
			{
				source = ../common/configuration.nix;
				target = "/etc/nixos/configuration.nix";
				mode = "644";
				user = "root";
				group = "root";
			}
			{
				source = ./hardware-configuration.nix;
				target = "/etc/nixos/hardware-configuration.nix";
				mode = "644";
				user = "root";
				group = "root";
			}
			{
				source = ../common/mechanix.nix;
				target = "/etc/nixos/mechanix.nix";
				mode = "644";
				user = "root";
				group = "root";
			}
		];
	};
in
lib.recursiveUpdate
	commonConfig
	{
		imports = [
			./hardware-configuration.nix
		];

		system.build.image = makeDiskImage;
	}
