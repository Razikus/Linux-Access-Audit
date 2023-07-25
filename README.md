
# AccessAudit README

## Video

Check instruction video! [here](https://www.youtube.com/watch?v=TwhQU6Aj2pI)

## Introduction

AccessAudit is a simple program that allows to forward all Access Linux Events into [immudb Vault](https://vault.immudb.io) 

## Features

The script will:

1. Ensure it's running on a Linux system.
2. Verify that the user has the necessary sudo privileges.
3. Get an immudb Vault Write API Key from the user.
4. Test the provided API key.
5. Check for the presence of the `curl` tool.
6. Create necessary configurations and scripts to forward access logs to the Vault.

## Prerequisites

1. Ensure the script is executed on a system running Linux.
2. The script must be executed by a user with sudo privileges.
3. You need to have the `curl`, `sudo` and `rsyslog` installed.
4. Access to immudb Vault with a valid Write API Key. (You can obtain it [here](https://vault.immudb.io/))

## Usage

1. Download the bash script or clone the repository containing the script.
2. Make the script executable: `chmod +x <script_name>.sh`
3. Run the script: `./<script_name>.sh`

Upon running, you'll be greeted with a welcome message outlining the steps the installer will take. It will also remind the user that AccessAudit will use the default collection and ledger.

To proceed with the installation, you will need to:

- Confirm your intention to continue.
- Provide your immudb Vault Write API Key when prompted.

The script will then check the validity of the provided API key, setup configurations, and restart the rsyslog service.

## Notes

- Ensure you have a proper backup or snapshot of your configurations before executing scripts that modify system configurations.
- Always review scripts and READMEs before executing them, especially when they require root or sudo privileges.

## Troubleshooting

1. If you encounter a message stating `Systems other than linux are not supported`, ensure you are running the script on a Linux system.
2. If the script says `sudo did not set us to uid 0`, ensure you're running the script as a user with sudo privileges.
3. In case the script aborts due to a failed API key check, verify the key you provided and try again.
4. If `curl` is not available, install it and then rerun the script.

## Contributions

Contributions are welcome! Please check with the project owner or the repository's contribution guidelines before making any changes.

## Support

For any issues, questions, or feedback, please refer to the project's issue tracker or contact the project maintainers.
