{ config, pkgs, ... }:

{
  home.username = "tiso";
  home.homeDirectory = "/home/tiso";

  home.stateVersion = "23.11"; # Please read the comment before changing.

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

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

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

    XDG_DESKTOP_DIR="$HOME/desktop";
    XDG_DOWNLOAD_DIR="$HOME/downloads";
    XDG_TEMPLATES_DIR="$HOME/templates";
    XDG_PUBLICSHARE_DIR="$HOME/public";
    XDG_DOCUMENTS_DIR="$HOME/documents";
    XDG_MUSIC_DIR="$HOME/music";
    XDG_PICTURES_DIR="$HOME/pictures";
    XDG_VIDEOS_DIR="$HOME/videos";
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
}
