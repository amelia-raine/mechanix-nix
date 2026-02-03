# Mechanix Nix
Nix packages and modules to get [Mechanix](https://github.com/mecha-org/mechanix-gui) running on NixOS.

This repository contains:
- Nix packages for the Mechanix apps, shell and services.
- Nix module that configures the shell and services.
- Nix expressions for building bootable NixOS Mechanix images.

## Work in progress
I don't have a Mecha Comet yet, so until then I can't finish and test this project.

## Building bootable images
As of this writing you can't yet build a bootable image that runs on the real hardware, but you can build an image to test in a VM (I have only tested it in x86_64).

In order to build a bootable image you will need the [Nix package manager, which you can install on any distro](https://nixos.org/download/), you don't need to use NixOS.

Then clone this repository, navigate to its root directory and run the following command:
```bash
nix-build '<nixpkgs/nixos>' -I nixpkgs=https://github.com/NixOS/nixpkgs/archive/nixos-25.11.tar.gz -I nixos-config=images/qcow -A config.system.build.image
```

Once it's done it will print a path to the directory where the generated image is.

## Installing manually

Instead of building a bootable image you may want to install Mechanix in an already existing NixOS installation (you probably want to do this in a VM and not in your personal computer).

You can do so by adding this repository to your imports in your NixOS configuration.

For example, by adding the repository as a channel:
```bash
# Run as root
nix-channel --add https://github.com/amelia-raine/mechanix-nix/archive/main.tar.gz mechanix
nix-channel --update
```
Then add `<mechanix>` to your imports:
```nix
imports = [
	<mechanix>
];
```

## Running the Mechanix apps without Mechanix
You can also run the Mechanix apps without installing the rest of Mechanix, but they may not work properly.

For example, in order to run the Notes app you would first clone this repository, navigate to its root and then run:
```bash
nix-shell -p '(import ./pkgs {}).apps.notes'
mechanix_notes
```
