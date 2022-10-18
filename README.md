## Description

This repository contains code used to test scaling out Terraform Cloud Agents with Terraform Enterprise. It consists on an example module and a PowerShell script that kicks off runs for `n` workspaces at the same time.

The module itself consists of a simple `time_sleep` delay of 30 seconds and a `random_string` that generates at least 10,000 characters to be stored in state.

The PowerShell script uses the Terraform Enterprise API to kick off runs in parallel.

## Related Repositories

Scale Test Setup: [https://github.com/HashiCorp-CSA/demo-tfe-scale-test-setup](https://github.com/HashiCorp-CSA/demo-tfe-agent-scale-test-setup)

## Getting Started & Documentation

To use this repository, there are two options. PowerShell or Bash depending on what you are most comfortable with. The PowerShell options provides more control over the rate of applies, whereas the bash version is single threaded and just kicks off one after the other.

### PowerShell

1. Clone the repository locally.
2. Have your instance of Terraform Enterprise spun up and ready for use.
2. Run the code in the (sister repository)[https://github.com/HashiCorp-CSA/demo-tfe-scale-test-setup] to generate the agents in AWS ECS and the workspaces and agent pools in Terraform Enterprise.
3. Generate a user or team token in Terraform Enterprise and store it in a file called `temptoken.txt` in the root of the repository or save it to pass as a command line argument.
4. Install PowerShell for your platform: https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell?view=powershell-7.2
5. Run the PowerShell script called `KickRuns.ps1` passing in the relevant parameters for your setup. The most important being:
    1. `-count`: The number of workspaces to run.
    3. `-workspaceNamePrefix`: The prefix of your workspaces.
    4. `-terraformUrl`: The URL of your instance of Terraform Enterprise.
    5. `-terraformToken`: The token for Terraform Enterprise (unless using `temptoken.txt`).
    6. `-organizationName`: The name of your organization in Terraform Enterprise.
6. For example on macOS, you can run the script like this: `pwsh ./KickRuns.ps1 -count 1600 -workspaceNamePrefix "test-agents-" -terraformUrl "https://mydemotfe.com" -terraformToken "<token>" -organizationName "my-organization"`

The runs will now kick off and you can observe them in the Terraform Enterprise UI. You can optionally run the `Stats.ps1` script to see how many runs are in progress via the Terraform Enterprise API.

### Bash

1. Clone the repository locally.
2. Have your instance of Terraform Enterprise spun up and ready for use.
2. Run the code in the (sister repository)[https://github.com/HashiCorp-CSA/demo-tfe-scale-test-setup] to generate the agents in AWS ECS and the workspaces and agent pools in Terraform Enterprise.
3. Generate a user or team token in Terraform Enterprise and store it in a file called `temptoken.txt` in the root of the repository or save it to pass as a command line argument.
4. Ensure you have `jq` installed and any other dependencies the script requires.
5. Run the bash script called `KickRuns.sh` passing in the relevant parameters for your setup. The most important being:
    1. `c`: The number of workspaces to run.
    3. `w`: The prefix of your workspaces.
    4. `u`: The URL of your instance of Terraform Enterprise.
    5. `t`: The token for Terraform Enterprise (unless using `temptoken.txt`).
    6. `o`: The name of your organization in Terraform Enterprise.
    7. `r`: The workspace run duration e.g. 120s. This needs to be longer for the bash version as it is single threaded and takes far longer to run all the workspaces.
6. For example you can run the script like this: `./KickRuns.sh -c 1600 -w "test-agents-" -u "https://mydemotfe.com" -t "<token>" -o "my-organization" -r "120s"`

## Contributing

To contribute to this repository, please fork it and raise a pull request.

## Disclaimer
“By using the software in this repository (the “Software”), you acknowledge that: (1) the Software is still in development, may change, and has not been released as a commercial product by HashiCorp and is not currently supported in any way by HashiCorp; (2) the Software is provided on an “as-is” basis, and may include bugs, errors, or other issues; (3) the Software is NOT INTENDED FOR PRODUCTION USE, use of the Software may result in unexpected results, loss of data, or other unexpected results, and HashiCorp disclaims any and all liability resulting from use of the Software; and (4) HashiCorp reserves all rights to make all decisions about the features, functionality and commercial release (or non-release) of the Software, at any time and without any obligation or liability whatsoever."
