# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:

{
  nixpkgs.config.allowUnfree = true;

  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Networking
  networking.hostName = "nix"; # Define your hostname.
  networking.networkmanager.enable = true;
  # networking.interfaces.eno1.ethtoolCommands = ''
  #   ethtool -s eno1 speed 1000 duplex full autoneg on
  # '';

  # Timezone
  time.timeZone = "Europe/Amsterdam";

  # Disk / device services
  services.udisks2.enable = true;

  # Udev rules
  services.udev.extraRules = ''
    SUBSYSTEM=="hidraw", ATTRS{idVendor}=="3633", MODE="0666"
    SUBSYSTEM=="hidraw", ATTRS{idVendor}=="34d3", ATTRS{idProduct}=="1100", MODE="0666"
  '';

  # Shell (ZSH)
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    syntaxHighlighting.enable = false; # handled manually in .zshrc
    autosuggestions.enable = false;    # handled manually in .zshrc
  };
  users.defaultUserShell = pkgs.zsh;

  # GPU (AMD)
  services.xserver.videoDrivers = [ "amdgpu" ];

  hardware.graphics = {
    enable = true;
    enable32Bit = true;

    extraPackages = with pkgs; [
      mesa
      vulkan-loader
    ];

    extraPackages32 = with pkgs; [
      driversi686Linux.mesa
    ];
  };

  # Gaming
  programs.steam = {
    enable = true;
    gamescopeSession.enable = true;
  };

  programs.gamemode.enable = true;

  # Audio
  services.pulseaudio.enable = true;
  services.pipewire.enable = false;
  services.pipewire.pulse.enable = false;
  services.pipewire.alsa.enable = false;

  # Security
  security.polkit.enable = true;
  security.sudo.wheelNeedsPassword = false;

  # User
  users.users.daniel = {
    isNormalUser = true;
    shell = pkgs.zsh;
    extraGroups = [ "wheel" "networkmanager" "video" ];
  };

  # Browser
  programs.firefox.enable = true;

  # Hyprland
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  # Display manager (greetd)
  services.greetd = {
    enable = true;

    settings = {
      default_session = {
        command = "hyprland";
        user = "daniel";
      };
    };
  };

  # System packages
  environment.systemPackages = with pkgs; [
    kitty # Terminal
    waybar
    hyprpaper
    wget
    lxqt.lxqt-policykit
    git
    htop
    vulkan-tools
    mesa-demos
    unzip
    sudo
    swappy
    slurp
    grim
    yazi # Text FileManager
    xfce.thunar # GUI FileManager
    xfce.thunar-volman
    pulseaudio
    wl-clipboard
    zsh
    zsh-autosuggestions
    zsh-syntax-highlighting
    deepcool-digital-linux
    ethtool
    fzf
    cabextract
    unzip
    networkmanager
    neovim
    ripgrep
    fd
    nodejs
    gvfs
    pkg-config
    libvterm
    gcc
    gnumake
    cmake
    bibata-cursors
    gobject-introspection
    gtk3
    (python3.withPackages (ps: with ps; [ pygobject3 ]))
    playerctl
    xfce.xfconf
    arc-theme
    papirus-icon-theme
    adwaita-icon-theme
    lxappearance
    qdirstat
  ];

  # Flatpak
  services.flatpak.enable = true;

  # Cursor
  environment.variables = {
    XCURSOR_THEME = "Bibata-Modern-Classic";
    XCURSOR_SIZE = "24";
  };

  # Openrazer
  hardware.openrazer = {
    enable = true;
    users = [ "daniel" ]; # your username
  };

  # Fonts
  fonts = {
    fontconfig.enable = true;
    packages = with pkgs; [
      nerd-fonts.commit-mono
      nerd-fonts.fira-code
      nerd-fonts.symbols-only
      fira-sans
      roboto
      font-awesome
    ];
  };

environment.variables = {
  GTK_THEME = "Arc-Dark";
  GTK_ICON_THEME = "Papirus-Dark";
};
 

  # Nix settings
  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
  };

  # System version
  system.stateVersion = "25.11"; # Did you read the comment?
}
