{ pkgs }:

pkgs.stdenv.mkDerivation {
  name = "picom-wrapped";
  dontUnpack = true;

  buildInputs = with pkgs; [ picom libglvnd mesa ];

  installPhase = ''
    mkdir -p $out/bin
    makeWrapper ${pkgs.picom}/bin/picom $out/bin/picom \
      --set LD_LIBRARY_PATH "${pkgs.libglvnd}/lib:${pkgs.mesa}/lib"
  '';

  nativeBuildInputs = [ pkgs.makeWrapper ];
}
