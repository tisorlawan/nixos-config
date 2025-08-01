{ pkgs, nixpkgs-unstable, inputs, ... }:

let
  pkgs-unstable = nixpkgs-unstable;
in
{
  home.username = "agung-b-sorlawan";
  home.homeDirectory = "/home/agung-b-sorlawan";


  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "24.11"; # Please read the comment before changing.


  home.packages = with pkgs; [
    # pkgs-unstable.windsurf
    starship
    atuin
    (pkgs.callPackage ./alacritty { })
    (pkgs.callPackage ./ghostty { inherit inputs; nixpkgs-unstable = nixpkgs-unstable; })

    #### @DESKTOP ENVIRONMENT ####
    dunst
    libinput
    libnotify
    (pkgs.callPackage ./picom { })
    # polybar
    # polybar-pulseaudio-control
    xdotool
    xclip
    xdg-user-dirs
    xorg.xbacklight
    xorg.xkill
    xorg.xdpyinfo
    xorg.xwininfo
    xorg.xmodmap
    networkmanagerapplet
    sxhkd
    pkgs-unstable.haskellPackages.greenclip
    redshift
    maim
    (flameshot.override { enableWlrSupport = true; })
    adwaita-icon-theme
    file-roller
    eww
    rofi
    util-linux
    awscli2
    postman
    rclone
    nushell
    foliate

    #### @CLI UTILITIES ####
    bat
    delta
    difftastic
    dust
    eza
    fd
    jq
    ripgrep
    lazygit
    pkgs-unstable.jujutsu
    fzf
    # skim
    # htop
    btop
    tmux
    zellij
    wget
    atool
    curl
    file
    pkgs-unstable.neovim
    vim
    # emacs-gtk
    sbcl
    killall
    yazi
    yt-dlp
    zoxide
    nethogs
    iw
    acpi
    brightnessctl
    unzip
    p7zip
    zip
    openssl
    jless
    rlwrap
    slides
    carapace # completion

    #### @DEVELOPMENT TOOLS ####
    man-pages
    man-pages-posix
    tldr
    gcc
    gnumake
    cmake
    just
    gdb
    valgrind
    pkg-config
    gitFull
    git-lfs
    protobuf
    lldb
    typst

    #### @PYTHON DEVELOPMENT ####
    # rye
    # python313
    ruff
    pyright
    virtualenv
    black
    isort
    python312Packages.pytest
    python312Packages.coverage
    pre-commit
    sonarlint-ls
    poetry
    poetryPlugins.poetry-plugin-shell

    #### @LANGUAGES AND LSP ####
    go
    nodejs_22
    bun
    # rustup
    # sccache
    # leptosfmt
    zig
    zls
    # livebook
    stylua
    lua5_1
    lua-language-server
    luarocks
    racket
    marksman
    # clang
    # clang-tools
    gopls
    golines
    gofumpt
    gotools
    ghc
    cabal-install
    haskellPackages.cabal-fmt
    haskell-language-server
    stack
    prettierd
    nil
    nixpkgs-fmt
    biome
    wabt

    #### @DATABASES AND SERVICES ####
    redis
    postgresql
    sqlite
    litecli
    docker
    # kubectl
    # k9s

    #### @DOCUMENT AND PDF TOOLS ####
    pdftk
    # poppler_utils
    jupyter-all
    ghostscript
    # (texlive.combine {
    #   inherit (texlive)
    #     scheme-medium# Base TeX Live scheme
    #     wrapfig# For text wrapping around figures
    #     capt-of# For captions outside floats
    #     # rotating         # For rotating text and figures
    #     hyperref# For hyperlinks
    #     ulem# For underlining
    #     # amsmath amssymb  # For mathematical formulas
    #     ;
    # })

    #### @SYSTEM UTILITIES ####
    trashy
    # trunk
    cocogitto
    mold
    # google-cloud-sdk
    openconnect
    neofetch
    rsync
    inotify-tools
    # php
    # php82Packages.composer
    jmtpfs
    fish

    #### @MEDIA TOOLS ####
    mpv
    exiftool
    feh
    ffmpeg-full
    ffmpegthumbnailer
    pavucontrol
    pulseaudio
    wireplumber
    alsa-utils
    poppler
    imagemagick
    mediainfo
    # wf-recorder

    #### @GUI APPLICATIONS ####
    neovide
    evince
    sioyek
    # foliate
    nautilus
    pcmanfm
    # pkgs-unstable.google-chrome
    brave
    # libreoffice
    # firefox
    # (pkgs.callPackage ./zoom-us { })
    # (pkgs.callPackage ./zoom-us { nixpkgs-unstable = nixpkgs-unstable; }) # use snap install
    pkgs-unstable.xournalpp
    wkhtmltopdf
    # transmission_4-gtk
    telegram-desktop
    inlyne

    # #### @HARDWARE AND GRAPHICS ####
    glxinfo
    # intel-gpu-tools
    # mesa-demos

    nixpkgs-unstable.noto-fonts
    nixpkgs-unstable.noto-fonts-emoji
    nixpkgs-unstable.noto-fonts-cjk-sans-static
    nixpkgs-unstable.noto-fonts-cjk-serif-static
    nixpkgs-unstable.material-icons
    nixpkgs-unstable.symbola
    # typestarFont # Note: Ensure this package exists in your nixpkgs; it may be custom or from a specific source
    nixpkgs-unstable.nerd-fonts.jetbrains-mono
    nixpkgs-unstable.nerd-fonts.blex-mono
    nixpkgs-unstable.cascadia-code
    nixpkgs-unstable.nerd-fonts.jetbrains-mono
    nixpkgs-unstable.fira-code
    nixpkgs-unstable.hack-font
    nixpkgs-unstable.source-code-pro
    nixpkgs-unstable.ibm-plex
    nixpkgs-unstable.inconsolata
    nixpkgs-unstable.liberation_ttf

    ngrok
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

  # fonts.fontconfig.enable = true;

  # Optional: Define default fonts for fontconfig
  # home.file.".config/fontconfig/fonts.conf".text = ''
  #   <?xml version="1.0"?>
  #   <!DOCTYPE fontconfig SYSTEM "fonts.dtd">
  #   <fontconfig>
  #     <!-- Default fonts -->
  #     <alias>
  #       <family>monospace</family>
  #       <prefer>
  #         <family>JetBrainsMono Nerd Font</family>
  #       </prefer>
  #     </alias>
  #     <alias>
  #       <family>sans-serif</family>
  #       <prefer>
  #         <family>Noto Sans</family>
  #         <family>Symbola</family>
  #       </prefer>
  #     </alias>
  #     <alias>
  #       <family>serif</family>
  #       <prefer>
  #         <family>Noto Serif</family>
  #         <family>Symbola</family>
  #       </prefer>
  #     </alias>
  #     <alias>
  #       <family>emoji</family>
  #       <prefer>
  #         <family>Noto Color Emoji</family>
  #       </prefer>
  #     </alias>
  #   </fontconfig>
  # '';

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
  #  /etc/profiles/per-user/agung-b-sorlawan/etc/profile.d/hm-session-vars.sh

  home.sessionVariables = {
    EDITOR = "nvim";
    WLAN_IFACE = "wlp0s20f3";
    SXHKD_SHELL = "/bin/sh";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
