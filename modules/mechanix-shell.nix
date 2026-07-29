{ pkgs, lib, config, ... }:
let
	cfg = config.mechanix.mechanix-shell;
	mechanix-pkgs = import ../pkgs { inherit pkgs; };
	mechanix-gui = mechanix-pkgs.gui;
in
{
	options = {
		mechanix.mechanix-shell = {
			enable = lib.mkEnableOption "the Mechanix Shell";
		};
	};
	config = lib.mkIf cfg.enable {
		environment.systemPackages = [
			mechanix-gui
			mechanix-pkgs.phoc
		];

		mechanix.mechanix-apps.enable = lib.mkDefault true;

		networking.networkmanager.enable = true;

		services.dbus.packages = [ mechanix-gui ];

		services.greetd = {
			enable = true;
			settings = {
				default_session = {
					command = "${pkgs.greetd}/bin/agreety --cmd /bin/sh";
					user = "greeter";
				};
				initial_session = {
					command = "phoc -E mechanix-launcher";
					user = "mecha";
				};
			};
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
