# rnemeth90's Dotfiles

A collection of configuration files and setup scripts for quickly customizing a freshly installed operating system. These dotfiles support **Linux Mint**, **Debian-based distributions**, **Arch Linux**, and **macOS**.

## 🔨 Full Setup

Run the following command to clone the repository and start the setup:

```bash
cd && git clone https://github.com/rnemeth90/dotfiles.git && cd dotfiles && find . -type f -iname "*.sh" -exec chmod +x {} \; && ./setup.sh
```

## ❔ What Does This Do?

The [setup.sh](./setup.sh) script covers a variety of tasks to set up my environment:

- System Updates:
  - Installs all available updates for the detected operating system.
- Multi-OS Package Managers:
  - Automatically detects the OS and installs the appropriate package manager:
  - Linux Mint / Debian: apt
  - Arch Linux: pacman
  - macOS: brew
  - Additionally, installs Snap, Flatpak, and NVM (Node Version Manager).
- Development Packages:
  - Installs tools like git, curl, vim, and more, using a Brewfile or the system’s package manager.
- Applications:
  - Installs essential applications like tldr, docker, and development tools.
- Configuration:
  - Creates .bash.local and .gitconfig.local for environment-specific overrides.
- Git Setup:
  - Creates an SSH key and configures Git for use with GitHub.

## ✨ Key Features

- Multi-OS Support:
  - Automatically adapts to the detected operating system, ensuring seamless setup across Linux Mint, Debian-based, Arch Linux, and macOS.
- Custom Bash Setup:
  - Includes aliases, exports, and prompt customizations.
- Git Configuration:
  - Automatically sets up a Git user, default branch, and GPG signing.
- Go Workspace:
  - Creates a Go workspace ($HOME/repos/golang) and clones my Go projects.
- Repository Cloning:
  - Clones all my personal GitHub repositories into $HOME/repos.

## 🛠️ Prerequisites

Before running the setup, ensure the following tools are installed:

- `git`
- `curl`
- `bash`

## 🔧 Customization

`.bash.local`

This file is created during setup and can be used to define environment-specific configurations. Example:

```
# Add custom paths
export PATH="$HOME/custom/bin:$PATH"

# Define environment variables
export EDITOR="vim"
```

`.gitconfig.local`

Configure Git settings like username, email, and signing key:

    ```
    [user]
      name = John Doe
      email = john.doe@example.com
    [commit]
      gpgsign = true
    ```

### TO DO:

- Edit settings in /etc/default/grub (e.g., bootloader options).
- Fix thefuck installation issue.
- Add support for tldr installation (done).

Test it out and customize it to fit your needs. If you’re not sure, _consider trying it in a virtual machine first!_
