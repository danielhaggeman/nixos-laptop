{
  description = "My full NixOS system with Home-Manager, Zen Browser, Star Citizen support, and SilentSDDM";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-citizen.url = "github:LovingMelody/nix-citizen";
    nix-gaming.url = "github:fufexan/nix-gaming";
    nix-citizen.inputs.nix-gaming.follows = "nix-gaming";

    silentSDDM = {
      url = "github:uiriansan/SilentSDDM";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nixpkgs, home-manager, zen-browser, nix-citizen, silentSDDM, ... }:
  let
    system = "x86_64-linux";
    lib = nixpkgs.lib;
  in {
    nixosConfigurations.nix = nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = { inherit inputs system; };
      modules = [
        ./configuration.nix
        ./hardware-configuration.nix

        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.daniel = { pkgs, ... }: {
            home.stateVersion = "24.11";

            imports = [ zen-browser.homeModules.beta ];
            programs.zen-browser.enable = true;

            home.packages = with pkgs; [
              inputs.nix-citizen.packages.${system}.rsi-launcher
              fastfetch
              vscode
              discord
              rofi
              protonup-qt
              lutris
              bottles
              heroic
              spicetify-cli
              pavucontrol
              polychromatic
              openrazer-daemon
              fanctl
              lm_sensors
            ];
          };
        }

        nix-citizen.nixosModules.default

        silentSDDM.nixosModules.default
        {
          programs.silentSDDM.enable = true;
          programs.silentSDDM.theme = "default"; # rei, ken, silvia, everforest, default

          # Wayland SDDM must stay on — mkForce prevents other modules overriding it.
          # defaultSession is intentionally not set here; configuration.nix owns it.
          services.displayManager.sddm.wayland.enable = lib.mkForce true;
        }
      ];
    };
  };
}