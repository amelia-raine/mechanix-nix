{
	pkgs,
	nixos-hardware
}:
{
	linux = import ./linux.nix { inherit pkgs nixos-hardware; };
}
