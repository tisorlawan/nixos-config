{
  description = "Nixos config flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/64c08a7c";
    home-manager.url = "github:nix-community/home-manager/release-26.05";

    zotimer.url = "github:tisorlawan/zotimer";
    ghostty.url = "github:ghostty-org/ghostty/v1.2.3";
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, home-manager, ... }@inputs:
    let
      system = "x86_64-linux";
      # pkgs = import nixpkgs {
      #   inherit system;
      #   config.allowUnfree = true;
      # };
    in
    {
      nixosConfigurations = {
        default = nixpkgs.lib.nixosSystem rec {
          inherit system;
          specialArgs = {
            inherit inputs;
            pkgs-unstable = import nixpkgs-unstable {
              inherit system;
              config.allowUnfree = true;
            };
          };

          modules = [
            ./hosts/default/configuration.nix
            home-manager.nixosModules.home-manager
            {
              nixpkgs.config.allowUnfree = true;
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.tiso = import ./hosts/default/home.nix;
            }
          ];
        };
      };
    };
}
