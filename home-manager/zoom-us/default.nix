{ pkgs, nixpkgs-unstable ? null }:

let
  # pick zoom-us from unstable if passed in, otherwise from stable pkgs
  zoomPkg =
    if nixpkgs-unstable != null
      && builtins.hasAttr "legacyPackages" nixpkgs-unstable
    then nixpkgs-unstable.legacyPackages.${pkgs.system}.zoom-us
    else pkgs.zoom-us;
in

pkgs.stdenv.mkDerivation {
  pname = "zoom-us-no-glx-integration";
  version = zoomPkg.version or "6.2.10"; # fallback if version attr missing
  src = zoomPkg;

  # makeWrapper gives us the simple shell‐script wrapping tool
  nativeBuildInputs = [ pkgs.makeWrapper ];

  # no other deps are modified
  buildInputs = [ ];

  installPhase = ''
    mkdir -p $out/bin

    # Path to the real zoom binary inside the Nix store:
    real_zoom="${zoomPkg}/bin/zoom"

    # Wrap it in $out/bin/zoom setting only that one env‐var
    makeWrapper "$real_zoom" "$out/bin/zoom" \
      --set QT_XCB_GL_INTEGRATION none
  '';

  # Don’t try to run any tests, docs, etc.
  dontConfigure = true;
  dontBuild = true;
  dontInstall = false;
}
