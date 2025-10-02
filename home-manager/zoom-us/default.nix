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
  pname = "zoom-us-wrapped";
  version = zoomPkg.version or "unspecified";
  src = zoomPkg;

  nativeBuildInputs = [ pkgs.makeWrapper ];

  # Include GL libs so the wrapper LD_LIBRARY_PATH can reference them.
  buildInputs = with pkgs; [ libglvnd mesa ];

  installPhase = ''
    mkdir -p $out/bin

    real_zoom="${zoomPkg}/bin/zoom"

    # Common stability tweaks:
    # - QT_XCB_GL_INTEGRATION=none avoids black/blank windows on some GPUs
    # - LD_LIBRARY_PATH ensures GL drivers resolve at runtime
    makeWrapper "$real_zoom" "$out/bin/zoom" \
      --set QT_XCB_GL_INTEGRATION none \
      --set LD_LIBRARY_PATH "${pkgs.libglvnd}/lib:${pkgs.mesa}/lib"

    # Desktop integration for xdg-open and browsers to handle zoommtg:// links
    mkdir -p $out/share/applications $out/share/icons $out/share/pixmaps

    # Reuse upstream icons if available
    if [ -d "${zoomPkg}/share/icons" ]; then
      ln -s "${zoomPkg}/share/icons" "$out/share/icons"
    fi
    if [ -d "${zoomPkg}/share/pixmaps" ]; then
      ln -s "${zoomPkg}/share/pixmaps" "$out/share/pixmaps"
    fi

    cat > $out/share/applications/zoomus-wrapped.desktop <<EOF
    [Desktop Entry]
    Name=Zoom
    Comment=Zoom Video Conference
    Exec=$out/bin/zoom %U
    Terminal=false
    Type=Application
    Icon=zoom
    Categories=Network;Chat;VideoConference;
    MimeType=x-scheme-handler/zoommtg;x-scheme-handler/zoomphonecall;
    StartupWMClass=zoom
    EOF
  '';

  dontConfigure = true;
  dontBuild = true;
  dontInstall = false;
}
