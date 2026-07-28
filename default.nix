{ pkgs, lib, config, ... }:
let
	inherit (lib) mkOption;
	tomlFormat = pkgs.formats.toml {};
	mechanix-pkgs = import ./pkgs { inherit pkgs; };
	mechanix-gui = mechanix-pkgs.gui;
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
				mechanix-pkgs.phoc
				bemenu
				alacritty
			] ++ lib.attrValues mechanix-pkgs.apps;

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
			defaultSession = "phoc-session";
			sessionPackages = [
				(
					(pkgs.makeDesktopItem {
						destination = "/share/wayland-sessions";
						name = "phoc-session";
						desktopName = "Phoc";
						exec = "phoc -E mechanix-launcher";
						type = "Application";
					}).overrideAttrs {
						passthru.providedSessions = [ "phoc-session" ];
					}
				)
			];
		};

		xdg.portal = {
			enable = true;
			extraPortals = [
				pkgs.xdg-desktop-portal-gtk
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
			squeekboard = {
				enable = true;
				description = "An on screen virtual keyboard";
				wantedBy = [ "default.target" ];
				path = with pkgs; [
					which
					squeekboard
				];
				serviceConfig = {
					Type = "simple";
					ExecStart = "${pkgs.squeekboard.src}/tools/squeekboard-restyled";
					Restart = "on-failure";
					RestartSec = 2;
					StandardOutput = "journal";
					StandardError = "journal";
					TimeoutStopSec = 30;
				};
			};
		};
	};
}
