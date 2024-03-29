# rnemeth90's dotfiles

## 🔨 Full Setup

```
cd && git clone https://github.com/rnemeth90/dotfiles.git && cd dotfiles && find . -type f -iname "*.sh" -exec chmod +x {} \; && ./setup.sh
```

## ❔ What does this do?

These are the base "dotfiles" that I use for setting up a new freshly installed [**Linux Mint OS**] to my tastes. The goal of the setup.sh script is to basically setup everything the way I like. Broadly said it covers:

- initial updates
- installing some basic gnome extensions, linux package managers (snap+flatpak) and development related package managers (homebrew, nvm+node)
- installing dev packages - from a Brewfile and with dnf or yum
- installing applications
- install Oh My Bash
- edits some settings and keyboard shortcuts
- creates bash and git config files + sets up an SSH key for Github

More specific local needs/overrides for bash + git can be configured by using the
.bash.local and .gitconfig.local files (created during setup).

If you want to use this or parts of it, you should naturally go through the files and see if it makes any sense for you. Personally I worked on this using virtual machines so that's always an option if you want to test it out or try modifying it.

### 💰 Credits

I took a lot of my initial inspiration from these two repos:

https://github.com/alrra/dotfiles (for MacOS or Ubuntu)

https://github.com/ruohola/dotfiles (for MacOS)

## TO DO:
- [ ] edit settings in `/etc/default/grub`
- [ ] thefuck install is not currently working
- [x] install tldr https://tldr.sh/
