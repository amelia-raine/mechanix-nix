{ pkgs, lib, config, ... }:
let
	commonConfig = import ../common/configuration.nix { inherit pkgs lib config; };
	makeDiskImage = import <nixpkgs/nixos/lib/make-disk-image.nix> {
		inherit pkgs lib config;
		baseName = "nixos-mechanix-${config.system.nixos.label}-${pkgs.stdenv.hostPlatform.system}";
		diskSize = 32768;
		format = "qcow2-compressed";
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
			(import ../common/mechanix.nix).module
		];

		system.build.image = makeDiskImage;
	}
