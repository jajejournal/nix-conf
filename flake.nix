{
  description = "NixOS: i3 + home-manager + disko (config portable entre máquinas)";

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
    # Ajustes automáticos por modelo de portátil (t420, x220, etc.)
    nixos-hardware = {
      url = "github:NixOS/nixos-hardware/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # OpenCode V2 (rama dev = 2.x). DESACTIVADO por ahora: se descarga el repo
    # entero aunque el módulo no se use, lo que hace lento el instalar desde el
    # ISO. Descomenta estas líneas (y ./modules/opencode.nix más abajo) cuando
    # quieras usarlo.
    # opencode.url = "github:anomalyco/opencode/dev";
  };

  outputs = { self, nixpkgs, home-manager, disko, nixos-hardware, ... }@inputs:
    let
      # ⚠️  Cambia aquí tu usuario y cámbialo también en install.sh
      user = "manssell";

      mkHost = host: extraModules: nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs user; };
        modules = [
          ./modules/common.nix
          ./modules/desktop.nix
          # ./modules/opencode.nix   # <- descomenta para instalar OpenCode V2 (compila desde fuente)
          ./hosts/${host}
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.backupFileExtension = "backup";
            home-manager.extraSpecialArgs = { inherit inputs user; };
            home-manager.users.${user} = import ./home;
          }
        ] ++ extraModules;
      };
    in
    {
      # Sistema ya instalado (usa hosts/<host>/hardware-configuration.nix)
      nixosConfigurations.t420 = mkHost "t420" [ ];
      # Instalación limpia con disko (lo usa install.sh)
      nixosConfigurations.t420-install = mkHost "t420" [
        disko.nixosModules.disko
        ./hosts/t420/disko.nix
      ];

      # Para otra máquina: crea hosts/<nombre>/ y añade aquí:
      # nixosConfigurations.<nombre> = mkHost "<nombre>" [ ];
    };
}
