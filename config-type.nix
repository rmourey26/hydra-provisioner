{ lib, ... }:

with lib;
with types;

{
  options = {
    sshCommand = mkOption {
      type = listOf str;
      default = ["hydra-queue-runner" "--status"];
      description = ''
        Command for getting the Hydra queue status. Useful if the provisioner
        runs on a different machine from the queue runner.
      '';
    };

    updateCommand = mkOption {
      type = listOf str;
      default = [ "/bin/sh" "-c" "cat > /var/lib/hydra/provisioner/machines" ];
      description = ''
        Command for writing the queue runner's machines file. The contents are
        passed via stdin.
      '';
    };

    tag = mkOption {
      type = str;
      default = "hydra-provisioned";
      description = ''
        Tag used for NixOps deployments created by the provisioner. Useful
        if you're running multiple provisioners.
      '';
    };

    systemTypes = mkOption {
      description = ''
        The spec must contain one or more sets named systemTypes.<type>,
        where <type> is a Nix system type such as "x86_64-linux". You
        can also list system features (e.g. "x86_64-linux:benchmark"), in
        which case only build steps that have "requiredSystemFeatures" set to
        the listed features will be executed on the machines created here.
      '';
      type = attrsOf (submodule (import ./system-type.nix));
      default = {
        x86_64-linux = {
          nixopsExpr = "${./example/deployment.nix}";
          nixPath = [ "nixpkgs=channel:nixos-21.05-small" ];
          minMachines = 1;
          maxMachines = 1;
          ignoredRunnables = 0;
          runnablesPerMachine = 10;
          maxJobs = 4;
          # sshKey = "/var/lib/hydra/queue-runner/.ssh/id_buildfarm_rsa";
          sshKey = "/etc/nix/id_buildfarm";
        };
      };
    };
  };
}
