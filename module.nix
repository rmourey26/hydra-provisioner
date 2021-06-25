{ config, lib, pkgs, ... }:

let
  cfg = config.services.hydra.provisioner;
  inherit (config.users.users.hydra-provisioner) home;

in

{
  options.services.hydra.provisioner = with lib; with types; {
    enable = mkEnableOption "Hydra Provisioner";

    useFlakeOverlay = mkOption {
      type = bool;
      default = true;
      description = ''
        when `true`, the flake's overlay will be applied to `nixpkgs.overlays`
        and the default package would be `pkgs.hydra-provisioner`.
        when `false`, the package would default to the flake's
        `packages.x86_64-linux.hydra-provisioner` instead.
      '';
    };

    package = mkOption {
      type = package;
      default = pkgs.hydra-provisioner;
      description = "Hydra provisioner package to use";
    };

    config = mkOption {
      type = submodule (import ./config-type.nix);
      description = ''
        Hydra Provisioner configuration
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    users.users.hydra-provisioner = {
      description = "Hydra Provisioner";
      group = "hydra";
      home = "/var/lib/hydra-provisioner";
      useDefaultShell = true;
      createHome = true;
      isSystemUser = true;
    };

    system.activationScripts.hydra-provisioner = lib.stringAfter [ "users" ]
    ''
      mkdir -m 0755 -p /var/lib/hydra/provisioner
      mkdir -m 0700 -p ${home}
      chown -R hydra-provisioner.hydra ${home} /var/lib/hydra/provisioner
    '';

    # FIXME: restrict PostgreSQL access.
    services.postgresql.identMap = ''
      hydra-users hydra-provisioner hydra
    '';

    services.hydra.buildMachinesFiles = [
      "/var/lib/hydra/provisioner/machines"
    ];

    systemd.services.hydra-provisioner = {
      wantedBy = [ "hydra-queue-runner.service" ];
      after    = [ "hydra-queue-runner.service" ];

      script = ''
          source /etc/profile
          while true; do
            timeout 3600 ${cfg.package}/bin/hydra-provisioner ${pkgs.writeText "conf.nix" ''
              with builtins;
              fromJSON (readFile ${pkgs.writeText "conf.json" (builtins.toJSON cfg.config)})
            ''}
            sleep 300
          done
      '';

      serviceConfig = {
        User = "hydra-provisioner";
        Restart = "always";
        RestartSec = 60;
      };
    };

    nix.nixPath = [ "${cfg.package}/share/nix" ];
  };
}
