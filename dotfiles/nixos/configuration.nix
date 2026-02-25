{ config, pkgs, lib, ... }:

{
  # Nixpkgs
  nixpkgs.config.allowUnfree = true;

  # System state version
  system.stateVersion = "25.11";

  # Hardware configuration
  imports = [ ./hardware-configuration.nix ];

  boot.kernelParams = [
    "snd_hda_intel.dmic_detect=0"
    "snd_hda_intel.model=dell-headset-multi"
  ];

  # Bootloader
  boot.loader.systemd-boot.enable = false;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.grub = {
    enable = true;
    efiSupport = true;
    device = "nodev";
    theme = "/etc/nixos/grub-themes/HyperFluent";
    useOSProber = true;
  };

  # Networking
  networking.hostName = "nix";
  networking.networkmanager.enable = true;

  # Timezone
  time.timeZone = "Europe/Amsterdam";

  # Users & shells
  users.defaultUserShell = pkgs.zsh;
  users.users.daniel = {
    isNormalUser = true;
    shell = pkgs.zsh;
    extraGroups = [ "wheel" "networkmanager" "video" "audio" ];
  };
  security.sudo.wheelNeedsPassword = false;

  # Services
  services.udisks2.enable = true;
  services.udev.extraRules = ''
    SUBSYSTEM=="hidraw", ATTRS{idVendor}=="3633", MODE="0666"
    SUBSYSTEM=="hidraw", ATTRS{idVendor}=="34d3", ATTRS{idProduct}=="1100", MODE="0666"
  '';
  services.tailscale.enable = true;
  services.flatpak.enable = true;
  security.polkit.enable = true;

  # Display & GUI
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;       # needed for X11 apps inside Wayland
  };

  services.displayManager.defaultSession = "hyprland";

  # Nvidia configuration
  hardware.nvidia = {
    open = true;                  # open-source Nvidia driver
    modesetting.enable = true;    # required for Wayland
    nvidiaSettings = true;        # GUI tool
  };

  # OpenGL support
  hardware.opengl.enable = true;  # provides mesa & drivers  

  # Sound
#  hardware.pulseaudio = {
 #   enable = true;
  #  support32Bit = true;
 # };
 # services.pipewire.enable = false;
  
   

hardware.pulseaudio.enable = false;

services.pipewire = {
  enable = true;
  alsa.enable = true;
  alsa.support32Bit = true;
  pulse.enable = true;   # provides PulseAudio compatibility
};


  # Kernel tuning
  boot.kernel.sysctl = {
    "vm.max_map_count" = 16777216;
    "fs.file-max" = 524288;
  };
  # Programs
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    syntaxHighlighting.enable = false;
    autosuggestions.enable = false;
  };
  programs.steam = {
    enable = true;
    gamescopeSession.enable = true;
  };
  programs.gamemode.enable = true;
  programs.firefox.enable = true;

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

  # Environment variables
  environment.variables = {
    XCURSOR_THEME = "Bibata-Modern-Classic";
    XCURSOR_SIZE = "24";
    PKG_CONFIG_PATH = "${pkgs.qt6.qtmultimedia}/lib/pkgconfig";
  };

  # System packages
  environment.systemPackages = with pkgs; [
    kitty
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
    wpsoffice
    swappy
    brightnessctl
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
  ];

  # OpenRazer
  hardware.openrazer = {
    enable = true;
    users = [ "daniel" ];
  };

  # Nix experimental features
  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
  };
}
