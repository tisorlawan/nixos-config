{ pkgs, inputs ? {}, nixpkgs-unstable ? null }:

let
  pkgs-unstable =
    if nixpkgs-unstable == null
    then pkgs
    else if nixpkgs-unstable ? legacyPackages
    then nixpkgs-unstable.legacyPackages.${pkgs.system}
    else nixpkgs-unstable;

  zed-editor-pkg =
    # Prefer the packaged binary from nixpkgs (avoids rebuilding from source and
    # the network-only cargo-about step that currently fails in the Zed flake).
    if pkgs-unstable ? zed-editor then pkgs-unstable.zed-editor
    else if pkgs ? zed-editor then pkgs.zed-editor
    else inputs.zed-editor.packages.${pkgs.system}.default;
in

pkgs.stdenv.mkDerivation {
  name = "zed-editor-wrapped";
  dontUnpack = true;
  buildInputs = with pkgs; [ zed-editor-pkg libglvnd mesa ];
  installPhase = ''
    mkdir -p $out/bin
    # Upstream binary is currently named "zeditor"; provide a stable "zed-editor" entry point.
    makeWrapper ${zed-editor-pkg}/bin/zeditor $out/bin/zed-editor \
      --set LD_LIBRARY_PATH "${pkgs.libglvnd}/lib:${pkgs.mesa}/lib"
  '';
  nativeBuildInputs = [ pkgs.makeWrapper ];
}
