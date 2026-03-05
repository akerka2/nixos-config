{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }: {
    nixosConfigurations.yggdrasil = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./configuration.nix
        ./hosts/Yggdrasil/hardware-configuration.nix
        ./hosts/Yggdrasil/gpu.nix
         ./hosts/Yggdrasil/host.nix
        home-manager.nixosModules.home-manager {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.akerka = import ./home.nix;
        }
      ];
    };
  };
  
  nixosConfigurations.conceptd = nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    modules = [
      ./configuration.nix
      ./hosts/ConceptD/hardware-configuration.nix  # add when available
      ./hosts/ConceptD/gpu.nix
      ./hosts/ConceptD/host.nix
      home-manager.nixosModules.home-manager {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.users.akerka = import ./home.nix;
      }
    ];
  };
}
