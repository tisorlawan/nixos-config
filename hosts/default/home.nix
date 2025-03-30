{ config, pkgs, ... }:

{
  home.username = "tiso";
  home.homeDirectory = "/home/tiso";

  home.stateVersion = "23.11";

  home.packages = with pkgs; [
    tmux
    gcc
    starship
    zoxide
    wezterm
    atool
    dpkg
  ];

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. These will be explicitly sourced when using a
  # shell provided by Home Manager. If you don't want to manage your shell
  # through Home Manager then you have to manually source 'hm-session-vars.sh'
  # located at either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/tiso/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
    EDITOR = "nvim";
  };

  xdg.desktopEntries = {
    neovide = {
      name = "Neovide";
      genericName = "GUI neovim";
      comment = "Edit text files";
      exec = "neovide %F";
      icon = "neovide";
      mimeType = [
        "text/english"
        "text/plain"
        "text/x-makefile"
        "text/x-c++hdr"
        "text/x-c++src"
        "text/x-chdr"
        "text/x-csrc"
        "text/x-java"
        "text/x-moc"
        "text/x-pascal"
        "text/x-tcl"
        "text/x-tex"
        "application/x-shellscript"
        "text/x-c"
        "text/x-c++"
        "application/json"
      ];
      type = "Application";
      categories = [
        "Utility"
        "TextEditor"
      ];
    };
  };

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      # "x-scheme-handler/http" = [ "google-chrome.desktop" ];
      # "x-scheme-handler/https" = [ "google-chrome.desktop" ];
      "x-scheme-handler/http" = [ "brave-browser.desktop" ];
      "x-scheme-handler/https" = [ "brave-browser.desktop" ];
      "text/html" = [ "brave-browser.desktop" ];

      # PDF
      "application/pdf" = [ "org.gnome.Evince.desktop" ];

      # Images
      "image/jpeg" = [ "feh.desktop" ];
      "image/png" = [ "feh.desktop" ];
      "image/gif" = [ "feh.desktop" ];
      "image/webp" = [ "feh.desktop" ];

      # Video
      "video/mp4" = [ "mpv.desktop" ];
      "video/x-matroska" = [ "mpv.desktop" ];
      "video/webm" = [ "mpv.desktop" ];

      # Text/Code
      "text/plain" = [ "neovide.desktop" ];
      "text/markdown" = [ "neovide.desktop" ];
      "text/english" = [ "neovide.desktop" ];
      "text/x-makefile" = [ "neovide.desktop" ];
      "text/x-c++hdr" = [ "neovide.desktop" ];
      "text/x-c++src" = [ "neovide.desktop" ];
      "text/x-chdr" = [ "neovide.desktop" ];
      "text/x-csrc" = [ "neovide.desktop" ];
      "text/x-java" = [ "neovide.desktop" ];
      "text/x-moc" = [ "neovide.desktop" ];
      "text/x-pascal" = [ "neovide.desktop" ];
      "text/x-tcl" = [ "neovide.desktop" ];
      "text/x-tex" = [ "neovide.desktop" ];
      "text/x-c" = [ "neovide.desktop" ];
      "text/x-c++" = [ "neovide.desktop" ];
      "application/json" = [ "neovide.desktop" ];
      "application/x-shellscript" = [ "neovide.desktop" ];

      # Archives
      "application/zip" = [ "org.gnome.FileRoller.desktop" ];
      "application/x-7z-compressed" = [ "org.gnome.FileRoller.desktop" ];
      "application/x-rar" = [ "org.gnome.FileRoller.desktop" ];
      "application/x-tar" = [ "org.gnome.FileRoller.desktop" ];
      "application/gzip" = [ "org.gnome.FileRoller.desktop" ];
      "application/x-gzip" = [ "org.gnome.FileRoller.desktop" ];
      "application/x-bzip2" = [ "org.gnome.FileRoller.desktop" ];
      "application/x-xz" = [ "org.gnome.FileRoller.desktop" ];
      "application/x-compress" = [ "org.gnome.FileRoller.desktop" ];

      # File browser
      "inode/directory" = [ "org.gnome.Nautilus.desktop" ];

      # Ebooks
      "application/epub+zip" = [ "com.github.johnfactotum.Foliate.desktop" ];
      "application/x-cbr" = [ "YACReader.desktop" ];
      "application/x-cbz" = [ "YACReader.desktop" ];
    };
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # home.file.".config/rofi" = { source = ../../files/cfg/config/rofi; };
  # home.file.".config/alacritty.toml" = { source = ../../files/cfg/config/alacritty.toml; };
  # home.file.".config/starship.toml" = { source = ../../files/cfg/config/starship.toml; };
  # home.file.".config/greenclip.toml" = { source = ../../files/cfg/config/greenclip.toml; };
  # home.file.".config/user-dirs.dirs" = { source = ../../files/cfg/config/user-dirs.dirs; };
  # home.file.".config/bspwm" = { source = ../../files/cfg/config/bspwm; };
  # home.file.".config/dunst" = { source = ../../files/cfg/config/dunst; };
  # home.file.".config/picom" = { source = ../../files/cfg/config/picom; };
  # home.file.".config/polybar" = { source = ../../files/cfg/config/polybar; };
  # home.file.".config/sxhkd" = { source = ../../files/cfg/config/sxhkd; };
  # home.file.".config/redshift" = { source = ../../files/cfg/config/redshift; };
  # home.file.".config/wezterm" = { source = ../../files/cfg/config/wezterm; };
  # home.file.".config/yazi" = { source = ../../files/cfg/config/yazi; };
  # home.file.".config/mpd" = {
  #   source = ../../files/cfg/config/mpd;
  #   recursive = true;
  # };
  # home.file.".config/mpv" = {
  #   source = ../../files/cfg/config/mpv;
  #   recursive = true;
  # };
  # home.file.".images" = { source = ../../files/cfg/images; };
  # home.file.".gitconfig" = { source = ../../files/cfg/gitconfig; };
  # home.file.".tmux.conf" = { source = ../../files/cfg/tmux.conf; };
  # home.file.".scripts" = { source = ../../files/cfg/scripts; };
}
