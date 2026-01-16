{ pkgs
, nixpkgs-unstable
, inputs
, ...
}:

let
  pkgs-unstable = nixpkgs-unstable;

  # SonarLint was first added on 2025-05-21 using nixpkgs rev 292fa7d4.
  # Pin to that revision to avoid current mvnHash mismatch from republished artifacts.
  legacyPkgs =
    import
      (builtins.fetchTarball {
        url = "https://github.com/NixOS/nixpkgs/archive/292fa7d4f6519c074f0a50394dbbe69859bb6043.tar.gz";
        sha256 = "sha256-GaOZntlJ6gPPbbkTLjbd8BMWaDYafhuuYRNrxCGnPJw=";
      })
      {
        system = "x86_64-linux";
        config.allowUnfree = true;
      };

  legacySonarLint = legacyPkgs.sonarlint-ls;
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
  home.packages =
    with pkgs;
    let
      # Shell tooling and terminal emulators
      terminalAndShells = [
        starship
        atuin
        (callPackage ./alacritty { })
        (callPackage ./ghostty {
          inherit inputs;
          nixpkgs-unstable = nixpkgs-unstable;
        })
        # (callPackage ./zed-editor { inherit inputs; nixpkgs-unstable = nixpkgs-unstable; })
        # (callPackage ./zoom-us { nixpkgs-unstable = nixpkgs-unstable; })
        nushell
        fish
      ];

      # Desktop session utilities and applets
      desktopEnvironment = [
        dunst
        libinput
        libnotify
        (callPackage ./picom { })
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
        antigravity-fhs
        # inputs.antigravity-nix.packages.x86_64-linux.default
        mesa
      ];

      # Productivity, syncing, and day-to-day utilities
      productivityAndOps = [
        util-linux
        awscli2
        postman
        rclone
        foliate
      ];

      # General CLI helpers and editors
      cliUtilities = [
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
        btop
        tmux
        zellij
        wget
        atool
        curl
        file
        pkgs-unstable.neovim
        vim-full
        sbcl
        killall
        yazi
        pkgs-unstable.yt-dlp
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
        carapace # completion helpers
        navi
        # pkgs-unstable.ducker
        # inputs.opencode.packages.x86_64-linux.default
        tokei
      ];

      # Core development toolchain and documentation
      devTooling = [
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
        ast-grep
      ];

      # Python, Ruby, and related ecosystem tools
      dynamicLanguages = [
        ruff
        pyright
        basedpyright
        virtualenv
        black
        isort
        python312Packages.pytest
        python312Packages.coverage
        pre-commit
        legacySonarLint
        poetry
        poetryPlugins.poetry-plugin-shell
        ruby
      ];

      # Compilers, language servers, and formatters
      languageTooling = [
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
        # racket
        marksman
        # clang
        # clang-tools
        # gopls
        # golines
        # gofumpt
        # gotools
        # ghc
        # cabal-install
        # haskellPackages.cabal-fmt
        # haskell-language-server
        # stack
        prettierd
        nil
        nixpkgs-fmt
        pkgs-unstable.biome
        wabt

        pnpm
      ];

      # Databases and developer services
      dataServices = [
        redis
        postgresql
        sqlite
        litecli
        docker
      ];

      # Document, PDF, and scientific tooling
      documentTools = [
        pdftk
        # poppler_utils
        jupyter-all
        ghostscript
        wkhtmltopdf
        # mermaid-cli
      ];

      # System helpers and connectivity tools
      systemUtilities = [
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
        ngrok
      ];

      # Audio, video, and imaging utilities
      mediaTools = [
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
      ];

      # Graphical applications
      guiApplications = [
        neovide
        evince
        sioyek
        nautilus
        pcmanfm
        brave
        pkgs-unstable.xournalpp
        telegram-desktop
        inlyne
        transmission_4-gtk
      ];

      # Hardware diagnostics and graphics
      hardwareDiagnostics = [
        mesa-demos
      ];

      # Font families sourced from nixpkgs-unstable
      fontPackages = [
        nixpkgs-unstable.noto-fonts-color-emoji
        nixpkgs-unstable.noto-fonts-cjk-sans
        nixpkgs-unstable.noto-fonts-cjk-serif
        nixpkgs-unstable.material-icons
        nixpkgs-unstable.symbola
        nixpkgs-unstable.nerd-fonts.jetbrains-mono
        nixpkgs-unstable.nerd-fonts.blex-mono
        nixpkgs-unstable.cascadia-code
        nixpkgs-unstable.fira-code
        nixpkgs-unstable.hack-font
        nixpkgs-unstable.source-code-pro
        nixpkgs-unstable.ibm-plex
        nixpkgs-unstable.inconsolata
        nixpkgs-unstable.liberation_ttf
      ];
    in
    terminalAndShells
    ++ desktopEnvironment
    ++ productivityAndOps
    ++ cliUtilities
    ++ devTooling
    ++ dynamicLanguages
    ++ languageTooling
    ++ dataServices
    ++ documentTools
    ++ systemUtilities
    ++ mediaTools
    ++ guiApplications
    ++ hardwareDiagnostics
    ++ fontPackages;

  # Register Zoom as the handler for zoommtg:// links so xdg-open and
  # browsers dispatch meeting URLs to it.
  xdg.mimeApps.enable = true;
  xdg.mimeApps.defaultApplications = {
    "x-scheme-handler/zoommtg" = [ "zoomus-wrapped.desktop" ];
    "x-scheme-handler/zoomphonecall" = [ "zoomus-wrapped.desktop" ];
  };

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
    PASSLOCK_FILE = "/home/agung-b-sorlawan/.rice/passlock.enc";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
