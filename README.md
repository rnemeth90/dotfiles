# Ryan's Dotfiles

### WSL Configuration / Install

Run the following to configure WSL from scratch...

```
bash -c "$(curl -fsSL https://raw.githubusercontent.com/rnemeth90/dotfiles/configure.sh)"
```

### Notes

Your dotfiles are how you personalize your system. These are mine.

If you're interested in the philosophy behind why projects like these are
awesome, you might want to [read Holman's post on the
subject](http://zachholman.com/2010/08/dotfiles-are-meant-to-be-forked/).

## topical

Everything's built around topic areas. If you're adding a new area to your
forked dotfiles — say, "Java" — you can simply add a `java` directory and put
files in there. Anything with an extension of `.bash` will get automatically
included into your shell. Anything with an extension of `.symlink` will get
symlinked without extension into `$HOME` when you run `script/bootstrap`.

## what's inside

A lot of stuff. Seriously, a lot of stuff. Check them out in the file browser
above and see what components may mesh up with you.
[Fork holman's](https://github.com/holman/dotfiles/fork) or [Fork mine](htps://github.com/rnemeth90/dotfiles/fork), remove what you don't
use, and build on what you do use.

## components

There's a few special files in the hierarchy.

- **bin/**: Anything in `bin/` will get added to your `$PATH` and be made
  available everywhere.
- **topic/\*.bash**: Any files ending in `.bash` get loaded into your
  environment.
- **topic/path.bash**: Any file named `path.bash` is loaded first and is
  expected to setup `$PATH` or similar.
- **topic/completion.bash**: Any file named `completion.bash` is loaded
  last and is expected to setup autocomplete.
- **topic/install.sh**: Any file named `install.sh` is executed when you run `script/install`. To avoid being loaded automatically, its extension is `.sh`, not `.bash`.
- **topic/\*.symlink**: Any file ending in `*.symlink` gets symlinked into
  your `$HOME`. This is so you can keep all of those versioned in your dotfiles
  but still keep those autoloaded files in your home directory. These get
  symlinked in when you run `script/bootstrap`.

## Git clone

There are two "master" branches here: WSL and PowerShell.

If you wish to clone these files and run scripts manually, run this:

```sh
git clone https://github.com/rnemeth90/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
script/bootstrap
```

This will symlink the appropriate files in `.dotfiles` to your home directory.
Everything is configured and tweaked within `~/.dotfiles`.

The main file you'll want to change right off the bat is `bash/bashrc.symlink`,
which sets up a few paths that'll be different on your particular machine.

## bugs

I want this to work for everyone; that means when you clone it down it should
work for you even though you may not have `rbenv` installed, for example. That
said, I do use this as _my_ dotfiles, so there's a good chance I may break
something if I forget to make a check for a dependency.

If you're brand-new to the project and run into any blockers, please
[open an issue](https://github.com/rnemeth90/dotfiles/issues) on this repository
and I'd love to get it fixed for you!

## thanks
