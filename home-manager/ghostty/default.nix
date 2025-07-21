{ pkgs, inputs, nixpkgs-unstable ? null }:

let
  pkgs-unstable =
    if nixpkgs-unstable != null
    then nixpkgs-unstable.legacyPackages.${pkgs.system}
    else pkgs;
  
  ghostty-pkg = inputs.ghostty.packages.${pkgs.system}.default;
in

pkgs.stdenv.mkDerivation {
  name = "ghostty-wrapped";
  dontUnpack = true;
  buildInputs = with pkgs; [ ghostty-pkg libglvnd mesa ];
  installPhase = ''
    mkdir -p $out/bin
    makeWrapper ${ghostty-pkg}/bin/ghostty $out/bin/ghostty \
      --set LD_LIBRARY_PATH "${pkgs.libglvnd}/lib:${pkgs.mesa}/lib"
  '';
  nativeBuildInputs = [ pkgs.makeWrapper ];
}
