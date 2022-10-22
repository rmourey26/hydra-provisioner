{
  description = "Hydra Provisioner";

  inputs.utils.url = "github:rmourey26/flake-utils";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  outputs = { self, nixpkgs, utils, ... }:
  utils.lib.simpleFlake {
    inherit nixpkgs;
    systems = [ "x86_64-linux" ];

    overlay = final: prev: {
      hydra-provisioner = final.poetry2nix.mkPoetryApplication {
        meta.mainProgram = "hydra-provisioner";

        projectDir = ./.;

        postInstall = ''
          mkdir -p $out/share/nix/hydra-provisioner
          cp ${./nix/auto-shutdown.nix} $_/auto-shutdown.nix
        '';
      };
    };

    packages = { hydra-provisioner }: {
      defaultPackage = hydra-provisioner;
      inherit hydra-provisioner;
    };

    nixosModule = { lib, config, ... }: let
      cfg = config.services.hydra.provisioner;
    in {
      imports = [ ./module.nix ];

      config = with lib; {
        nixpkgs = mkIf cfg.useFlakeOverlay {
          overlays = [ self.overlay ];
        };

        services.hydra.provisioner = mkIf (!cfg.useFlakeOverlay) {
          package = self.defaultPackage.x86_64-linux;
        };
      };
    };
  };
}
