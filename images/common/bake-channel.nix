# Based on https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/installer/cd-dvd/channel.nix

{ pkgs, lib, config, ... }:
let
	mechanix = lib.cleanSource ../..;
	channelSources = pkgs.runCommandLocal "mechanix" {} ''
		mkdir -p $out
		cp -prd ${mechanix.outPath} $out/mechanix
	'';
in
{
	inherit channelSources;
	service = {
		description = "Initialize Mechanix Channel";
		unitConfig.DefaultDependencies = false;
		wantedBy = [ "sysinit.target" ];
		before = [
			"sysinit.target"
			"shutdown.target"
			"nix-daemon.socket"
			"nix-daemon.service"
		];
		after = [
			"local-fs.target"
			"register-nix-paths.service"
		];
		conflicts = [ "shutdown.target" ];
		restartIfChanged = false;
		serviceConfig = {
			Type = "oneshot";
			RemainAfterExit = true;
		};
		script = ''
			if ! [ -e /var/lib/mechanix-nix/did-channel-init ]; then
				echo "unpacking the Mechanix Nix sources..."
				mkdir -p /nix/var/nix/profiles/per-user/root
				nixos_channel=$(${lib.getExe' config.nix.package.out "nix-instantiate"} --eval-only --expr '<nixos>')
				${lib.getExe' config.nix.package.out "nix-env"} -p /nix/var/nix/profiles/per-user/root/channels \
					-i $nixos_channel ${channelSources} --quiet --option build-use-substitutes false \
					${lib.optionalString config.boot.initrd.systemd.enable "--option sandbox false"}
				mkdir -m 0700 -p /root/.nix-defexpr
				ln -sfvT /nix/var/nix/profiles/per-user/root/channels /root/.nix-defexpr/channels
				echo 'https://github.com/amelia-raine/mechanix-nix/archive/release.tar.gz mechanix' >> /root/.nix-channels
				mkdir -m 0755 -p /var/lib/mechanix-nix
				touch /var/lib/mechanix-nix/did-channel-init
			fi
		'';
	};
}
