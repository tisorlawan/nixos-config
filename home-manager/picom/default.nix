{ pkgs }:

pkgs.stdenv.mkDerivation {
  name = "picom-wrapped";
  dontUnpack = true;

  buildInputs = with pkgs; [ picom libglvnd mesa.drivers ];

  installPhase = ''
    mkdir -p $out/bin
    makeWrapper ${pkgs.picom}/bin/picom $out/bin/picom \
      --set LD_LIBRARY_PATH "${pkgs.libglvnd}/lib:${pkgs.mesa.drivers}/lib"
  '';

  nativeBuildInputs = [ pkgs.makeWrapper ];
}
