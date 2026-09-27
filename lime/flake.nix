{
  description = "NixOS setup";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  inputs.nixos-hardware.url = "github:NixOS/nixos-hardware";
  outputs = { self, nixpkgs, nixos-hardware }: {
    nixosConfigurations.lime = nixpkgs.lib.nixosSystem {
      modules = [
        ./configuration.nix
        nixos-hardware.nixosModules.lenovo-thinkpad-x1-7th-gen
      ];
    };
  };
}
