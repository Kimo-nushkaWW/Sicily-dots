{
  description = "Sicily-dots — NixOS + Hyprland + k4 island";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Quickshell — the QML runtime that powers k4.
    # Exposes an overlay with pkgs.quickshell.
    quickshell = {
      url = "git+https://git.outfoxxed.me/outfoxxed/quickshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, quickshell, ... }: let
    system = "x86_64-linux";

    pkgs = import nixpkgs {
      inherit system;
      overlays = [ quickshell.overlays.default ];
      config.allowUnfree = true;
    };
  in {
    nixosConfigurations.sicily = nixpkgs.lib.nixosSystem {
      inherit system;
      modules = [
        ./hosts/sicily/configuration.nix
        home-manager.nixosModules.home-manager
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            users.kimo = import ./home;
            extraSpecialArgs = { inherit quickshell; };
          };
        }
      ];
      specialArgs = { inherit pkgs; };
    };
  };
}
