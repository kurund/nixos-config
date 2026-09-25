{
  description = "NixOS setup";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  outputs = { self, nixpkgs }: {
    nixosConfigurations.lime = nixpkgs.lib.nixosSystem {
      modules = [ ./configuration.nix ];
    };
  };
}
