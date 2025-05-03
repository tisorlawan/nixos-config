{ pkgs, nixpkgs-unstable ? null }:

let
  pkgs-unstable = if nixpkgs-unstable != null 
                  then nixpkgs-unstable.legacyPackages.${pkgs.system}
                  else pkgs;
in

pkgs.stdenv.mkDerivation {
  name = "ghostty-wrapped";
  dontUnpack = true;
  buildInputs = with pkgs; [ ghostty libglvnd mesa.drivers ];
  installPhase = ''
    mkdir -p $out/bin
    makeWrapper ${pkgs.ghostty or pkgs-unstable.ghostty}/bin/ghostty $out/bin/ghostty \
      --set LD_LIBRARY_PATH "${pkgs.libglvnd}/lib:${pkgs.mesa.drivers}/lib"
  '';
  nativeBuildInputs = [ pkgs.makeWrapper ];
}
