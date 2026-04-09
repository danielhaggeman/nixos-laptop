{ config, lib, pkgs, inputs, system, ... }:

{
  nixpkgs.config.allowUnfree = true;

  imports = [
    ./hardware-configuration.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.initrd.kernelModules = [ "nvidia" "nvidia_modeset" "nvidia_uvm" "nvidia_drm" ];
  boot.kernelParams = [ "nvidia-drm.modeset=1" "quiet" "loglevel=3" ];
  boot.blacklistedKernelModules = [ "nouveau" ];

  networking.hostName = "nix";
  networking.networkmanager.enable = true;

  time.timeZone = "Europe/Amsterdam";

  services.udisks2.enable = true;

  services.udev.extraRules = ''
    SUBSYSTEM=="hidraw", ATTRS{idVendor}=="3633", MODE="0666"
    SUBSYSTEM=="hidraw", ATTRS{idVendor}=="34d3", ATTRS{idProduct}=="1100", MODE="0666"
  '';

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    syntaxHighlighting.enable = false;
    autosuggestions.enable = false;
  };
  users.defaultUserShell = pkgs.zsh;

  services.xserver.enable = true;
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    modesetting.enable = true;
    open = true;
    nvidiaSettings = true;
    powerManagement.enable = true;

    prime = {
      offload = {
        enable = true;
        enableOffloadCmd = true;
      };
      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";
    };
  };

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  systemd.services.display-manager.after = lib.mkForce [
    "systemd-udev-settle.service"
    "dev-dri-card0.device"
    "dev-dri-card1.device"
    "multi-user.target"
  ];
  systemd.services.display-manager.wants = lib.mkForce [
    "systemd-udev-settle.service"
    "dev-dri-card0.device"
    "dev-dri-card1.device"
  ];

  programs.steam = {
    enable = true;
    gamescopeSession.enable = true;
  };
  programs.gamemode.enable = true;

  services.pulseaudio.enable = true;
  services.pipewire.enable = false;
  services.pipewire.pulse.enable = false;
  services.pipewire.alsa.enable = false;

  security.polkit.enable = true;
  security.sudo.wheelNeedsPassword = false;

  users.users.daniel = {
    isNormalUser = true;
    shell = pkgs.zsh;
    extraGroups = [ "wheel" "networkmanager" "video" ];
  };

  programs.firefox.enable = true;

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  services.desktopManager.plasma6.enable = true;

  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
  };

  environment.systemPackages = with pkgs; [
    kitty
    waybar
    hyprpaper
    wget
    mesa-demos
    unzip
    sudo
    wpsoffice
    swappy
    brightnessctl
    slurp
    grim
    remmina
    hyprlock
    tailscale
    yazi
    xfce.thunar
    xfce.thunar-volman
    pulseaudio
    wl-clipboard
    cabextract
    zsh
    zsh-autosuggestions
    zsh-syntax-highlighting
    deepcool-digital-linux
    ethtool
    fzf
    networkmanager
    neovim
    ripgrep
    (python3.withPackages (ps: with ps; [ pygobject3 ]))
    playerctl
    xfce.xfconf
    moonlight-qt
    sunshine
    fira
    font-awesome
    roboto
    liberation_ttf
    noto-fonts
    noto-fonts-color-emoji
    nnn
    qt6.qtbase
    qt6.qtsvg
    qt6.qtvirtualkeyboard
    qt6.qtmultimedia
    wireplumber
    alsa-utils
    hypridle
    btop
    networkmanagerapplet
    arc-theme
    papirus-icon-theme
    adwaita-icon-theme
    lxappearance
    qdirstat
  ];

  services.flatpak.enable = true;

  environment.variables = {
    XCURSOR_THEME = "Bibata-Modern-Classic";
    XCURSOR_SIZE = "24";
    GTK_THEME = "Arc-Dark";
    GTK_ICON_THEME = "Papirus-Dark";
    NIXOS_OZONE_WL = "1";
  };

  hardware.openrazer = {
    enable = true;
    users = [ "daniel" ];
  };

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

  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
  };

  system.stateVersion = "25.11";
}