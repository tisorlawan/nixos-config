# Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ pkgs, pkgs-unstable, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
    ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.supportedFilesystems = [ "ntfs" ];

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

  nix.settings.trusted-users = [ "root" "tiso" ];

  xdg.portal.enable = false;

  services.libinput.enable = true;
  services.libinput.touchpad.tappingDragLock = false;
  # Configure keymap in X11
  services.xserver = {
    enable = true;
    # desktopManager.gnome.enable = true;
    # desktopManager.xfce.enable = true;
    windowManager.bspwm.enable = true;

    xkb.layout = "us";
    xkb.variant = "";
    xkb.options = "caps:swapescape";

  };
  services.displayManager.sddm.enable = true;
  console.useXkbConfig = true;

  hardware.opengl = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver # LIBVA_DRIVER_NAME=iHD
      # intel-vaapi-driver # LIBVA_DRIVER_NAME=i965 (older but works better for Firefox/Chromium)
      libvdpau-va-gl
    ];
  };
  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "iHD"; # Force intel-media-driver
    WLR_NO_HARDWARE_CURSORS = "1"; # If your cursor becomes invisible
    NIXOS_OZONE_WL = "1"; # Hint electron apps to use wayland
    SSH_ASKPASS = ""; # disable ask pass UI
    SSL_CERT_FILE = /etc/ssl/certs/ca-bundle.crt;

    WLAN_IFACE = "wlp0s20f3";
  };

  sound.enable = true;
  sound.mediaKeys.enable = true;

  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
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


  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.tiso = {
    isNormalUser = true;
    description = "Agung Baptiso Sorlawan";
    extraGroups = [ "networkmanager" "wheel" "audio" "video" ];
    packages = [ ];
    shell = pkgs.fish;
  };
  programs.fish.enable = true;


  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  # wayland
  environment.systemPackages = with pkgs; [
    # @terminal
    alacritty
    wezterm
    starship

    # @desktop helper
    dunst
    libinput
    libnotify
    picom
    polybar
    polybar-pulseaudio-control
    rofi
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
    maim # screenshot
    flameshot
    gnome.adwaita-icon-theme # for xournalapp

    # @terminal apps
    bat
    delta
    difftastic
    dust
    eza
    fd
    jq
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
    mediainfo
    pkgs-unstable.neovim
    vim
    helix
    killall
    unrar
    yazi
    yt-dlp
    zoxide
    nethogs
    brightnessctl
    unzip
    p7zip
    zip
    openssl
    jless

    # @dev
    # devenv
    man-pages
    man-pages-posix
    tldr
    gcc
    gnumake
    cmake
    gdb
    valgrind
    pkg-config
    git
    jujutsu
    # rye
    python312
    poetry
    ruff
    ruff-lsp
    pyright
    virtualenv
    black
    isort
    go
    nodejs_22
    docker
    kubectl
    k9s
    rustup
    sccache
    leptosfmt
    pkgs-unstable.zig
    pkgs-unstable.zls
    pkgs-unstable.beam.packages.erlang_27.elixir_1_17
    pkgs-unstable.elixir-ls
    livebook
    stylua
    lua-language-server
    guile
    marksman
    inlyne # markdown previewer
    clang
    clang-tools
    gopls
    golines
    gofumpt
    gotools
    ghc
    cabal-install
    haskell-language-server
    prettierd
    nil
    nixpkgs-fmt
    biome
    redis
    trashy
    trunk
    cocogitto
    mold # faster linker
    postgresql
    pdftk # pdf uncompress, remove watermark
    qpdf # pdf manipulation, e.g: extract specific pages
    poppler_utils # pdftotext
    xsv
    jupyter-all
    ghostscript
    google-cloud-sdk
    sqlite
    litecli
    openconnect
    neofetch
    rsync
    inotify-tools # for elixir
    texliveSmall


    # @media
    mpv
    exiftool
    feh
    ffmpeg-full

    ffmpegthumbnailer
    pavucontrol
    pulseaudio
    ripgrep
    poppler
    imagemagick

    # @desktop app
    neovide
    evince
    yacreader
    foliate # epub reader
    gnome.nautilus
    pkgs-unstable.google-chrome
    pkgs-unstable.brave
    libreoffice
    postman
    firefox
    obsidian
    zoom-us
    xournalpp # signature pdf
    # pkgs-unstable.zed-editor
    transmission-gtk

    # @hardware
    glxinfo
    intel-gpu-tools
    mesa-demos

    # @fonts
    noto-fonts
    (pkgs.nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
    material-icons


    (callPackage ./../../pkgs/toptracker.nix { })
  ];

  virtualisation.docker.enable = true;
  # use docker without Root access (Rootless docker)
  virtualisation.docker.rootless = {
    enable = false;
    setSocketVariable = true;
  };


  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };
  programs.ssh.askPassword = "";

  # List services that you want to enable:
  services.locate.enable = true;
  services.locate.package = pkgs.mlocate;
  services.locate.localuser = null; # silences warning about running updatedb as root

  services.gvfs.enable = true;
  services.udisks2.enable = true;


  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = [ ];

  xdg.mime.enable = true;
  xdg.mime.defaultApplications = {
    "application/pdf" = "org.gnome.Evince.desktop";
    "image/png" = "feh.desktop";
    "audio/flac" = "mpv.desktop";
    "audio/mp3" = "mpv.desktop";
    "text/plain" = "neovide.desktop";
    "text/html" = "google-chrome.desktop";
    "application/json" = "neovide.desktop";
  };

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  system.stateVersion = "23.11"; # Did you read the comment?

}
