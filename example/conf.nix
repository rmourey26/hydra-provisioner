{

  # Tag used for NixOps deployments created by the provisioner. Useful
  # if you're running multiple provisioners.
  #tag = "hydra-provisioned";

  # The spec must contain one or more sets named systemTypes.<type>,
  # where <type> is a Nix system type such as "x86_64-linux". You 
  # can also list system features (e.g. "x86_64-linux:benchmark"), in 
  # which case only build steps that have "requiredSystemFeatures" set to
  # the listed features will be executed on the machines created here.
  systemTypes.x86_64-linux = {

    # Path to NixOps module defining the deployment for this type.
    nixopsExpr = builtins.toPath ./deployment.nix;

    # The minimum number of machines to keep around for this type.
    #minMachines = 0;

    # The maximum number of machines to provision for this type.
    #maxMachines = 1;

    # Value subtracted from the number of runnables of this type. This
    # is the number of runnables to be performed by non-provisioned
    # machines, before the provisioner kicks in to create more
    # machines.
    #ignoredRunnables = 0;

    # How many machines should be created given the number of
    # runnables. For instance, if there are 10 runnables and
    # runnablesPerMachine is 5, then 2 machines will be created.
    #runnablesPerMachine = 10;

    # How many jobs can be run concurrently on machines of this type.
    #maxJobs = 1;

    # The speed factor.
    #speedFactor = 1;

    # The path of the SSH private key.
    #sshKey = "/var/lib/hydra/queue-runner/.ssh/id_buildfarm";

    # Whether to stop or destroy the machine when it's idle.
    #stopOnIdle = false;

    # Grace period in seconds before an idle machine is stopped or
    # destroyed. Thus, if Hydra load increases in the meantime, the
    # machine can be put back in action. Note that regardless of this 
    # setting, EC2 instances are not stopped or destroyed until their 
    # current hour of execution time has nearly expired.
    #gracePeriod = 0;

  };
  
  # Command for getting the Hydra queue status. Useful if the provisioner 
  # runs on a different machine from the queue runner.
  #sshCommand = ["hydra-queue-runner", "--status"]
  
  # Command for writing the queue runner's machines file. The contents are 
  # passed via stdin.
  #updateCommand = [ "/bin/sh" "-c" "cat > /var/lib/hydra/provisioner/machines" ];
}
