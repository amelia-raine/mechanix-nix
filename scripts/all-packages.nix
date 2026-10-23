{
	pkgs ? import <nixpkgs> {},
	mechanix-pkgs ? import ../pkgs { inherit pkgs; }
}:
let
	inherit (pkgs) lib stdenv;
in
[
	mechanix-pkgs.gui
	mechanix-pkgs.extension-service
	mechanix-pkgs.phoc
] ++
(builtins.attrValues mechanix-pkgs.apps) ++
(lib.optional stdenv.hostPlatform.isAarch64 mechanix-pkgs.hardware.comet-imx8mp.linux)
