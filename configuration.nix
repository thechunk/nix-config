# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:
let
  home-manager = builtins.fetchTarball https://github.com/nix-community/home-manager/archive/release-25.05.tar.gz;
in
{
  imports =
    [ # Include the results of the hardware scan.
      # <nixpkgs/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix>
      # <nixpkgs/nixos/modules/installer/cd-dvd/channel.nix>
      "${builtins.fetchGit { url = "https://github.com/NixOS/nixos-hardware.git"; }}/lenovo/thinkpad/t14"
      "${builtins.fetchGit { url = "https://github.com/NixOS/nixos-hardware.git"; }}/common/gpu/intel/meteor-lake/"
      ./hardware-configuration.nix
      (import "${home-manager}/nixos")
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Use latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernel.sysctl."kernel/sysrq" = 1;

  networking.hostName = "russnix"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Berlin";

  console.font = "Lat2-Terminus16";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "de_DE.UTF-8";
    LC_IDENTIFICATION = "de_DE.UTF-8";
    LC_MEASUREMENT = "de_DE.UTF-8";
    LC_MONETARY = "de_DE.UTF-8";
    LC_NAME = "de_DE.UTF-8";
    LC_NUMERIC = "de_DE.UTF-8";
    LC_PAPER = "de_DE.UTF-8";
    LC_TELEPHONE = "de_DE.UTF-8";
    LC_TIME = "de_DE.UTF-8";
  };

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  fonts.packages = with pkgs; [
    inter
    nerd-fonts.iosevka
    font-awesome
  ];

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.russellc = {
    isNormalUser = true;
    description = "Russell";
    extraGroups = [ "networkmanager" "wheel" "video" ];
    packages = with pkgs; [];
  };

  home-manager.users.russellc = { pkgs, config, ... }: {
    home.packages = with pkgs; [
      alacritty
      mako
      fuzzel
      rofi
      ungoogled-chromium
    ];

    programs.bash.enable = true;
    programs.bash.initExtra = ''
      PS1="\[\033[1;32m\][\[\e]0;\u@\h: \w\a\]\u@\h:\w]\$\[\033[0m\] "
    '';
    programs.rofi.enable = true;
    programs.waybar.enable = true;

    services.mako = {
      enable = true;
      settings = {
        on-button-middle = "exec makoctl menu -n \"$id\" fuzzel -- -d -p 'Select action: '";
      };
    };
    services.network-manager-applet.enable = true;

    programs.fuzzel = {
      enable = true;
      settings = {
        main = {
          font = "Iosevka Nerd Font Mono:size=12";
          terminal = "${pkgs.alacritty}/bin/alacritty";
        };
      };
    };

    programs.alacritty = {
      enable = true;
      settings = {
        font = {
          size = 12.0;
          normal.family = "Iosevka Nerd Font Mono";
        };
      };
    };

    programs.librewolf = {
      enable = true;
      policies = {
        ExtensionSettings = {
          "{446900e4-71c2-419f-a6a7-df9c091e268b}" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/bitwarden-password-manager/latest.xpi";
            installation_mode = "force_installed";
            private_browsing = true;
          };
          "{d634138d-c276-4fc8-924b-40a0ea21d284}" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/1password-x-password-manager/latest.xpi";
            installation_mode = "force_installed";
            private_browsing = true;
            default_area = "navbar";
          };
        };
      };
      profiles.default = {
        name = "default";
        isDefault = true;
        settings = {
          "browser.aboutConfig.showWarning" = false;
          "browser.toolbars.bookmarks.visibility" = "newtab";
          "browser.compactmode.show" = true;
          "browser.startup.page" = 3;
          "browser.warnOnQuit" = false;
          "media.videocontrols.picture-in-picture.video-toggle.enabled" = false;
          "webgl.disabled" = false;
          "privacy.resistFingerprinting" = false;
          "privacy.clearOnShutdown.history" = false;
          "privacy.clearOnShutdown.cookies" = false;
          "privacy.clearOnShutdown.downloads" = false;
          "privacy.clearOnShutdown_v2.cache" = false;
          "privacy.clearOnShutdown_v2.cookiesAndStorage" = false;
          "privacy.clearOnShutdown_v2.browsingHistoryAndDownloads" = false;
          "sidebar.position_start" = false;
          "sidebar.revamp" = true;
          "sidebar.verticalTabs" = true;
          "ui.systemUsesDarkTheme" = true;
        };
        search = {
          force = true;
          default = "Kagi";
          engines = {
            "Kagi" = {
              urls = [
              {
                template = "https://kagi.com/search?";
                params = [
                {
                  name = "q";
                  value = "{searchTerms}";
                }
                ];
              }
              ];
            };
          };
        };
      };
    };

    programs.chromium = {
      package = pkgs.ungoogled-chromium;
      commandLineArgs = [
        "--enable-features=UseOzonePlatform"
        "--ozone-platform=wayland"
      ];
      extensions = [
        { id = "aeblfdkhhhdcdjpifhhbdiojplfjncoa"; }
      ];
    };

    programs.mise = {
      enable = true;
      globalConfig = {
        tools = {
          erlang = "28.0";
          elixir = "1.18.4-otp-28";
          go = "1.24.1";
          ruby = "3.4.4";
        };
      };
    };

    programs.swaylock = {
      enable = true;
      settings = {
        color = "000000";
        show-failed-attempts = true;
      };
    };

    services.swayidle = {
      enable = true;
      timeouts = [
        { timeout = 60 * 5; command = "${pkgs.swaylock}/bin/swaylock -fF"; }
      ];
    };

    services.trayscale.enable = true;

    # programs.neovim = {
    #   enable = true;
    #   package = pkgs.neovim;
    # };

    gtk = {
      enable = true;
      font = {
        name = "Inter Display";
        size = 11;
      };
      iconTheme = {
        package = pkgs.pantheon.elementary-icon-theme;
        name = "elementary";
      };
      theme = lib.mkForce {
        package = pkgs.lounge-gtk-theme;
        name = "Lounge-night-compact";
      };
    };

    home.pointerCursor.package = pkgs.pantheon.elementary-icon-theme;
    home.pointerCursor.name = "elementary";
    home.pointerCursor.gtk.enable = true;

    wayland.windowManager.sway = {
      enable = true;
      config = {
        terminal = "alacritty";
        menu = "rofi -terminal alacritty -show combi -combi-modes drun#run -modes combi";
        bars = [{ command = "waybar"; }];
      };
    };

    home.file = {
      ".config/niri" = {
        source = config.lib.file.mkOutOfStoreSymlink ./dotfiles/niri;
        recursive = true;
        force = true;
      };
      ".config/nvim" = {
        source = config.lib.file.mkOutOfStoreSymlink ./dotfiles/nvim;
        recursive = true;
        force = true;
      };
    };

    home.stateVersion = "25.05";
  };

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    git
    jetbrains.ruby-mine
    rocmPackages.clang
    gnumake
    automake
    autoconf
    xarchiver
    xdg-utils
  #  wget
  ];

  environment.etc."greetd/environments".text = ''
    niri-session
    sway
  '';

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  programs.neovim = {
    enable = true;
    defaultEditor = true;
  };
  programs.niri.enable = true;
  programs.sway.enable = true;

  programs.thunar.enable = true;
  programs.thunar.plugins = with pkgs.xfce; [
    thunar-archive-plugin
    thunar-volman
  ];
  programs.xfconf.enable = true;
  programs.dconf.enable = true;
  services.gvfs.enable = true;
  services.tumbler.enable = true;

  # List services that you want to enable:
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --cmd niri-session";
        user = "greeter";
      };
    };
  };

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  services.blueman.enable = true;
  # services.tzupdate.enable = true;
  services.tailscale = {
    enable = true;
    useRoutingFeatures = "client";
  };

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  security.polkit.enable = true;
  security.pam.services.swaylock = {};
  security.pam.services.passwd.rules.password.pwquality = {
    control = "required";
    modulePath = "${pkgs.libpwquality.lib}/lib/security/pam_pwquality.so";
    order = config.security.pam.services.passwd.rules.password.unix.order - 10;
    settings = {
      minlen = 8;
    };
  };
  security.rtkit.enable = true;

  services.acpid.enable = true;
  services.fwupd.enable = true;
  services.logind = {
    lidSwitch = "suspend-then-hibernate";
    lidSwitchExternalPower = "ignore";
    extraConfig = "HandlePowerKey=hibernate";
  };
  systemd.sleep.extraConfig = ''
    HibernateDelaySec=1h
  '';

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  powerManagement.enable = true;

  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;

  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "iHD";
    NIXOS_OZONE_WL = "1";
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?
}
