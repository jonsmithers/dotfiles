Dear self,

Herein lie all your dotfiles. Clone the repo and execute
[`./setup-everything.sh`] to symlink your dotfiles and install all the basic
essentials. The script will detect already-installed tools and skip over them.
It will also prompt before every install it performs so you can skip parts of
your choosing.

Edit [_config.json_] to change how things get symlink.

#### Details:

The [_dotphile_] python script reads the symlink configuration from
[_config.json_] and creates those symlinks in a safe and communicative manner.
Python is pre-installed on most unix system. If the system Python is version 3,
then [_setup-everything.sh_] script will run it through Python's `2to3`
transpiler before execution.

[_config.json_]:           https://github.com/jonsmithers/dotfiles/blob/master/config.json "View File"
[_dotphile_]:              https://github.com/jonsmithers/dotfiles/blob/master/dotphile "View File"
[_setup-everything.sh_]:   https://github.com/jonsmithers/dotfiles/blob/master/setup-everything.sh "View File"
[`./setup-everything.sh`]: https://github.com/jonsmithers/dotfiles/blob/master/setup-everything.sh "View File"

[modeline]: # ( vim: set tw=80: )
