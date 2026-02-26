{
  description = "My NixOs system"
  
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
  };

  outputs = { self, nikpkgs }; {
    nixosConfiguration.ConceptD =
      nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";

        modules = [
          ./hosts/ConceptD/configuration.nix
        ];
      };
  };
}
