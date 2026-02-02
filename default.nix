{ pkgs, lib, config, ... }:
let
	inherit (lib) mkOption;
	tomlFormat = pkgs.formats.toml {};
	mechanix-pkgs = import ./pkgs { inherit pkgs; };
	mechanix-gui = mechanix-pkgs.gui;
	mechanix-apps = mechanix-pkgs.apps;
	wrapJay = jay: binName:
		pkgs.runCommandLocal binName
			{ nativeBuildInputs = [ pkgs.makeBinaryWrapper ]; }
			''
				mkdir -p $out/icons
				ln -s ${pkgs.adwaita-icon-theme}/share/icons/Adwaita $out/icons/default
				ln -s ${jay}/share $out/share
				mkdir -p $out/bin
				makeWrapper ${jay}/bin/${binName} $out/bin/${binName} \
					--suffix XCURSOR_PATH : $out/icons
			'';
	jay = wrapJay pkgs.jay "jay";
	mechanix-jay = wrapJay mechanix-pkgs.jay "mechanix-jay";
in
{
	options = {
		mechanix = {
			settings = mkOption {
				type = tomlFormat.type;
				default = {};
			};
		};
	};

	config = {
		environment = {
			systemPackages = with pkgs; [
				mechanix-gui
				jay
				mechanix-jay
				bemenu
				alacritty
			] ++ lib.attrValues mechanix-apps;

			etc."mxconf/profile/default_profile.toml".source = "${mechanix-gui}/share/mxconf/default_profile.toml";
			etc."mechanix/shell/assets/settings.toml".source = tomlFormat.generate "settings.toml" config.mechanix.settings;
		};

		services.dbus.packages = [ mechanix-gui ];

		networking.networkmanager.enable = true;

		hardware.bluetooth.enable = true;

		hardware.graphics.enable = true;
		programs.xwayland.enable = true;
		services.displayManager = {
			enable = true;
			sddm = {
				enable = true;
				wayland.enable = true;
			};
			sessionPackages = [
				(
					(pkgs.makeDesktopItem {
						destination = "/share/wayland-sessions";
						name = "jay-mechanix-session";
						desktopName = "Jay Mechanix";
						exec = "mechanix-jay run";
						type = "Application";
					}).overrideAttrs {
						passthru.providedSessions = [ "jay-mechanix-session" ];
					}
				)
				(
					(pkgs.makeDesktopItem {
						destination = "/share/wayland-sessions";
						name = "jay-session";
						desktopName = "Jay Default";
						exec = "jay run";
						type = "Application";
					}).overrideAttrs {
						passthru.providedSessions = [ "jay-session" ];
					}
				)
			];
		};

		xdg.portal = {
			enable = true;
			extraPortals = [
				jay
				mechanix-jay
				pkgs.xdg-desktop-portal-gtk
			];
			configPackages = [
				jay
				mechanix-jay
			];
		};

		programs.dconf = {
			enable = true;
			profiles.user.databases = [{
				lockAll = true;
				settings = {
					"org/gnome/desktop/a11y/applications".screen-keyboard-enabled = true;
					"org/gnome/desktop/interface".color-scheme = "prefer-dark";
				};
			}];
		};

		systemd.services = {
			mechanix-system = {
				enable = true;
				description = "Mechanix System Service";
				after = [ "dbus.service" ];
				wantedBy = [ "multi-user.target" ];
				serviceConfig = {
					Type = "simple";
					ExecStart = "${mechanix-gui}/bin/mechanix-system-service";
					Restart = "on-failure";
					RestartSec = 10;
					StandardOutput = "journal";
					StandardError = "journal";
					KillSignal = "SIGTERM";
					TimeoutStopSec = 30;
				};
			};
		};
		systemd.user.services = {
			create-default-dirs = {
				enable = true;
				description = "Creates the default home subdirectories";
				wantedBy = [ "default.target" ];
				serviceConfig = {
					Type = "oneshot";
					ExecStart = "${pkgs.coreutils}/bin/mkdir -p Downloads Documents Music";
				};
			};
			mechanix-conf = {
				enable = true;
				description = "Mechanix Configuration Service";
				after = [ "dbus.service" ];
				wantedBy = [ "default.target" ];
				serviceConfig = {
					Type = "dbus";
					BusName = "org.mechanix.MxConf";
					ExecStart = "${mechanix-gui}/bin/mxconf -s";
					Restart = "on-failure";
					RestartSec = 10;
					StandardOutput = "journal";
					KillSignal = "SIGTERM";
					TimeoutStopSec = 30;
				};
			};
			mechanix-desktop = {
				enable = true;
				description = "Desktop Session Service";
				after = [ "dbus.service" ];
				wantedBy = [ "default.target" ];
				serviceConfig = {
					Type = "simple";
					ExecStart = "${mechanix-gui}/bin/mechanix-session-service";
					Restart = "on-failure";
					RestartSec = 10;
					StandardOutput = "journal";
					StandardError = "journal";
					KillSignal = "SIGTERM";
					TimeoutStopSec = 30;
				};
			};
			mechanix-search = {
				enable = true;
				description = "Apps and Files Search Service";
				after = [ "dbus.service" "create-default-dirs.service" ];
				wantedBy = [ "default.target" ];
				serviceConfig = {
					Type = "dbus";
					BusName = "org.mechanix.MxSearch";
					ExecStart = "${mechanix-gui}/bin/mxsearch";
					Restart = "on-failure";
					RestartSec = 10;
					StandardOutput = "journal";
					KillSignal = "SIGTERM";
					TimeoutStopSec = 30;
				};
			};
		};
	};
}
