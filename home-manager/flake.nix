{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/release-25.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/2d293cbf";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    zed-editor = {
      url = "github:zed-industries/zed/v0.214.7";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # ghostty.url = "github:ghostty-org/ghostty/298f11166d4762741dd84fb48c8f96a09d0fb326";
    ghostty.url = "github:ghostty-org/ghostty/v1.2.3";
    # nixpkgs.url = "github:nixos/nixpkgs/release-25.05";
    # nixpkgs-unstable.url = "github:nixos/nixpkgs/62b852f6";
    # home-manager = {
    #   url = "github:nix-community/home-manager/release-25.05";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, flake-utils, home-manager, ghostty, ... }:
    flake-utils.lib.eachDefaultSystem
      (system:
        let
          pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
          };
        in
        {
          formatter = pkgs.nixpkgs-fmt;

          devShells.default = pkgs.mkShell {
            buildInputs = [
              home-manager.packages.${system}.home-manager
            ];
            shellHook = ''
              echo "NixOS Home Manager development shell"
              echo "Run 'home-manager switch --flake .#agung-b-sorlawan' to build and activate"
            '';
          };
        }) // {
      # IMPORTANT: This is now outside the eachDefaultSystem function
      # This makes homeConfigurations available at the top level of the flake
      homeConfigurations = {
        "agung-b-sorlawan" = home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs {
            system = "x86_64-linux";
            config.allowUnfree = true;
          };
          extraSpecialArgs = {
            inherit nixpkgs;
            nixpkgs-unstable = import nixpkgs-unstable {
              system = "x86_64-linux";
              config.allowUnfree = true;
            };
            inputs = self.inputs;
          };
          modules = [ ./home.nix ];
        };
      };
    };
}
