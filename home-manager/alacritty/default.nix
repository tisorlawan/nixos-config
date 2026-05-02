{ pkgs }:

pkgs.stdenv.mkDerivation {
  name = "alacritty-wrapped";
  dontUnpack = true;

  buildInputs = with pkgs; [ alacritty libglvnd mesa ];

  installPhase = ''
    mkdir -p $out/bin
    # Alacritty itself needs Nix GL/Mesa when running on Ubuntu.  The interactive
    # shell is cleaned separately by ~/.scripts/clean-terminal-shell so dev
    # shells don't inherit these graphics overrides.
    makeWrapper ${pkgs.alacritty}/bin/alacritty $out/bin/alacritty \
      --set LD_LIBRARY_PATH "${pkgs.libglvnd}/lib:${pkgs.mesa}/lib"
  '';

  nativeBuildInputs = [ pkgs.makeWrapper ];
}
