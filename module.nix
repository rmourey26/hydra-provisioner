{ config, lib, pkgs, ... }:

let
  cfg = config.services.hydra.provisioner;
  inherit (config.users.users.hydra-provisioner) home;
in

{
  options.services.hydra.provisioner = with lib; with types; {
    enable = mkEnableOption "Hydra Provisioner";

    package = mkOption {
      type = package;
      default = pkgs.hydra-provisioner;
      description = "Hydra provisioner package to use";
    };

    extraConfig = mkOption {
      type = str;
      description = "Hydra provisioner configuration";
      example = builtins.readFile ./examples/conf.nix;
    };
  };

  config = lib.mkIf cfg.enable {
    users.extraUsers.hydra-provisioner = {
      description = "Hydra provisioner";
      group = "hydra";
      home = "/var/lib/hydra-provisioner";
      useDefaultShell = true;
      createHome = true;
    };

    system.activationScripts.hydra-provisioner = lib.stringAfter [ "users" ]
    ''
      mkdir -m 0755 -p /var/lib/hydra/provisioner
      mkdir -m 0700 -p ${home}
      chown hydra-provisioner.hydra ${home} /var/lib/hydra/provisioner
    '';

    environment.systemPackages = with pkgs;
    [
      hydra-provisioner
      nixops
      awscli
    ];

  # FIXME: restrict PostgreSQL access.
  services.postgresql.identMap = ''
    hydra-users hydra-provisioner hydra
  '';

  services.hydra.buildMachinesFiles = [
    "/etc/nix/machines"
    "/var/lib/hydra/provisioner/machines"
  ];

  systemd.services.hydra-provisioner = {
    script = ''
        source /etc/profile
        while true; do
          timeout 3600 ${cfg.package}/bin/hydra-provisioner ${pkgs.writeText "conf.nix" cfg.extraConfig}
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
