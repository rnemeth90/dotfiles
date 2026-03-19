# rnemeth90's Dotfiles

A collection of configuration files and setup scripts for quickly configuring a freshly installed operating system. These dotfiles support **Debian-based distributions**, **Arch Linux**, and **macOS**.

## Full Setup

Run the following command to clone the repository and start the setup:

```bash
cd && git clone https://github.com/rnemeth90/dotfiles.git && cd dotfiles && find . -type f -iname "*.sh" -exec chmod +x {} \; && ./setup.sh
```

You can also run individual setup steps by passing a function name:

```bash
./setup.sh install_packages
./setup.sh install_fonts
```

## What Does This Do?

The [setup.sh](./setup.sh) script runs the following steps in order:

1. **Symbolic links** -- Links shell configs, Neovim config, and other dotfiles from the repo into `$HOME` and `$HOME/.config`.
2. **Package managers** -- Installs Homebrew (macOS only), npm (via brew), and Rust/Cargo (via rustup).
3. **Shell configuration** -- Creates `~/.bash.local` for machine-specific PATH and environment overrides.
4. **OS packages** -- Detects the OS and installs packages from the appropriate list:
   - macOS: `brew install` from `os/mac/packages`
   - Debian/Ubuntu: `apt install` from `os/debian/packages`
   - Arch: `pacman`/`yay` from `os/arch/packages`
5. **Git configuration** -- Creates `~/.gitconfig.local` with user identity and default branch settings. Optionally clones personal repositories.
6. **Fonts** -- Downloads and installs Nerd Fonts from GitHub releases.
7. **Language tooling** -- Installs CLI tools via `go install`, `cargo install`, `npm install -g`, and `pip install`. On Debian, also runs additional manual installs (Chrome, Azure CLI, VS Code, Terraform, etc.).

## Key Features

- **Multi-OS support** -- Automatically detects macOS, Debian, or Arch and runs the appropriate install paths. OS-specific scripts are gated so they only run on their target platform.
- **Bash configuration** -- Modular setup with separate files for aliases, exports, prompt, options, colors, and autocompletion. Machine-specific overrides go in `~/.bash.local`.
- **Neovim (lazy.nvim)** -- Full configuration in `.config/nvim-lazy/` with LSP, completion (nvim-cmp), Treesitter, Snacks pickers, and Copilot integration.
- **Git configuration** -- Shared settings in `git/gitconfig` with local overrides in `~/.gitconfig.local`. SSH key setup is available but disabled by default in the main flow.
- **Utility scripts** -- A collection of shell scripts in `bin/` for Kubernetes, Azure, Go project scaffolding, VM provisioning, and general automation.

## Prerequisites

Before running the setup, ensure the following are installed:

- `git`
- `curl`
- `bash`

## Customization

### `.bash.local`

Created during setup. Use this for environment-specific configuration that should not be version-controlled:

```bash
export PATH="$HOME/custom/bin:$PATH"
export EDITOR="vim"
```

### `.gitconfig.local`

Created during setup. Configure your Git identity and optional commit signing:

```
[user]
  name = John Doe
  email = john.doe@example.com
[commit]
  gpgsign = true
```

## Repository Structure

```
dotfiles/
  setup.sh              Main entry point
  utils/                Shared shell helpers (colors, prompts, execute)
  shell/                Bash config files (aliases, exports, prompt, etc.)
  shell/bash_aliases.d/ Modular alias files (docker, git, k8s, terraform)
  git/                  Git config and SSH key setup scripts
  bin/                  Utility scripts and tools
  os/                   OS detection, symlinks, package lists, installers
  os/common/            Cross-platform installers (go, cargo, npm, pip, fonts)
  .config/nvim-lazy/    Neovim configuration (lazy.nvim)
  .config/              App configs (alacritty, kitty, bat, lazygit, tmux, etc.)
  conf/                 Misc config files (xinitrc, man page styles)
  golang/               Cobra CLI template
  packages              Reference package list with descriptions
```

## TO DO

- Edit settings in `/etc/default/grub` (bootloader options).

Test it out and customize it to fit your needs. If you're not sure, _consider trying it in a virtual machine first._
