# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:
let
  home-manager = builtins.fetchTarball https://github.com/nix-community/home-manager/archive/release-25.05.tar.gz;
in
{
  imports =
    [ # Include the results of the hardware scan.
      # <nixpkgs/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix>
      # <nixpkgs/nixos/modules/installer/cd-dvd/channel.nix>
      ./hardware-configuration.nix
      (import "${home-manager}/nixos")
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Use latest kernel.
  # boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Berlin";

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
    iosevka
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
      librewolf
      mako
      fuzzel
      rofi
    ];
    programs.bash.enable = true;
    programs.rofi.enable = true;
    programs.waybar.enable = true;
    services.mako.enable = true;
    programs.fuzzel = {
      enable = true;
      settings = {
        main = {
          terminal = "${pkgs.alacritty}/bin/alacritty";
        };
      };
    };

    programs.alacritty = {
      enable = true;
      settings = {
        font = {
          size = 12.0;
          normal.family = "Iosevka";
        };
      };
    };

    programs.librewolf = {
      enable = true;
      settings = {
        "webgl.disabled" = false;
        "privacy.resistFingerprinting" = false;
        "privacy.clearOnShutdown.history" = false;
        "privacy.clearOnShutdown.cookies" = false;
        "sidebar.position_start" = false;
        "sidebar.revamp" = true;
        "sidebar.verticalTabs" = true;
        "ui.systemUsesDarkTheme" = true;
      };
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

    # programs.neovim = {
    #   enable = true;
    #   package = pkgs.neovim;
    # };

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

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    git
    rocmPackages.clang
    gnumake
    automake
    autoconf
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

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  security.polkit.enable = true;
  security.pam.services.swaylock = {};
  security.rtkit.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;

  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver
      libvdpau-va-gl
    ];
  };
  environment.sessionVariables = { LIBVA_DRIVER_NAME = "iHD"; };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?
}
