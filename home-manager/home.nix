{ pkgs
, nixpkgs-unstable
, inputs
, ...
}:

let
  pkgs-unstable = nixpkgs-unstable;
  system = pkgs.stdenv.hostPlatform.system;
  hyprPkgs = inputs.hyprland.packages.${system};
  hyprlandGuiUtilsPkgs = inputs.hyprland_guiutils.packages.${system};
  nixGLIntel = inputs.nixgl.packages.${system}.nixGLIntel;
  nixGLWrapped = pkg: binary: pkgs.symlinkJoin {
    name = "${binary}-nixgl-wrapped";
    paths = [ pkg ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      rm -f $out/bin/${binary}
      makeWrapper ${nixGLIntel}/bin/nixGLIntel $out/bin/${binary} \
        --add-flags ${pkg}/bin/${binary}
    '';
  };
  kittyPatched = pkgs.kitty.overrideAttrs (oldAttrs: {
    postPatch = (oldAttrs.postPatch or "") + ''
      python3 - <<'PY'
      from pathlib import Path

      path = Path("kitty/fonts/fontconfig.py")
      text = path.read_text()
      old = """def is_monospace(descriptor: FontConfigPattern) -> bool:
          return descriptor['spacing'] in ('MONO', 'DUAL')
      """
      new = """def is_monospace(descriptor: FontConfigPattern) -> bool:
          if descriptor['spacing'] in ('MONO', 'DUAL'):
              return True
          return descriptor.get('postscript_name') in {
              'BerkeleyMono-Bold',
              'BerkeleyMono-Oblique',
              'BerkeleyMono-BoldOblique',
          }
      """
      if new not in text:
          if old not in text:
              raise SystemExit("kitty fontconfig.py monospace marker not found")
          text = text.replace(old, new, 1)
          path.write_text(text)
      PY
    '';
  });
  kittyWrapped = pkgs.writeShellScriptBin "kitty" ''
    exec ${nixGLIntel}/bin/nixGLIntel ${kittyPatched}/bin/kitty "$@"
  '';
  neovimPython = pkgs.python3.withPackages (ps: with ps; [ pynvim ]);

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
  nixpkgs.overlays = [ inputs.emacs-overlay.overlays.default ];

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
        # (callPackage ./ghostty { inherit inputs; })
        xterm
        nushell
        fish
      ];

      # Desktop session utilities and applets
      desktopEnvironment = [
        wl-color-picker
        mako
        zotero
        grim
        slurp
        swappy
        kittyWrapped
        wl-clipboard
        dunst
        socat
        (nixGLWrapped quickshell "quickshell")
        waybar
        wf-recorder
        rofi
        hyprlandGuiUtilsPkgs.hyprland-guiutils
        hyprPkgs.hyprland
        hyprPkgs.xdg-desktop-portal-hyprland
        pkgs-unstable.hyprpaper
        hyprsunset
        xdg-desktop-portal
        xdg-desktop-portal-gtk
        libinput
        libnotify
        (callPackage ./picom { })
        cliphist
        xdotool
        xclip
        xdg-user-dirs
        xbacklight
        xkill
        xdpyinfo
        xwininfo
        xmodmap
        networkmanagerapplet
        sxhkd
        copyq
        redshift
        maim
        (flameshot.override { enableWlrSupport = true; })
        playerctl
        adwaita-icon-theme
        file-roller
        eww
        rofi
        wl-clipboard
        wofi
        antigravity-fhs
        # inputs.antigravity-nix.packages.x86_64-linux.default
        # mesa
        nixGLIntel
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
        diff-so-fancy
        sxcs # color picker
        dust
        eza
        fd
        jq
        fx
        ripgrep
        lazygit
        pkgs-unstable.jujutsu
        fzf
        btop
        tmux
        wget
        atool
        curl
        file
        pkgs.emacs-unstable-pgtk
        vim-full
        killall
        pkgs-unstable.yt-dlp
        zoxide
        nethogs
        iw
        acpi
        brightnessctl
        unzip
        p7zip
        zip
        ouch
        openssl
        jless
        rlwrap
        slides
        navi
        tokei
        xan
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
        husky
        gitFull
        git-lfs
        protobuf
        lldb
        typst
        ast-grep
        pkgs-unstable.devenv
      ];

      # Python, Ruby, and related ecosystem tools
      dynamicLanguages = [
        ruff
        pyright
        basedpyright
        virtualenv
        black
        isort
        pre-commit
        legacySonarLint
        poetry
        poetryPlugins.poetry-plugin-shell
        ruby
      ];

      # Compilers, language servers, and formatters
      languageTooling = [
        gf
        go
        nodejs_22
        typescript-language-server
        oxlint
        bun
        # rustup
        # sccache
        # leptosfmt
        zig
        # zls
        # livebook
        odin
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
        process-compose
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
        fastfetch
        rsync
        inotify-tools
        # php
        # php82Packages.composer
        jmtpfs
        ngrok
      ];

      # Audio, video, and imaging utilities
      mediaTools = [
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
        kubectl
        # mpv
        # wf-recorder
      ];

      # Graphical applications
      guiApplications = [
        (nixGLWrapped neovide "neovide")
        (nixGLWrapped evince "evince")
        (nixGLWrapped sioyek "sioyek")
        nautilus
        pcmanfm
        (nixGLWrapped pkgs-unstable.xournalpp "xournalpp")
        (nixGLWrapped telegram-desktop "telegram-desktop")
        (nixGLWrapped inlyne "inlyne")
        transmission_4-gtk
      ];

      # Hardware diagnostics and graphics
      hardwareDiagnostics = [
        # mesa-demos
      ];

      # Font families sourced from nixpkgs-unstable
      fontPackages = [
        pkgs.corefonts
        nixpkgs-unstable.noto-fonts-color-emoji
        nixpkgs-unstable.noto-fonts-cjk-sans
        nixpkgs-unstable.source-code-pro
        nixpkgs-unstable.noto-fonts-cjk-serif
        nixpkgs-unstable.material-icons
        nixpkgs-unstable.symbola
        nixpkgs-unstable.nerd-fonts.symbols-only
        nixpkgs-unstable.nerd-fonts.jetbrains-mono
        nixpkgs-unstable.nerd-fonts.blex-mono
        nixpkgs-unstable.cascadia-code
        nixpkgs-unstable.fira-code
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
    "text/plain" = [ "nvim.desktop" ];
    "x-scheme-handler/zoommtg" = [ "zoomus-wrapped.desktop" ];
    "x-scheme-handler/zoomphonecall" = [ "zoomus-wrapped.desktop" ];
  };

  xdg.portal = {
    enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-gtk
      hyprPkgs.xdg-desktop-portal-hyprland
    ];
    config = {
      common.default = [ "hyprland" "gtk" ];
      hyprland.default = [ "hyprland" "gtk" ];
    };
  };

  fonts.fontconfig.enable = true;

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
    NVIM_PYTHON3_HOST_PROG = "${neovimPython}/bin/python3";
    NIXOS_OZONE_WL = "1";
    WLAN_IFACE = "wlp0s20f3";
    SXHKD_SHELL = "/bin/sh";
    PASSLOCK_FILE = "/home/agung-b-sorlawan/.rice/passlock.enc";
    # GBM_BACKENDS_PATH = "${pkgs.mesa}/lib/gbm";
    # LIBGL_DRIVERS_PATH = "${pkgs.mesa}/lib/dri";
    # __EGL_VENDOR_LIBRARY_DIRS = "${pkgs.mesa}/share/glvnd/egl_vendor.d";
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
  #  /etc/profiles/per-user/agung-b-sorlawan/etc/profile.d/hm-session-vars.sh

  home.file = {
    ".config/environment.d/90-rice-session.conf".text = ''
      PATH=$HOME/.scripts:$HOME/.local/bin:$HOME/.nix-profile/bin:/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin
      XDG_DATA_DIRS=$HOME/.nix-profile/share:/nix/var/nix/profiles/default/share:/usr/local/share:/usr/share
      LANG=en_US.UTF-8
      LC_ALL=en_US.UTF-8
      LC_CTYPE=en_US.UTF-8
    '';

  };

  # Override system portal services to use nix versions (system v1.18 can't
  # discover nix-installed portal backends; nix v1.20 can).
  systemd.user.services = {
    xdg-desktop-portal = {
      Unit = {
        Description = "Portal service";
        PartOf = [ "graphical-session.target" ];
      };
      Service = {
        Type = "dbus";
        BusName = "org.freedesktop.portal.Desktop";
        ExecStart = "${pkgs.xdg-desktop-portal}/libexec/xdg-desktop-portal";
        Slice = "session.slice";
      };
    };
    xdg-desktop-portal-gtk = {
      Unit.Description = "Portal service (GTK/GNOME implementation)";
      Service = {
        Type = "dbus";
        BusName = "org.freedesktop.impl.portal.desktop.gtk";
        ExecStart = "${pkgs.xdg-desktop-portal-gtk}/libexec/xdg-desktop-portal-gtk";
      };
    };
    xdg-desktop-portal-hyprland = {
      Unit.Description = "Portal service (Hyprland implementation)";
      Service = {
        Type = "dbus";
        BusName = "org.freedesktop.impl.portal.desktop.hyprland";
        ExecStart = "${hyprPkgs.xdg-desktop-portal-hyprland}/libexec/xdg-desktop-portal-hyprland";
      };
    };

    quickshell = {
      Unit = {
        Description = "Quickshell bar";
        PartOf = [ "graphical-session.target" ];
        After = [ "graphical-session-pre.target" ];
      };
      Service = {
        ExecStart = "${nixGLIntel}/bin/nixGLIntel ${pkgs.quickshell}/bin/qs -p %h/.config/quickshell --no-duplicate";
        Restart = "on-failure";
        RestartSec = 2;
      };
      Install.WantedBy = [ "graphical-session.target" ];
    };
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
