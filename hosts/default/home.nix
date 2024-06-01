{ config, pkgs, ... }:

{
  home.username = "tiso";
  home.homeDirectory = "/home/tiso";

  home.stateVersion = "23.11";

  home.packages = with pkgs; [
    neovim
    tmux
    gcc
    starship
    zoxide
    wezterm
    atool
    dpkg

    noto-fonts
    (pkgs.nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
    material-icons

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')
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

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
  programs.rofi.enable = true;
  programs.fd.enable = true;
  programs.fzf.enable = true;
  programs.htop.enable = true;
  programs.ripgrep.enable = true;
  programs.bat.enable = true;
  programs.eza.enable = true;

  home.file.".config/rofi" = { source = ../../files/cfg/config/rofi; };
  home.file.".config/alacritty.toml" = { source = ../../files/cfg/config/alacritty.toml; };
  home.file.".config/starship.toml" = { source = ../../files/cfg/config/starship.toml; };
  home.file.".config/greenclip.toml" = { source = ../../files/cfg/config/greenclip.toml; };
  home.file.".config/user-dirs.dirs" = { source = ../../files/cfg/config/user-dirs.dirs; };
  home.file.".config/bspwm" = { source = ../../files/cfg/config/bspwm; };
  home.file.".config/dunst" = { source = ../../files/cfg/config/dunst; };
  home.file.".config/picom" = { source = ../../files/cfg/config/picom; };
  home.file.".config/polybar" = { source = ../../files/cfg/config/polybar; };
  home.file.".config/sxhkd" = { source = ../../files/cfg/config/sxhkd; };
  home.file.".config/redshift" = { source = ../../files/cfg/config/redshift; };
  home.file.".config/wezterm" = { source = ../../files/cfg/config/wezterm; };
  home.file.".config/yazi" = { source = ../../files/cfg/config/yazi; };
  home.file.".config/mpd" = { source = ../../files/cfg/config/mpd; };
  home.file.".config/mpv" = { source = ../../files/cfg/config/mpv; };
  home.file.".images" = { source = ../../files/cfg/images; };
  home.file.".gitconfig" = { source = ../../files/cfg/gitconfig; };
  home.file.".tmux.conf" = { source = ../../files/cfg/tmux.conf; };
  home.file.".scripts" = { source = ../../files/cfg/scripts; };
}
