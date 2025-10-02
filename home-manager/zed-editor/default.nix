{ pkgs, inputs, nixpkgs-unstable ? null }:

let
  pkgs-unstable =
    if nixpkgs-unstable != null
    then nixpkgs-unstable.legacyPackages.${pkgs.system}
    else pkgs;

  zed-editor-pkg = inputs.zed-editor.packages.${pkgs.system}.default;
in

pkgs.stdenv.mkDerivation {
  name = "zed-editor-wrapped";
  dontUnpack = true;
  buildInputs = with pkgs; [ zed-editor-pkg libglvnd mesa ];
  installPhase = ''
    mkdir -p $out/bin
    makeWrapper ${zed-editor-pkg}/bin/zed-editor $out/bin/zed-editor \
      --set LD_LIBRARY_PATH "${pkgs.libglvnd}/lib:${pkgs.mesa}/lib"
  '';
  nativeBuildInputs = [ pkgs.makeWrapper ];
}
