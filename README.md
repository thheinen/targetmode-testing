# README

# Prerequisites

- Internet Connection
- Visual Studio Code
- An AWS account for instances to start in (Test Kitchen)
- Windows Subsystem for Linux, if on Windows
- Docker installed in WSL 2 or on MacOS

Alternative: Open in GitHub DevContainers and provide AWS credentials. This will fulfill all prerequisites

# Getting Started

## Visual Studio Code

- Open folder in Visual Studio Code
- When asked "Dev Container detected" select to open in Dev Container. Initial build can take 5-10 minutes due to dependencies
- You will end up in a preconfigured environment and can open a Terminal inside of it (if not done automatically)
- If you want to use Test Kitchen on AWS, you need to set the `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, and `AWS_REGION` environment variables in VS Code

## GitHub Codespaces

- Create a Codespace from the repository
- Add values for the `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, and `AWS_REGION` secrets if you want to use Test Kitchen on AWS

# Handling Changes in the Fork Branches

Whenever changes in any of the external repositories (usually in the `thheinen/target-mode` branches) occur, you need to rebuild the container. It will automatically execute the `import-patches.sh` script which bakes in the differences from those branches.

You can trigger a rebuild of the container via Ctrl-Shift-P and then "Dev Container: Rebuild Container". It is not necessary to build without cache. After the rebuild, apply the patches with the mentioned script again.

# Local Development

1. Ensure the `KITCHEN_LOCAL_YML` variable is set to `kitchen.ec2.yml`. This adds AWS-specific configuration on top of the general cookbook one
  - the config will limit access to the instance via SSH to the current IP
  - it also copies the auto-generated SSH key to root to enable root login
2. Run `kitchen` commands as usual

# Known Issues / Remediations

## Test Kitchen: Could not load the 'chef_target' provisioner

__Error:__

After any `kitchen` command, the following error is shown:
```
>>>>>> Message: Could not load the 'chef_target' provisioner from the load path
```

__Reason:__

The required patches were not applied, which is weird (see "Getting Started" and execute `import-patches.sh` against clean Chef Workstation).

## Test Kitchen: No instances for regex

__Error:__

After `kitchen list` or similar commands the following error is shown:
```
No instances for regex `', try running `kitchen list'
```

__Reason:__

All provider (AWS) specific resources are in `kitchen.ec2.yml` which is not the standard file for a local Kitchen configuration.
Execute `export KITCHEN_LOCAL_YML="kitchen.ec2.yml"` and execute the kitchen command again

## Test Kitchen: "requires a Train-based transport"

__Error:__

Chef Target Mode provisioner requires a Train-based transport like kitchen-transport-train to converge a machine remotely.

__Reason:__

- You need to switch the Train transport to `name: train` to enable exchange of connection data between the transport and Chef itself in __converge state__

## Test Kitchen: "can't modify frozen String"

__Error:__

After executing `kitchen create` the following error is displayed:

```
Failed to complete #create action: [can't modify frozen String: "" in the specified region eu-west-1.
```

__Reason:__

_Unknown_

Usually happens when SSH connection to a newly created instance on AWS does not work. Seems to work on GitHub Codespaces, but fails locally - while permitted IPs are set in `kitchen.ec2.yml` dynamically.

_Caution:_ sometimes does not remove the faulty instance, which continues to run and incur costs.

Likely cause: Not reverting from the `train` transport to the standard one
