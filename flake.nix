{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nixpkgs, home-manager, ... }: {
    nixosConfigurations.yggdrasil = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs; };  # Добавь эту строку
      modules = [
        ./configuration.nix
        ./desktop/configuration.nix
        ./desktop/hardware-configuration.nix
       
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.akerka = { imports = [
            ./home.nix
            ./desktop/home.nix
          ];};
        }
      ];
    };
    
    nixosConfigurations.conceptd = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs; };  # Добавь эту строку
      modules = [
        ./configuration.nix
        ./laptop/configuration.nix
        ./laptop/hardware-configuration.nix
       
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.akerka = { imports = [
            ./home.nix
            ./laptop/home.nix
          ];};
        }
      ];
    };    
  };
}
