{ config, lib, pkgs, ... }:
let
	commonConfig = import ../common/configuration.nix { inherit pkgs; };
	makeDiskImage = import <nixpkgs/nixos/lib/make-disk-image.nix> {
		inherit config lib pkgs;
		diskSize = 32768;
		format = "qcow2-compressed";
		baseName = "nixos-mechanix-${config.system.nixos.label}-${pkgs.stdenv.hostPlatform.system}";
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
			../common/mechanix.nix
		];

		system.build.image = makeDiskImage;
	}
