{
  description = "manssell's NixOS - ThinkPad T420 (i3 + startx)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko/latest";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, disko, ... }:
    let
      common = [
        ./hosts/t420
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.backupFileExtension = "backup";
          home-manager.users.manssell = import ./home;
        }
      ];
      mk = extra: nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = common ++ extra;
      };
    in {
      # system already installed: use hosts/t420/hardware-configuration.nix (copied from /etc/nixos)
      nixosConfigurations.t420 = mk [ ];
      # Fresh reinstall with disko (install.sh)
      nixosConfigurations.t420-install = mk [ disko.nixosModules.disko ./hosts/t420/disko.nix ];
    };
}
