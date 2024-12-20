{
  description = "Nixos config flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/d3c42f18";
    home-manager.url = "github:nix-community/home-manager/release-24.11";

    # iwmenu.url = "github:e-tho/iwmenu";
    zotimer.url = "github:tisorlawan/zotimer";
    television.url = "github:alexpasmantier/television";
  };

  outputs = { nixpkgs, nixpkgs-unstable, home-manager, ... }@inputs:
    {
      nixosConfigurations = {
        default = nixpkgs.lib.nixosSystem rec {
          system = "x86_64-linux";
          specialArgs = {
            pkgs = import nixpkgs {
              inherit system;
              config.allowUnfree = true;
            };
            pkgs-unstable = import nixpkgs-unstable {
              inherit system;
              config.allowUnfree = true;
            };
            inherit inputs;
          };

          modules = [
            ./hosts/default/configuration.nix
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.tiso = import ./hosts/default/home.nix;

              # Optionally, use home-manager.extraSpecialArgs to pass
              # arguments to home.nix
            }
          ];
        };
      };
    };
}
