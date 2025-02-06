{ pkgs, pkgs-unstable, inputs, ... }:
let
  typestarFont = pkgs.stdenv.mkDerivation {
    name = "typestar-ocr-regular";
    src = builtins.path {
      path = ../../files/fonts/typestar_ocr_regular;
      name = "typestar-ocr-regular";
    };
    phases = [ "installPhase" ];
    installPhase = ''
      mkdir -p $out/share/fonts/opentype
      cp $src/Typestar_OCR_Regular.otf $out/share/fonts/opentype/Typestar_OCR_Regular.otf
    '';
  };
in
{
  imports = [ ./hardware-configuration.nix ];
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;
  home-manager.backupFileExtension = "backup";

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.supportedFilesystems = [ "ntfs" ];
  security.rtkit.enable = true;

  hardware = {
    graphics = {
      enable = true;
      extraPackages = with pkgs; [
        intel-media-driver # LIBVA_DRIVER_NAME=iHD
        # intel-vaapi-driver # LIBVA_DRIVER_NAME=i965 (older but works better for Firefox/Chromium)
        libvdpau-va-gl
      ];
    };
    pulseaudio.enable = false;
  };

  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;
  networking.hostName = "sorlawan";
  networking.hostFiles = [ ../../files/etc-hosts ];

  time.timeZone = "Asia/Jakarta";

  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  console.useXkbConfig = true;

  nix.settings.trusted-users = [ "root" "tiso" ];

  services = {
    gvfs.enable = true;
    udisks2.enable = true;
    libinput = { enable = true; touchpad.tappingDragLock = false; };
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      # If you want to use JACK applications, uncomment this
      jack.enable = true;

      # use the example session manager (no others are packaged yet so this is enabled by default,
      # no need to redefine it in your config for now)
      #media-session.enable = true;
    };
    xserver = {
      enable = true;
      # desktopManager.gnome.enable = true;
      # desktopManager.xfce.enable = true;
      windowManager.bspwm.enable = true;
      xkb = { layout = "us"; variant = ""; options = "caps:swapescape"; };
    };
    displayManager.sddm.enable = true;
    locate = { enable = true; package = pkgs.mlocate; localuser = null; };
  };

  programs = {
    fish.enable = true;
    ssh.askPassword = "";
    nix-ld = { enable = true; libraries = [ ]; };
    hyprland = { enable = true; xwayland.enable = true; };
    steam = {
      enable = false;
      remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
      dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
      localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network Game Transfers
    };
    # Some programs need SUID wrappers, can be configured further or are
    # started in user sessions.
    # programs.mtr.enable = true;
    # programs.gnupg.agent = {
    #   enable = true;
    #   enableSSHSupport = true;
    # };
  };

  xdg = {
    portal = {
      enable = true;
      extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    };
  };

  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "iHD"; # Force intel-media-driver
    SSH_ASKPASS = ""; # disable ask pass UI
    # SSL_CERT_FILE = /etc/ssl/certs/ca-bundle.crt;
    BAT_THEME = "base16";

    WLR_NO_HARDWARE_CURSORS = "1"; # If your cursor becomes invisible
    NIXOS_OZONE_WL = "1"; # Hint electron apps to use wayland

    WLAN_IFACE = "wlp0s20f3";
    SXHKD_SHELL = "/bin/sh";
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.tiso = {
    isNormalUser = true;
    description = "Agung Baptiso Sorlawan";
    extraGroups = [ "networkmanager" "wheel" "audio" "video" ];
    packages = [ ];
    shell = pkgs.fish;
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    #### @TERMINAL EMULATORS ####
    starship
    atuin
    alacritty
    pkgs-unstable.ghostty

    #### @DESKTOP ENVIRONMENT ####
    dunst
    libinput
    libnotify
    picom
    polybar
    polybar-pulseaudio-control
    xdotool
    xclip
    xdg-user-dirs
    xorg.xbacklight
    xorg.xkill
    xorg.xdpyinfo
    xorg.xwininfo
    networkmanagerapplet
    sxhkd
    haskellPackages.greenclip
    redshift
    maim
    (flameshot.override { enableWlrSupport = true; })
    adwaita-icon-theme
    file-roller

    #### @WAYLAND SPECIFIC ####
    grim
    hyprpaper
    slurp
    eww
    wofi
    wl-clipboard
    socat
    clipse
    rofi-wayland

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
    fzf
    skim
    htop
    btop
    tmux
    zellij
    wget
    atool
    curl
    file
    pkgs-unstable.neovim
    vim
    inputs.helix.packages.${pkgs.system}.default
    killall
    unrar
    pkgs-unstable.yazi
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
    inputs.zotimer.packages.${pkgs.system}.default
    rlwrap
    slides

    #### @DEVELOPMENT TOOLS ####
    pkgs-unstable.devenv
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

    #### @PYTHON DEVELOPMENT ####
    # rye
    python313
    pkgs-unstable.ruff
    pkgs-unstable.ruff-lsp
    pyright
    virtualenv
    black
    isort

    #### @LANGUAGES AND LSP ####
    go
    nodejs_22
    pkgs-unstable.bun
    rustup
    sccache
    leptosfmt
    pkgs-unstable.zig
    pkgs-unstable.zls
    pkgs-unstable.beam.packages.erlang_27.elixir_1_17
    pkgs-unstable.elixir-ls
    livebook
    stylua
    lua5_1
    lua-language-server
    luarocks
    guile # scheme
    chicken # sheme
    marksman
    clang
    clang-tools
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

    #### @DATABASES AND SERVICES ####
    redis
    postgresql
    sqlite
    litecli
    docker
    kubectl
    k9s

    #### @DOCUMENT AND PDF TOOLS ####
    pdftk
    qpdf
    wkhtmltopdf
    antiword
    poppler_utils
    xsv
    jupyter-all
    ghostscript
    texliveSmall

    #### @SYSTEM UTILITIES ####
    trashy
    trunk
    cocogitto
    mold
    google-cloud-sdk
    openconnect
    neofetch
    rsync
    inotify-tools
    sbcl
    php
    php82Packages.composer
    ngrok

    #### @MEDIA TOOLS ####
    mpv
    exiftool
    feh
    ffmpeg-full
    ffmpegthumbnailer
    pavucontrol
    pulseaudio
    alsa-utils
    poppler
    imagemagick
    mediainfo
    wf-recorder

    #### @GUI APPLICATIONS ####
    (callPackage ./../../pkgs/toptracker.nix { })
    neovide
    evince
    yacreader
    foliate
    nautilus
    pcmanfm
    pkgs-unstable.google-chrome
    libreoffice
    postman
    firefox
    zoom-us
    xournalpp
    transmission_4-gtk
    telegram-desktop
    inlyne

    #### @HARDWARE AND GRAPHICS ####
    glxinfo
    intel-gpu-tools
    mesa-demos
  ];

  virtualisation.docker.enable = true;
  virtualisation.docker.rootless = {
    enable = false;
    setSocketVariable = true;
  };

  # xdg.mime.enable = true;
  # xdg.mime.defaultApplications = {
  #   "application/pdf" = "org.gnome.Evince.desktop";
  #   "image/png" = "feh.desktop";
  #   "audio/flac" = "mpv.desktop";
  #   "audio/mp3" = "mpv.desktop";
  #   "text/plain" = "neovide.desktop";
  #   "text/html" = "google-chrome.desktop";
  #   "application/json" = "neovide.desktop";
  # };

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  system.stateVersion = "23.11"; # Did you read the comment?

  fonts = {
    enableDefaultPackages = false;
    packages = with pkgs; [
      noto-fonts
      noto-fonts-emoji
      noto-fonts-cjk-sans
      material-icons
      symbola
      typestarFont

      # Popular monospace/programming fonts
      (nerdfonts.override { fonts = [ "JetBrainsMono" "IBMPlexMono" "CascadiaCode" ]; })
      fira-code # Fira Code (with ligatures)
      hack-font # Hack
      source-code-pro # Adobe Source Code Pro
      ibm-plex # IBM Plex Mono
      cascadia-code # Cascadia Code
      inconsolata # Inconsolata
      # ubuntu-mono # Ubuntu Mono
      # dejavu-fonts # DejaVu Sans Mono
      liberation_ttf # Liberation Mono
    ];
    fontDir = {
      enable = true;
      decompressFonts = true;
    };
    fontconfig = {
      enable = true;
      defaultFonts = {
        monospace = [ "JetBrainsMono Nerd Font" ];
        sansSerif = [ "Noto Sans" "Symbola" ];
        serif = [ "Noto Serif" "Symbola" ];
        emoji = [ "Noto Color Emoji" ];
      };
    };
  };
}
