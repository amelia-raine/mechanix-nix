{ pkgs, lib, config, ... }:
let
	mechanix-pkgs = import ./pkgs { inherit pkgs; };
	mechanix-gui = mechanix-pkgs.gui;
in
{
	config = {
		environment.systemPackages = with pkgs; [
			mechanix-gui
			mechanix-pkgs.phoc
			alacritty
		] ++ lib.attrValues mechanix-pkgs.apps;

		networking.networkmanager.enable = true;

		hardware.bluetooth.enable = true;

		hardware.graphics.enable = true;
		programs.xwayland.enable = true;
		services.xserver.desktopManager.phosh = {
			enable = true;
			user = "mecha";
			group = "users";
			phocConfig.xwayland = "immediate";
		};

		programs.dconf = {
			enable = true;
			profiles.user.databases = [{
				lockAll = true;
				settings = {
					"sm/puri/phosh/lockscreen".require-unlock = false;
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
