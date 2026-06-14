{ pkgs, inputs ? null }:

let
  ghostty-pkg = inputs.ghostty.packages.${pkgs.system}.default;
in

pkgs.stdenv.mkDerivation {
  name = "ghostty-wrapped";
  dontUnpack = true;
  buildInputs = with pkgs; [ ghostty-pkg libglvnd mesa ];
  installPhase = ''
    mkdir -p $out/bin
    # Ghostty itself needs Nix GL/Mesa when running on Ubuntu.  The interactive
    # shell is cleaned separately by ~/.scripts/clean-terminal-shell so dev
    # shells don't inherit these graphics overrides.
    makeWrapper ${ghostty-pkg}/bin/ghostty $out/bin/ghostty \
      --set LD_LIBRARY_PATH "${pkgs.libglvnd}/lib:${pkgs.mesa}/lib"
  '';
  nativeBuildInputs = [ pkgs.makeWrapper ];
}
