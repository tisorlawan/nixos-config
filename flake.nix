{
  description = "Nixos config flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/62e0f05e";
    home-manager.url = "github:nix-community/home-manager/release-25.05";

    # iwmenu.url = "github:e-tho/iwmenu";
    zotimer.url = "github:tisorlawan/zotimer";
    # television.url = "github:alexpasmantier/television";
    ghostty.url = "github:ghostty-org/ghostty/37bac094c7bf1c602e3bfa115d8d7a70736b0e8e";
    helix.url = "github:helix-editor/helix/25.01";
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
