{ lib, ... }:

with lib;
with types;

{
  options = {
    nixopsExpr = mkOption {
      type = path;
      description = ''
        Path to NixOps module defining the deployment for this type.
      '';
    };

    minMachines = mkOption {
      type = ints.unsigned;
      default = 0;
      description = ''
        The minimum number of machines to keep around for this type.
      '';
    };

    maxMachines = mkOption {
      type = ints.unsigned;
      default = 0;
      description = ''
        The maximum number of machines to provision for this type.
      '';
    };

    nixPath = mkOption {
      type = listOf str;
      default = [];
    };

    ignoredRunnables = mkOption {
      type = ints.unsigned;
      default = 0;
      description = ''
        Value subtracted from the number of runnables of this type. This
        is the number of runnables to be performed by non-provisioned
        machines, before the provisioner kicks in to create more
        machines.
      '';
    };

    runnablesPerMachine = mkOption {
      type = ints.unsigned;
      default = 10;
      description = ''
        How many machines should be created given the number of
        runnables. For instance, if there are 10 runnables and
        runnablesPerMachine is 5, then 2 machines will be created.
      '';
    };

    maxJobs = mkOption {
      type = ints.unsigned;
      default = 1;
      description = ''
        How many jobs can be run concurrently on machines of this type.
      '';

    };

    sppedFactor = mkOption {
      type = ints.unsigned;
      default = 1;
      description = ''
        The speed factor.
      '';
    };

    sshKey = mkOption {
      type = str;
      example = "/var/lib/hydra/queue-runner/.ssh/id_buildfarm";
      description = ''
        The path of the SSH private key.
      '';
    };

    stopOnIdle = mkOption {
      type = bool;
      default = false;
      description = ''
        Whether to stop or destroy the machine when it's idle.
      '';
    };

    gracePeriod = mkOption {
      type = ints.unsigned;
      default = 0;
      description = ''
        Grace period in seconds before an idle machine is stopped or
        destroyed. Thus, if Hydra load increases in the meantime, the
        machine can be put back in action. Note that regardless of this
        setting, EC2 instances are not stopped or destroyed until their
        current hour of execution time has nearly expired.
      '';
    };
  };
}
