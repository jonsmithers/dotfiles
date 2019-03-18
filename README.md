Dear self,

Herein lie all your dotfiles. Clone the repo and execute
[`./setup-everything`] to symlink your dotfiles and install all the basic
essentials. Edit [_config.json_] to change how files get symlink.

#### Behavior of [_setup-everything_] script

* Detects if tools are already installed and skips over them.
* Prompts for confirmation before installing each item, so you can skip parts of
  your choosing. 
* The symlink process never overwrites files. You need to manually delete/move
  existing files if they are preventing a symlink.

#### Characteristics of [vimrc] file

* Automatically installs all your plugins upon first launch.
* Gracefully handles a large variety of vim versions, vim forks, and even
  operating systems (like Windows :scream:).

#### Other implementation details

The [_dotphile_] python script reads the symlink configuration from
[_config.json_] and creates those symlinks in a safe and communicative manner.
Python is pre-installed on most unix system. If the system Python is version 3,
then [_setup-everything_] script will run it through Python's `2to3` transpiler
before execution.

[_config.json_]:        https://github.com/jonsmithers/dotfiles/blob/master/config.json      "View File"
[_dotphile_]:           https://github.com/jonsmithers/dotfiles/blob/master/dotphile         "View File"
[_setup-everything_]:   https://github.com/jonsmithers/dotfiles/blob/master/setup-everything "View File"
[`./setup-everything`]: https://github.com/jonsmithers/dotfiles/blob/master/setup-everything "View File"
[vimrc]:                https://github.com/jonsmithers/dotfiles/blob/master/vim/vimrc        "View File"

[modeline]: # ( vim: set tw=80: )
