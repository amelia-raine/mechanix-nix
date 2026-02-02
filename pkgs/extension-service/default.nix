{
	formats,
	rustPlatform,
	mechanixSrc
}:
let
	tomlFormat = formats.toml {};
	cargoToml = (fromTOML (builtins.readFile "${mechanixSrc}/Cargo.toml"));
	newCargoToml = cargoToml // {
		workspace = cargoToml.workspace // {
			members = [
				"services/extensions"
			];
		};
	};
in
rustPlatform.buildRustPackage {
	pname = "mechanix-extension-service";
	version = "0.0.1";
	src = mechanixSrc;

	cargoLock.lockFile = ./Cargo.lock;

	postPatch = ''
		cp ${tomlFormat.generate "Cargo.toml" newCargoToml} Cargo.toml
		cp ${./Cargo.lock} Cargo.lock
		chmod +w Cargo.lock
	'';
}
