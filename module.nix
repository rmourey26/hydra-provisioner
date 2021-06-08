{ config, lib, pkgs, ... }:

let
  cfg = config.services.hydra.provisioner;

in

{
  options.services.hydra.provisioner = {
    enable = lib.mkEnableOption "Hydra Provisioner";

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.hydra-provisioner;
      description = "Hydra provisioner package to use";
    };
  };

  config = lib.mkIf cfg.enable {
    users.extraUsers.hydra-provisioner =
      { description = "Hydra provisioner";
      group = "hydra";
      home = "/var/lib/hydra-provisioner";
      useDefaultShell = true;
      createHome = true;
    };

    system.activationScripts.hydra-provisioner = lib.stringAfter [ "users" ]
    ''
      mkdir -m 0755 -p /var/lib/hydra/provisioner
      mkdir -m 0700 -p /var/lib/hydra-provisioner
      chown hydra-provisioner.hydra /var/lib/hydra-provisioner /var/lib/hydra/provisioner
    '';

    environment.systemPackages = with pkgs;
    [
      hydra-provisioner
      nixops
      awscli
    ];

  # FIXME: restrict PostgreSQL access.
  services.postgresql.identMap =
    ''
      hydra-users hydra-provisioner hydra
    '';

    services.hydra.buildMachinesFiles =
      [ "/etc/nix/machines" "/var/lib/hydra/provisioner/machines" ];

      systemd.services.hydra-provisioner =
        { script =
          ''
          source /etc/profile
          while true; do
          timeout 3600 ${cfg.package}/bin/hydra-provisioner /var/lib/hydra-provisioner/nixos-org-configurations/hydra-provisioner/conf.nix
          sleep 300
          done
          '';
          serviceConfig.User = "hydra-provisioner";
          serviceConfig.Restart = "always";
          serviceConfig.RestartSec = 60;
        };

        nix.nixPath = [ "${cfg.package}/share/nix" ];
      };

    }

