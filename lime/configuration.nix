{ config, pkgs, ... }:

{
  imports =
    [
      /etc/nixos/hardware-configuration.nix
    ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.initrd.luks.devices."luks-10ef9b73-65b2-4661-ba38-547d6b936ed0".device = "/dev/disk/by-uuid/10ef9b73-65b2-4661-ba38-547d6b936ed0";

  networking.hostName = "lime";
  networking.networkmanager.enable = true;

  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;

  # connecting to external display switched audio and it was not working
  # also switching from speaker to headphones was bit flaky
  services.pipewire.wireplumber.extraConfig."51-laptop-audio" = {
    "wireplumber.settings"."node.restore-default-targets" = false;
    "monitor.alsa.rules" = [{
      matches = [{ "device.name" = "alsa_card.pci-0000_00_1f.3-platform-skl_hda_dsp_generic"; }];
      actions.update-props."device.profile" = "HiFi (HDMI1, HDMI2, HDMI3, Mic1, Mic2, Speaker)";
    }];
  };
  systemd.user.services.wireplumber.serviceConfig.ExecStartPost =
    toString (pkgs.writeShellScript "unmute-headphone-pin" ''
      # UCM mutes the headphone pin while wireplumber sets up the card
      for _ in $(seq 20); do
        ${pkgs.wireplumber}/bin/wpctl status | grep -q "Controller Speaker" && break
        sleep 0.5
      done
      sleep 0.5
      ${pkgs.alsa-utils}/bin/amixer -q -c sofhdadsp sset Headphone 100% unmute
    '');

  time.timeZone = "Europe/London";

  i18n.defaultLocale = "en_GB.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_GB.UTF-8";
    LC_IDENTIFICATION = "en_GB.UTF-8";
    LC_MEASUREMENT = "en_GB.UTF-8";
    LC_MONETARY = "en_GB.UTF-8";
    LC_NAME = "en_GB.UTF-8";
    LC_NUMERIC = "en_GB.UTF-8";
    LC_PAPER = "en_GB.UTF-8";
    LC_TELEPHONE = "en_GB.UTF-8";
    LC_TIME = "en_GB.UTF-8";
  };

  services.xserver.xkb = {
    layout = "gb";
    variant = "";
  };

  console.keyMap = "uk";

  users.users."kurund" = {
    shell = pkgs.nushell;
    isNormalUser = true;
    description = "Kurund Jalmi";
    extraGroups = [ "networkmanager" "wheel" "docker" ];
    packages = with pkgs; [];
  };

  nixpkgs.config.allowUnfree = true;

  nix.settings.experimental-features = ["nix-command" "flakes"]; 

  environment.systemPackages = with pkgs; [
     vim
     neovim
     wget
     git
     jujutsu
     pass
     browserpass
     kitty
     ghostty
     btop
     bat
     noctalia
     google-chrome
     fuzzel
     tuigreet
     thunar
     thunar-volman
     thunar-archive-plugin
     tumbler
     obsidian
     tmux
     fastfetch
     docker
     nushell
     fish
     starship
     starship-jj
     gnupg
     gh
     stow
     herdr
     gcc
     delta
     ripgrep
     pnpm
     google-clasp
     mattermost-desktop
     spotify-player
     claude-code

     # neovim / mason: runtimes needed to install LSPs, linters and formatters
     nodejs
     python3
     unzip
     php
  ];

  virtualisation.docker.enable = true;

  programs.browserpass.enable = true;

  programs.lazygit.enable = true;

  programs.fish.enable = true;
  programs.nushell.enable = true;

  programs.nix-ld.enable = true;
  # extra libs for prebuilt mason binaries (marksman needs icu)
  programs.nix-ld.libraries = with pkgs; [ icu ];

  programs.niri.enable = true; 

  # PGP key configurtion
  programs.gnupg.agent = {
    enable = true;
    pinentryPackage = pkgs.pinentry-gnome3;
  };

  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --time --cmd niri-session";
        user = "greeter";
      };
    };
  };

   # enable automounting of external devices
   services.udisks2.enable = true;

  system.stateVersion = "26.05";

}
