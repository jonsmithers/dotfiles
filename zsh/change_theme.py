#!/usr/bin/env python3
import subprocess
import sys
import fileinput
import re
from dataclasses import dataclass
from typing import Union, Literal
from os import path, environ, getenv
from collections import namedtuple


# SEARCH TERM \<change_vim_colorscheme\> \+\<[a-z\-]\+ \<

Url = namedtuple("Url", ["url"])
# TODO rename to ThemeKittenName
Name = namedtuple("Name", ["name"])


    # Theme(name="GitHub Dark"),
    # Theme(name="GitHub Dark Colorblind",      neovim_repo="git@github.com:projekt0n/github-nvim-theme.git",             neovim_dir_name="github-nvim-theme"),
    # Theme(name="GitHub Dark High Contrast",   neovim_repo="git@github.com:projekt0n/github-nvim-theme.git",             neovim_dir_name="github-nvim-theme"),
    # Theme(name="GitHub Dark Dimmed",          neovim_repo="git@github.com:projekt0n/github-nvim-theme.git",             neovim_dir_name="github-nvim-theme"),
    # Theme(name="GitHub Light"),
    # Theme(name="GitHub Light High Contrast",  neovim_repo="git@github.com:projekt0n/github-nvim-theme.git",             neovim_dir_name="github-nvim-theme"),
    # Theme(name="Gruvbox Dark"),
    # Theme(name="Gruvbox Light"),
# Theme = namedtuple('Theme', ['name', 'type', 'neovim_repo', 'neovim_dir_name'])
ThemeType = Union[Literal['light'], Literal['dark']]
@dataclass
class Theme:
  name: str
  """ Name displayed for selecting this theme. """
  neovim_repo: str
  """ git remote url to neovim plugin repo. """
  neovim_dir_name: str
  """ directory name for downloaded plugin. """
  neovim_name: str
  """ neovim's "colorscheme" is set to this value. """
  type: ThemeType
  """
  "dark" or "light".

  Neovim's "background" is set to this value.
  """
  neovim_global_vars: Union[str, None]
  kitty_source: Union[Url, Name]
  kitty_name: str


themes = [
    Theme(name="Apprentice Dark",             type="dark",  neovim_repo="git@github.com:romainl/Apprentice.git",                      neovim_dir_name="Apprentice",       neovim_name="apprentice",       neovim_global_vars=None,                               kitty_source=Name("Apprentice"),                                                                                        kitty_name="Apprentice"  ),
    # Theme(name="Ayu Dark",                    type="dark",  neovim_repo="git@github.com:ayu-theme/ayu-vim.git",                       neovim_dir_name="ayu-vim",          neovim_name="ayu",              neovim_global_vars=None,                               kitty_source=Name("Ayu")  ),
    Theme(name="Ayu Light",                   type="light", neovim_repo="git@github.com:ayu-theme/ayu-vim.git",                       neovim_dir_name="ayu-vim",          neovim_name="ayu",              neovim_global_vars="ayucolor=light",                   kitty_source=Name("Ayu Light"),                                                                                         kitty_name="Ayu Light"  ),
    Theme(name="Ayu Mirage",                  type="dark",  neovim_repo="git@github.com:ayu-theme/ayu-vim.git",                       neovim_dir_name="ayu-vim",          neovim_name="ayu",              neovim_global_vars="ayucolor=mirage",                  kitty_source=Name("Ayu Mirage"),                                                                                        kitty_name="Ayu Mirage" ),
    Theme(name="Catppuccin Frappe",           type="dark",  neovim_repo="https://github.com/catppuccin/nvim.git",                     neovim_dir_name="catppuccin",       neovim_name="catppuccin",       neovim_global_vars="catppuccin_flavour=frappe",        kitty_source=Url("https://raw.githubusercontent.com/catppuccin/kitty/main/themes/frappe.conf"),                         kitty_name="catppuccin_frappe" ),
    Theme(name="Catppuccin Latte",            type="light", neovim_repo="https://github.com/catppuccin/nvim.git",                     neovim_dir_name="catppuccin",       neovim_name="catppuccin",       neovim_global_vars="catppuccin_flavour=latte",         kitty_source=Url("https://raw.githubusercontent.com/catppuccin/kitty/main/themes/latte.conf"),                          kitty_name="catppuccin_latte" ),
    Theme(name="Catppuccin Macchiato",        type="dark",  neovim_repo="https://github.com/catppuccin/nvim.git",                     neovim_dir_name="catppuccin",       neovim_name="catppuccin",       neovim_global_vars="catppuccin_flavour=macchiato",     kitty_source=Url("https://raw.githubusercontent.com/catppuccin/kitty/main/themes/macchiato.conf"),                      kitty_name="catppuccin_macchiato" ),
    Theme(name="Catppuccin Mocha",            type="dark",  neovim_repo="https://github.com/catppuccin/nvim.git",                     neovim_dir_name="catppuccin",       neovim_name="catppuccin",       neovim_global_vars="catppuccin_flavour=mocha",         kitty_source=Url("https://raw.githubusercontent.com/catppuccin/kitty/main/themes/mocha.conf"),                          kitty_name="catppuccin_mocha" ),
    Theme(name="Gruvbox Material Dark Hard",  type="dark",  neovim_repo="git@github.com:sainnhe/gruvbox-material.git",                neovim_dir_name="gruvbox-material", neovim_name="gruvbox-material", neovim_global_vars="gruvbox_material_background=hard", kitty_source=Name("Gruvbox Dark Hard"),                                                                                 kitty_name="Gruvbox Dark Hard" ),
    Theme(name="Gruvbox Material Dark Soft",  type="dark",  neovim_repo="git@github.com:sainnhe/gruvbox-material.git",                neovim_dir_name="gruvbox-material", neovim_name="gruvbox-material", neovim_global_vars="gruvbox_material_background=hard", kitty_source=Name("Gruvbox Dark Soft"),                                                                                 kitty_name="Gruvbox Dark Soft" ),
    Theme(name="Gruvbox Material Light Hard", type="light", neovim_repo="git@github.com:sainnhe/gruvbox-material.git",                neovim_dir_name="gruvbox-material", neovim_name="gruvbox-material", neovim_global_vars="gruvbox_material_background=hard", kitty_source=Name("Gruvbox Light Hard"),                                                                                kitty_name="Gruvbox Light Hard" ),
    Theme(name="Gruvbox Material Light Soft", type="light", neovim_repo="git@github.com:sainnhe/gruvbox-material.git",                neovim_dir_name="gruvbox-material", neovim_name="gruvbox-material", neovim_global_vars="gruvbox_material_background=hard", kitty_source=Name("Gruvbox Light Soft"),                                                                                kitty_name="Gruvbox Light Soft" ),
    Theme(name="JetBrains Darcula",           type="dark",  neovim_repo="git@github.com:santos-gabriel-dario/darcula-solid.nvim.git", neovim_dir_name="darcula-solid",    neovim_name="darcula",          neovim_global_vars=None,                               kitty_source=Name("Jet Brains Darcula"),                                                                                kitty_name="Jet Brains Darcula" ),
    Theme(name="Kanagawa Dragon",             type="dark",  neovim_repo="git@github.com:rebelot/kanagawa.nvim.git",                   neovim_dir_name="kanagawa.nvim",    neovim_name="kanagwa-dargon",   neovim_global_vars=None,                               kitty_source=Url("https://raw.githubusercontent.com/rebelot/kanagawa.nvim/master/extras/kanagawa_dragon.conf"),         kitty_name="Kanagawa Dragon"),
    Theme(name="Kanagawa Lotus",              type="light", neovim_repo="git@github.com:rebelot/kanagawa.nvim.git",                   neovim_dir_name="kanagawa.nvim",    neovim_name="kanagwa-lotus",    neovim_global_vars=None,                               kitty_source=Url("https://raw.githubusercontent.com/rebelot/kanagawa.nvim/master/extras/kanagawa_light.conf"),          kitty_name="Kanagawa Lotus"),
    Theme(name="Kanagawa Wave",               type="dark",  neovim_repo="git@github.com:rebelot/kanagawa.nvim.git",                   neovim_dir_name="kanagawa.nvim",    neovim_name="kanagwa-wave",     neovim_global_vars=None,                               kitty_source=Url("https://raw.githubusercontent.com/rebelot/kanagawa.nvim/master/extras/kanagawa.conf"),                kitty_name="Kanagawa Wave"),
    Theme(name="Nightfox Nightfox",           type="dark",  neovim_repo="git@github.com:EdenEast/nightfox.nvim.git",                  neovim_dir_name="nightfox.nvim",    neovim_name="nightfox",         neovim_global_vars=None,                               kitty_source=Url("https://raw.githubusercontent.com/EdenEast/nightfox.nvim/main/extra/nightfox/nightfox_kitty.conf"),   kitty_name="nightfox-nightfox" ),
    Theme(name="Nightfox Carbonfox",          type="dark",  neovim_repo="git@github.com:EdenEast/nightfox.nvim.git",                  neovim_dir_name="nightfox.nvim",    neovim_name="carbonfox",        neovim_global_vars=None,                               kitty_source=Url("https://raw.githubusercontent.com/EdenEast/nightfox.nvim/main/extra/carbonfox/nightfox_kitty.conf"),  kitty_name="nightfox-carbonfox" ),
    Theme(name="Nightfox Dayfox",             type="dark",  neovim_repo="git@github.com:EdenEast/nightfox.nvim.git",                  neovim_dir_name="nightfox.nvim",    neovim_name="dayfox",           neovim_global_vars=None,                               kitty_source=Url("https://raw.githubusercontent.com/EdenEast/nightfox.nvim/main/extra/dayfox/nightfox_kitty.conf"),     kitty_name="nightfox-dayfox" ),
    Theme(name="Nightfox Dawnfox",            type="dark",  neovim_repo="git@github.com:EdenEast/nightfox.nvim.git",                  neovim_dir_name="nightfox.nvim",    neovim_name="dawnfox",          neovim_global_vars=None,                               kitty_source=Url("https://raw.githubusercontent.com/EdenEast/nightfox.nvim/main/extra/dawnfox/nightfox_kitty.conf"),    kitty_name="nightfox-dawnfox" ),
    Theme(name="Nightfox Duskfox",            type="dark",  neovim_repo="git@github.com:EdenEast/nightfox.nvim.git",                  neovim_dir_name="nightfox.nvim",    neovim_name="duskfox",          neovim_global_vars=None,                               kitty_source=Url("https://raw.githubusercontent.com/EdenEast/nightfox.nvim/main/extra/duskfox/nightfox_kitty.conf"),    kitty_name="nightfox-duskfox" ),
    Theme(name="Nightfox Nordfox",            type="dark",  neovim_repo="git@github.com:EdenEast/nightfox.nvim.git",                  neovim_dir_name="nightfox.nvim",    neovim_name="nordfox",          neovim_global_vars=None,                               kitty_source=Url("https://raw.githubusercontent.com/EdenEast/nightfox.nvim/main/extra/nordfox/nightfox_kitty.conf"),    kitty_name="nightfox-nordfox" ),
    Theme(name="Nightfox Terafox",            type="dark",  neovim_repo="git@github.com:EdenEast/nightfox.nvim.git",                  neovim_dir_name="nightfox.nvim",    neovim_name="terafox",          neovim_global_vars=None,                               kitty_source=Url("https://raw.githubusercontent.com/EdenEast/nightfox.nvim/main/extra/terafox/nightfox_kitty.conf"),    kitty_name="nightfox-terafox" ),
    Theme(name="Nordic",                      type="dark",  neovim_repo="git@github.com:AlexvZyl/nordic.nvim.git",                    neovim_dir_name="nordic.nvim",      neovim_name="nordic",           neovim_global_vars=None,                               kitty_source=Url("https://raw.githubusercontent.com/AlexvZyl/nordic.nvim/refs/heads/main/platforms/kitty/nordic.conf"), kitty_name="nordic" ),
    Theme(name="One Dark",                    type="dark",  neovim_repo="git@github.com:joshdick/onedark.vim.git",                    neovim_dir_name="onedark.vim",      neovim_name="onedark",          neovim_global_vars=None,                               kitty_source=Name("One Dark"),                                                                                          kitty_name=("One Dark") ),
    Theme(name="One Light",                   type="light", neovim_repo="git@github.com:rakr/vim-one.git",                            neovim_dir_name="vim-one",          neovim_name="one",              neovim_global_vars=None,                               kitty_source=Name("One Half Light"),                                                                                    kitty_name=("One Half Light") ),
    # Theme(name="Rose Pine",                   type="dark",  neovim_repo="git@github.com:rose-pine/neovim.git",                        neovim_dir_name="rose-pine",        neovim_name="rose-pine",        neovim_global_vars=None,                               ),
    # Theme(name="Rose Pine Dawn",              type="light", neovim_repo="git@github.com:rose-pine/neovim.git",                        neovim_dir_name="rose-pine",        neovim_name="rose-pine",        neovim_global_vars=None,                               ),
    Theme(name="Seoul256 Dark",               type="dark",  neovim_repo="git@github.com:junegunn/seoul256.vim.git",                   neovim_dir_name="seoul256.vim",     neovim_name="seoul256",         neovim_global_vars=None,                               kitty_source=Url("https://raw.githubusercontent.com/malikbenkirane/kitty-colors/master/seoul256.kitty-conf"),           kitty_name="seoul256" ),
    Theme(name="Seoul256 Light",              type="light", neovim_repo="git@github.com:junegunn/seoul256.vim.git",                   neovim_dir_name="seoul256.vim",     neovim_name="seoul256-light",   neovim_global_vars=None,                               kitty_source=Url("https://raw.githubusercontent.com/malikbenkirane/kitty-colors/master/seoul256-light.kitty-conf"),     kitty_name="seoul256-light" ),
    Theme(name="TokyoNight Night",            type="dark",  neovim_repo="git@github.com:folke/tokyonight.nvim.git",                   neovim_dir_name="tokyonight.nvim",  neovim_name="tokyonight-night", neovim_global_vars=None,                               kitty_source=Name("Tokyo Night"),                                                                                       kitty_name=("Tokyo Night") ),
    Theme(name="TokyoNight Day",              type="light", neovim_repo="git@github.com:folke/tokyonight.nvim.git",                   neovim_dir_name="tokyonight.nvim",  neovim_name="tokyonight-day",   neovim_global_vars=None,                               kitty_source=Name("Tokyo Night Day"),                                                                                   kitty_name=("Tokyo Night Day") ),
    Theme(name="TokyoNight Moon",             type="dark",  neovim_repo="git@github.com:folke/tokyonight.nvim.git",                   neovim_dir_name="tokyonight.nvim",  neovim_name="tokyonight-moon",  neovim_global_vars=None,                               kitty_source=Name("Tokyo Night Storm"),                                                                                 kitty_name=("Tokyo Night Storm") ),
    Theme(name="TokyoNight Storm",            type="dark",  neovim_repo="git@github.com:folke/tokyonight.nvim.git",                   neovim_dir_name="tokyonight.nvim",  neovim_name="tokyonight-storm", neovim_global_vars=None,                               kitty_source=Name("Tokyo Night Moon"),                                                                                  kitty_name=("Tokyo Night Moon") ),
    Theme(name="Zenbones Dark",               type="dark",  neovim_repo="git@github.com:mcchrish/zenbones.nvim.git",                  neovim_dir_name="zenbones.nvim",    neovim_name="zenbones",         neovim_global_vars="zenbones_compat=1",                kitty_source=Url("https://raw.githubusercontent.com/mcchrish/zenbones.nvim/main/extras/kitty/zenbones_dark.conf"),      kitty_name="zenbones-dark" ),
    Theme(name="Zenbones Light",              type="light", neovim_repo="git@github.com:mcchrish/zenbones.nvim.git",                  neovim_dir_name="zenbones.nvim",    neovim_name="zenbones",         neovim_global_vars="zenbones_compat=1",                kitty_source=Url("https://raw.githubusercontent.com/mcchrish/zenbones.nvim/main/extras/kitty/zenbones_light.conf"),     kitty_name="zenbones-light" ),
    Theme(name="Zenbones Neobones Dark",      type="dark",  neovim_repo="git@github.com:mcchrish/zenbones.nvim.git",                  neovim_dir_name="zenbones.nvim",    neovim_name="neobones",         neovim_global_vars="zenbones_compat=1",                kitty_source=Url("https://raw.githubusercontent.com/mcchrish/zenbones.nvim/main/extras/kitty/neobones_dark.conf"),      kitty_name="zenbones-neobones-dark" ),
    Theme(name="Zenbones Neobones Light",     type="light", neovim_repo="git@github.com:mcchrish/zenbones.nvim.git",                  neovim_dir_name="zenbones.nvim",    neovim_name="neobones",         neovim_global_vars="zenbones_compat=1",                kitty_source=Url("https://raw.githubusercontent.com/mcchrish/zenbones.nvim/main/extras/kitty/neobones_light.conf"),     kitty_name="zenbones-neobones-light" ),
    Theme(name="Zenbones Seoulbones Dark",    type="dark",  neovim_repo="git@github.com:mcchrish/zenbones.nvim.git",                  neovim_dir_name="zenbones.nvim",    neovim_name="seoulbones",       neovim_global_vars="zenbones_compat=1",                kitty_source=Url("https://raw.githubusercontent.com/mcchrish/zenbones.nvim/main/extras/kitty/seoulbones_dark.conf"),    kitty_name="zenbones-seoulbones-dark" ),
    Theme(name="Zenbones Seoulbones Light",   type="light", neovim_repo="git@github.com:mcchrish/zenbones.nvim.git",                  neovim_dir_name="zenbones.nvim",    neovim_name="seoulbones",       neovim_global_vars="zenbones_compat=1",                kitty_source=Url("https://raw.githubusercontent.com/mcchrish/zenbones.nvim/main/extras/kitty/seoulbones_light.conf"),   kitty_name="zenbones-seoulbones-light" ),
    Theme(name="Zenbones Zenwritten Dark",    type="dark",  neovim_repo="git@github.com:mcchrish/zenbones.nvim.git",                  neovim_dir_name="zenbones.nvim",    neovim_name="zenwritten",       neovim_global_vars="zenbones_compat=1",                kitty_source=Url("https://raw.githubusercontent.com/mcchrish/zenbones.nvim/main/extras/kitty/zenwritten_dark.conf"),    kitty_name="zenbones-zenwritten-dark" ),
    Theme(name="Zenbones Zenwritten Light",   type="light", neovim_repo="git@github.com:mcchrish/zenbones.nvim.git",                  neovim_dir_name="zenbones.nvim",    neovim_name="zenwritten",       neovim_global_vars="zenbones_compat=1",                kitty_source=Url("https://raw.githubusercontent.com/mcchrish/zenbones.nvim/main/extras/kitty/zenwritten_light.conf"),   kitty_name="zenbones-zenwritten-light" ),
    ]


fzf_result = subprocess.run(args=["fzf", "--border=rounded", "--prompt='Choose a Theme: '"], input="\n".join(t.name for t in themes), text=True, capture_output=True)

if fzf_result.returncode != 0:
  exit(fzf_result.returncode)

theme = next(t for t in themes if t.name == fzf_result.stdout.strip())

def procure_neovim_theme():
  expected_path = path.expanduser(f"~/.config/nvim/pack/{theme.neovim_dir_name}/start/{theme.neovim_dir_name}")
  if path.isdir(path.expanduser(f"~/.config/nvim/pack/{theme.neovim_dir_name}/start/{theme.neovim_dir_name}")):
    print(f"Found {theme.neovim_dir_name} in {expected_path}")
  else:
    print("Obtaining neovim theme from git repo")
    subprocess.run(["git", "clone", theme.neovim_repo, expected_path])

procure_neovim_theme()

def replace_or_add_line(file: str, regex: str, replacement: str):
  with fileinput.input(files=path.expanduser(file), inplace=True) as f:
    line_added=False
    for line in f:
      if re.match(regex, line):
        line_added=True
        print(replacement)
      else:
        print(line, end='')
    if not line_added:
      print(replacement)
def replace_or_add_lines(file: str, start_pattern: str, end_pattern: str, replacement: str):
  with open(path.expanduser(file), 'r') as f:
    file_content = f.read()
    print("LINES START")
    print(file_content)
    print("LINES END")
    pattern = re.compile(rf"{start_pattern}.*?{end_pattern}", re.DOTALL)
    new_content=re.sub(pattern, f"{start_pattern}\n{replacement}\n{end_pattern}\n", file_content)
    with open(path.expanduser(file), 'w') as fw:
      print('NEW CONTENT')
      print(new_content)
      print('^^^^')
      fw.write(new_content)


replace_or_add_line("~/.zshenv", "^export VIM_BACKGROUND=.*",    f"export VIM_BACKGROUND={theme.type}")
replace_or_add_line("~/.zshenv", "^export VIM_COLORSCHEME=.*",   f"export VIM_COLORSCHEME={theme.neovim_name}")
replace_or_add_line("~/.zshenv", "^export VIM_THEME_GLOBALS=.*", f"export VIM_THEME_GLOBALS='{'' if theme.neovim_global_vars is None else theme.neovim_global_vars}'")

def run_bash(command: str):
  print(command)
  done = subprocess.run(
    args=["bash", "-c", command],
    text=True,
    capture_output=True
  )
  if done.returncode:
    print(done.stderr)
    exit(done.returncode)

def procure_kitty_theme():
  if type(theme.kitty_source) == Name:
    run_bash(command = f"kitty +kitten themes --dump-theme '{theme.kitty_source.name}' > $HOME/.config/kitty/'{theme.name}'.conf")
  elif type(theme.kitty_source) == Url:
    run_bash(command = f"curl --fail '{theme.kitty_source.url}' > \"$HOME/.config/kitty/{theme.name}.conf\"")
  else:
    print('unhandled type')
    exit(1)

procure_kitty_theme()
replace_or_add_lines(
  file="~/.config/kitty/profile.conf",
  start_pattern="# begin auto-generated kitty theme setting",
  end_pattern="# end auto-generated kitty theme setting",
  replacement=f"include {theme.name}.conf",
)

# This script prompts for choice of theme and then configures vim and kitty to
# have matching themes.
#
# Additional Kitty Setup
# =======================
#
# None. This script will automatically obtain the necessary theme assets.
#
#
# Additional Vim Setup
# ====================
#
# 1. If the script doesn't see the theme plugins in your vimrc, it will
#    automatically download colorscheme plugins into vim's native plugin
#    directory:
#
#        git clone <theme-repo> ~/.vim/pack/<theme>/start/<theme>
#
# 2. Configure vimrc to read environment variables "$VIM_BACKGROUND" and
#    "$VIM_COLORSCHEME" and "$VIM_THEME_GLOBALS" like so:
#
#        if (!exists('g:colors_name')) " no colorscheme set
#          if exists('$VIM_BACKGROUND')
#            execute 'set background='..$VIM_BACKGROUND
#          endif
#          if exists('$VIM_COLORSCHEME')
#            execute 'silent! colorscheme '..$VIM_COLORSCHEME
#          endif
#          if exists('$VIM_THEME_GLOBALS')
#            for assignment in split($VIM_THEME_GLOBALS, ',')
#              sandbox execute 'let g:'..split(assignment, '=')[0]..'="'..split(assignment, '=')[1]..'"'
#            endfor
#            execute 'silent! colorscheme ' .. $VIM_COLORSCHEME
#          endif
#        endif

# set -e -o pipefail
#
# function change_vim_colorscheme() {
#   local theme="$1"
#   local globals="$2"
#   echo setting vim theme to "$theme"
#   local line_to_insert="export VIM_COLORSCHEME=$theme"
#   if grep --quiet '^export VIM_COLORSCHEME' < ~/.zshenv; then
#     sed -I '.sedbackup' 's/^export VIM_COLORSCHEME=.*/'"$line_to_insert"'/' ~/.zshenv
#     rm ~/.zshenv.sedbackup
#   else
#     echo "$line_to_insert" >> ~/.zshenv
#   fi
#   line_to_insert="export VIM_THEME_GLOBALS='$globals'"
#   if grep --quiet '^export VIM_THEME_GLOBALS' < ~/.zshenv; then
#     sed -I '.sedbackup' 's/^export VIM_THEME_GLOBALS=.*/'"$line_to_insert"'/' ~/.zshenv
#     rm ~/.zshenv.sedbackup
#   else
#     echo "$line_to_insert" >> ~/.zshenv
#   fi
# }
# function change_vim_background() {
#   local background=$1
#   local line_to_insert="export VIM_BACKGROUND=$background"
#   if grep --quiet '^export VIM_BACKGROUND' < ~/.zshenv; then
#     sed -I '.sedbackup' 's/^export VIM_BACKGROUND=.*/'"$line_to_insert"'/' ~/.zshenv
#     rm ~/.zshenv.sedbackup
#   else
#     echo "$line_to_insert" >> ~/.zshenv
#   fi
# }
# function change_kitty_theme() {
#   local theme=$1
#   echo setting kitty theme to "$theme"
#   [[ -f "$HOME/.config/kitty/profile.conf" ]] || touch ~/.config/kitty/profile.conf
#   if ! grep --quiet "include profile.conf" < ~/.config/kitty/kitty.conf; then
#     echo "include profile.conf" >> ~/.config/kitty/kitty.conf
#   fi
#   local sed_target
#   sed_target="$(readlink ~/.config/kitty/profile.conf || echo ~/.config/kitty/profile.conf)"
#   sed \
#     -I '.sedbackup' \
#     '/# begin auto-generated kitty theme setting/,/# end auto-generated kitty theme setting/s/^[^#].*$/include '"$theme"'.conf/' \
#     "$sed_target"
#   rm "${sed_target}.sedbackup"
#   if ! grep --quiet "^include $theme.conf$" < "$sed_target"; then
#     echo "adding auto-generated section to $sed_target"
#     {
#       echo '# begin auto-generated kitty theme setting'
#       echo "include $theme.conf"
#       echo '# end auto-generated kitty theme setting'
#     } >> "$sed_target"
#   fi
#   [[ -f "$HOME/.config/kitty/$theme.conf" ]] || {
#     echo This kitty theme does not exist! "$HOME/.config/kitty/$theme.conf"
#   }
# }
# function obtain_neovim_theme_from_git() {
#   local theme_plugin=$1
#   local git_remote=$2
#   if [[ -d "$HOME/.config/nvim/pack/$theme_plugin/start/$theme_plugin" ]]; then
#     echo found "$theme_plugin" in ~/.config/nvim/pack/"$theme_plugin"/start
#     return
#   else
#     echo obtaining neovim theme from git repo;
#     git clone "$git_remote" "$HOME/.config/nvim/pack/$theme_plugin/start/$theme_plugin"
#   fi
# }
# function obtain_kitty_theme_from_curl() {
#   local theme=$1
#   local curl_url=$2
#   [[ -f "$HOME/.config/kitty/$theme.conf" ]] || {
#     echo obtaining kitty theme from url
#     (
#       set -x;
#       curl --fail "$curl_url" > "$HOME/.config/kitty/$theme.conf";
#     )
#   }
# }
# function obtain_kitty_theme_from_kitten() {
#   local theme=$1
#   [[ -f "$HOME/.config/kitty/$theme.conf" ]] || {
#     echo obtaining kitty theme from kitten
#     kitty +kitten themes --dump-theme "$theme" > "$HOME/.config/kitty/$theme.conf"
#   }
# }
# function obtain_kitty_theme_from_github() {
#   local theme=$1
#   [[ -f "$HOME/.config/kitty/$theme.conf" ]] || {
#     echo obtaining kitty theme from github/projekt0n/github-nvim-theme;
#     curl --fail https://raw.githubusercontent.com/projekt0n/github-theme-contrib/main/themes/kitty/"$theme".conf > ~/.config/kitty/"$theme".conf;
#   }
# }
#
# theme=$1
# if [[ -z "$theme" ]]; then
#   themes=(
#     "Apprentice Dark"
#     "Ayu Dark"
#     "Ayu Light"
#     "Ayu Mirage"
#     "Catppuccin Frappe"
#     "Catppuccin Latte"
#     "Catppuccin Macchiato"
#     "Catppuccin Mocha"
#     "GitHub Dark"
#     "GitHub Dark Colorblind"
#     "GitHub Dark High Contrast"
#     "GitHub Dark Dimmed"
#     "GitHub Light"
#     "GitHub Light High Contrast"
#     "Gruvbox Dark"
#     "Gruvbox Light"
#     "Gruvbox Material Dark Hard"
#     "Gruvbox Material Dark Soft"
#     "Gruvbox Material Light Hard"
#     "Gruvbox Material Light Soft"
#     "JetBrains Darcula (dark)"
#     "Kanagawa Dragon (dark)"
#     "Kanagawa Lotus (light)"
#     "Kanagawa Wave (dark)"
#     "Neofusion (dark)"
#     "Nightfox Nightfox"
#     "Nightfox Carbonfox"
#     "Nightfox Dayfox"
#     "Nightfox Dawnfox"
#     "Nightfox Duskfox"
#     "Nightfox Nordfox"
#     "Nightfox Terafox"
#     "Nordic"
#     "One Dark"
#     "One Light"
#     "Rose Pine"
#     "Rose Pine Dawn"
#     # "Rose Pine Moon"
#     "Seoul256 Dark"
#     "Seoul256 Light"
#     "TokyoNight Night"
#     "TokyoNight Day"
#     "TokyoNight Moon"
#     "TokyoNight Storm"
#     "Zenbones Dark"
#     "Zenbones Light"
#     "Zenbones Neobones Dark"
#     "Zenbones Neobones Light"
#     "Zenbones Seoulbones Dark"
#     "Zenbones Seoulbones Light"
#     "Zenbones Zenwritten Dark"
#     "Zenbones Zenwritten Light"
#   );
#   PS3=$'\n'"select theme> "
#   if command -v fzf &> /dev/null; then
#     theme=$(( IFS=$'\n'; echo "${themes[*]}" ) | fzf --border=rounded --prompt='Choose a Theme: ')
#   else
#     select theme in "${themes[@]}"; do
#       break
#     done
#   fi
# fi
#
# case $theme in
#   "Apprentice Dark")
#     obtain_neovim_theme_from_git   Apprentice git@github.com:romainl/Apprentice.git
#     change_vim_background          dark
#     change_vim_colorscheme         apprentice
#     obtain_kitty_theme_from_kitten Apprentice
#     change_kitty_theme             Apprentice
#     ;;
#   "Ayu Dark")
#     obtain_neovim_theme_from_git   ayu-vim git@github.com:ayu-theme/ayu-vim.git
#     change_vim_background          dark
#     change_vim_colorscheme         ayu
#     obtain_kitty_theme_from_kitten Ayu
#     change_kitty_theme             Ayu
#     ;;
#   "Ayu Light")
#     obtain_neovim_theme_from_git   ayu-vim git@github.com:ayu-theme/ayu-vim.git
#     change_vim_background          light
#     change_vim_colorscheme         ayu 'ayucolor=light'
#     obtain_kitty_theme_from_kitten 'Ayu Light'
#     change_kitty_theme             'Ayu Light'
#     ;;
#   "Ayu Mirage")
#     obtain_neovim_theme_from_git   ayu-vim git@github.com:ayu-theme/ayu-vim.git
#     change_vim_background          dark
#     change_vim_colorscheme         ayu 'ayucolor=mirage'
#     obtain_kitty_theme_from_kitten 'Ayu Mirage'
#     change_kitty_theme             'Ayu Mirage'
#     ;;
#   "Catppuccin Frappe")
#     obtain_neovim_theme_from_git catppuccin https://github.com/catppuccin/nvim.git
#     change_vim_background        dark
#     change_vim_colorscheme       catppuccin 'catppuccin_flavour=frappe'
#     obtain_kitty_theme_from_curl catppuccin_frappe https://raw.githubusercontent.com/catppuccin/kitty/main/themes/frappe.conf
#     change_kitty_theme           catppuccin_frappe
#     ;;
#   "Catppuccin Latte")
#     obtain_neovim_theme_from_git catppuccin https://github.com/catppuccin/nvim.git
#     change_vim_background        light
#     change_vim_colorscheme       catppuccin 'catppuccin_flavour=latte'
#     obtain_kitty_theme_from_curl catppuccin_latte https://raw.githubusercontent.com/catppuccin/kitty/main/themes/latte.conf
#     change_kitty_theme           catppuccin_latte
#     ;;
#   "Catppuccin Macchiato")
#     obtain_neovim_theme_from_git catppuccin https://github.com/catppuccin/nvim.git
#     change_vim_background        dark
#     change_vim_colorscheme       catppuccin 'catppuccin_flavour=macchiato'
#     obtain_kitty_theme_from_curl catppuccin_macchiato https://raw.githubusercontent.com/catppuccin/kitty/main/themes/macchiato.conf
#     change_kitty_theme           catppuccin_macchiato
#     ;;
#   "Catppuccin Mocha")
#     obtain_neovim_theme_from_git catppuccin https://github.com/catppuccin/nvim.git
#     change_vim_background        dark
#     change_vim_colorscheme       catppuccin 'catppuccin_flavour=mocha'
#     obtain_kitty_theme_from_curl catppuccin_mocha https://raw.githubusercontent.com/catppuccin/kitty/main/themes/mocha.conf
#     change_kitty_theme           catppuccin_mocha
#     ;;
#   "GitHub Dark")
#     obtain_neovim_theme_from_git   github-nvim-theme git@github.com:projekt0n/github-nvim-theme.git
#     change_vim_background          dark
#     change_vim_colorscheme         github_dark
#     obtain_kitty_theme_from_github github_dark
#     change_kitty_theme             github_dark
#     ;;
#   "GitHub Dark High Contrast")
#     obtain_neovim_theme_from_git   github-nvim-theme git@github.com:projekt0n/github-nvim-theme.git
#     change_vim_background          dark
#     change_vim_colorscheme         github_dark_high_contrast
#     obtain_kitty_theme_from_github github_dark_high_contrast
#     change_kitty_theme             github_dark_high_contrast
#     ;;
#   "GitHub Dark Colorblind")
#     obtain_neovim_theme_from_git   github-nvim-theme git@github.com:projekt0n/github-nvim-theme.git
#     change_vim_background          dark
#     change_vim_colorscheme         github_dark_colorblind
#     obtain_kitty_theme_from_github github_dark_colorblind
#     change_kitty_theme             github_dark_colorblind
#     ;;
#   "GitHub Dark Dimmed")
#     obtain_neovim_theme_from_git   github-nvim-theme git@github.com:projekt0n/github-nvim-theme.git
#     change_vim_background          dark
#     change_vim_colorscheme         github_dark_dimmed
#     obtain_kitty_theme_from_github github_dark_dimmed
#     change_kitty_theme             github_dark_dimmed
#     ;;
#   "GitHub Light")
#     obtain_neovim_theme_from_git   github-nvim-theme git@github.com:projekt0n/github-nvim-theme.git
#     change_vim_background          dark
#     change_vim_colorscheme         github_light
#     obtain_kitty_theme_from_github github_light
#     change_kitty_theme             github_light
#     ;;
#   "GitHub Light High Contrast")
#     obtain_neovim_theme_from_git   github-nvim-theme git@github.com:projekt0n/github-nvim-theme.git
#     change_vim_background          dark
#     change_vim_colorscheme         github_light_high_contrast
#     obtain_kitty_theme_from_github github_light_high_contrast
#     change_kitty_theme             github_light_high_contrast
#     ;;
#   "Gruvbox Dark")
#     obtain_neovim_theme_from_git   gruvbox git@github.com:morhetz/gruvbox.git
#     change_vim_background          dark
#     change_vim_colorscheme         gruvbox
#     obtain_kitty_theme_from_kitten 'Gruvbox Dark Hard'
#     change_kitty_theme             'Gruvbox Dark Hard'
#     ;;
#   "Gruvbox Light")
#     obtain_neovim_theme_from_git   gruvbox git@github.com:morhetz/gruvbox.git
#     change_vim_background          light
#     change_vim_colorscheme         gruvbox
#     obtain_kitty_theme_from_kitten 'Gruvbox Light Hard'
#     change_kitty_theme             'Gruvbox Light Hard'
#     ;;
#   "Gruvbox Material Dark Hard")
#     obtain_neovim_theme_from_git   gruvbox-material git@github.com:sainnhe/gruvbox-material.git
#     change_vim_background          dark
#     change_vim_colorscheme         gruvbox-material gruvbox_material_background=hard
#     obtain_kitty_theme_from_kitten 'Gruvbox Dark Hard'
#     change_kitty_theme             'Gruvbox Dark Hard'
#     ;;
#   "Gruvbox Material Dark Soft")
#     obtain_neovim_theme_from_git   gruvbox-material git@github.com:sainnhe/gruvbox-material.git
#     change_vim_background          dark
#     change_vim_colorscheme         gruvbox-material gruvbox_material_background=soft
#     obtain_kitty_theme_from_kitten 'Gruvbox Dark Soft'
#     change_kitty_theme             'Gruvbox Dark Soft'
#     ;;
#   "Gruvbox Material Light Hard")
#     obtain_neovim_theme_from_git   gruvbox-material git@github.com:sainnhe/gruvbox-material.git
#     change_vim_background          light
#     change_vim_colorscheme         gruvbox-material gruvbox_material_background=hard
#     obtain_kitty_theme_from_kitten 'Gruvbox Light Hard'
#     change_kitty_theme             'Gruvbox Light Hard'
#     ;;
#   "Gruvbox Material Light Soft")
#     obtain_neovim_theme_from_git   gruvbox-material git@github.com:sainnhe/gruvbox-material.git
#     change_vim_background          light
#     change_vim_colorscheme         gruvbox-material gruvbox_material_background=soft
#     obtain_kitty_theme_from_kitten 'Gruvbox Light Soft'
#     change_kitty_theme             'Gruvbox Light Soft'
#     ;;
#   "JetBrains Darcula (dark)")
#     obtain_neovim_theme_from_git   darcula-solid git@github.com:santos-gabriel-dario/darcula-solid.nvim.git
#     change_vim_background          dark
#     change_vim_colorscheme         darcula-solid
#     obtain_kitty_theme_from_kitten 'Jet Brains Darcula'
#     change_kitty_theme             'Jet Brains Darcula'
#     ;;
#   "Kanagawa Dragon (dark)")
#     obtain_neovim_theme_from_git kanagawa.nvim git@github.com:rebelot/kanagawa.nvim.git
#     change_vim_background        dark
#     change_vim_colorscheme       kanagawa-dragon
#     obtain_kitty_theme_from_curl 'Kanagawa Dragon' https://raw.githubusercontent.com/rebelot/kanagawa.nvim/master/extras/kanagawa_dragon.conf
#     change_kitty_theme           'Kanagawa Dragon'
#     ;;
#   "Kanagawa Lotus (light)")
#     obtain_neovim_theme_from_git kanagawa.nvim git@github.com:rebelot/kanagawa.nvim.git
#     change_vim_background        light
#     change_vim_colorscheme       kanagawa-lotus
#     obtain_kitty_theme_from_curl 'Kanagawa Lotus' https://raw.githubusercontent.com/rebelot/kanagawa.nvim/master/extras/kanagawa_light.conf
#     change_kitty_theme           'Kanagawa Lotus'
#     ;;
#   "Kanagawa Wave (dark)")
#     obtain_neovim_theme_from_git kanagawa.nvim git@github.com:rebelot/kanagawa.nvim.git
#     change_vim_background        dark
#     change_vim_colorscheme       kanagawa-wave
#     obtain_kitty_theme_from_curl 'Kanagawa Wave' https://raw.githubusercontent.com/rebelot/kanagawa.nvim/master/extras/kanagawa.conf
#     change_kitty_theme           'Kanagawa Wave'
#     ;;
#   "Neofusion (dark)")
#     obtain_neovim_theme_from_git neofusion.nvim https://github.com/diegoulloao/neofusion.nvim.git
#     change_vim_background        dark
#     change_vim_colorscheme       neofusion
#     obtain_kitty_theme_from_curl 'neofusion-dark' https://raw.githubusercontent.com/diegoulloao/neofusion.kitty/main/neofusion.conf
#     change_kitty_theme           'neofusion-dark'
#     ;;
#   "Nightfox Nightfox")
#     obtain_neovim_theme_from_git nightfox.nvim git@github.com:EdenEast/nightfox.nvim.git
#     change_vim_background        dark
#     change_vim_colorscheme       nightfox
#     obtain_kitty_theme_from_curl 'nightfox-nightfox' https://raw.githubusercontent.com/EdenEast/nightfox.nvim/main/extra/nightfox/nightfox_kitty.conf
#     change_kitty_theme           'nightfox-nightfox'
#     ;;
#   "Nightfox Carbonfox")
#     obtain_neovim_theme_from_git nightfox.nvim git@github.com:EdenEast/nightfox.nvim.git
#     change_vim_background        dark
#     change_vim_colorscheme       carbonfox
#     obtain_kitty_theme_from_curl 'nightfox-carbonfox' https://raw.githubusercontent.com/EdenEast/nightfox.nvim/main/extra/carbonfox/nightfox_kitty.conf
#     change_kitty_theme           'nightfox-carbonfox'
#     ;;
#   "Nightfox Dayfox")
#     obtain_neovim_theme_from_git nightfox.nvim git@github.com:EdenEast/nightfox.nvim.git
#     change_vim_background        dark
#     change_vim_colorscheme       dayfox
#     obtain_kitty_theme_from_curl 'nightfox-dayfox' https://raw.githubusercontent.com/EdenEast/nightfox.nvim/main/extra/dayfox/nightfox_kitty.conf
#     change_kitty_theme           'nightfox-dayfox'
#     ;;
#   "Nightfox Dawnfox")
#     obtain_neovim_theme_from_git nightfox.nvim git@github.com:EdenEast/nightfox.nvim.git
#     change_vim_background        dark
#     change_vim_colorscheme       dawnfox
#     obtain_kitty_theme_from_curl 'nightfox-dawnfox' https://raw.githubusercontent.com/EdenEast/nightfox.nvim/main/extra/dawnfox/nightfox_kitty.conf
#     change_kitty_theme           'nightfox-dawnfox'
#     ;;
#   "Nightfox Duskfox")
#     obtain_neovim_theme_from_git nightfox.nvim git@github.com:EdenEast/nightfox.nvim.git
#     change_vim_background        dark
#     change_vim_colorscheme       duskfox
#     obtain_kitty_theme_from_curl 'nightfox-duskfox' https://raw.githubusercontent.com/EdenEast/nightfox.nvim/main/extra/duskfox/nightfox_kitty.conf
#     change_kitty_theme           'nightfox-duskfox'
#     ;;
#   "Nightfox Nordfox")
#     obtain_neovim_theme_from_git nightfox.nvim git@github.com:EdenEast/nightfox.nvim.git
#     change_vim_background        dark
#     change_vim_colorscheme       nordfox
#     obtain_kitty_theme_from_curl 'nightfox-nordfox' https://raw.githubusercontent.com/EdenEast/nightfox.nvim/main/extra/nordfox/nightfox_kitty.conf
#     change_kitty_theme           'nightfox-nordfox'
#     ;;
#   "Nightfox Terafox")
#     obtain_neovim_theme_from_git nightfox.nvim git@github.com:EdenEast/nightfox.nvim.git
#     change_vim_background        dark
#     change_vim_colorscheme       terafox
#     obtain_kitty_theme_from_curl 'nightfox-terafox' https://raw.githubusercontent.com/EdenEast/nightfox.nvim/main/extra/terafox/nightfox_kitty.conf
#     change_kitty_theme           'nightfox-terafox'
#     ;;
#   "Nordic")
#     obtain_neovim_theme_from_git nordic.nvim git@github.com:AlexvZyl/nordic.nvim.git
#     change_vim_background        dark
#     change_vim_colorscheme       nordic
#     obtain_kitty_theme_from_curl 'nordic' https://raw.githubusercontent.com/AlexvZyl/nordic.nvim/refs/heads/main/platforms/kitty/nordic.conf
#     change_kitty_theme           'nordic'
#     ;;
#   "One Dark")
#     obtain_neovim_theme_from_git   onedark.vim git@github.com:joshdick/onedark.vim.git
#     change_vim_background          dark
#     change_vim_colorscheme         onedark
#     obtain_kitty_theme_from_kitten 'One Dark'
#     change_kitty_theme             'One Dark'
#     ;;
#   "One Light")
#     obtain_neovim_theme_from_git   vim-one git@github.com:rakr/vim-one.git
#     change_vim_background          light
#     change_vim_colorscheme         one
#     obtain_kitty_theme_from_kitten 'One Half Light'
#     change_kitty_theme             'One Half Light'
#     ;;
#   "Rose Pine")
#     obtain_neovim_theme_from_git   rose-pine git@github.com:rose-pine/neovim.git
#     change_vim_background          dark
#     change_vim_colorscheme         rose-pine
#     obtain_kitty_theme_from_curl   'Rose Pine' https://raw.githubusercontent.com/rose-pine/kitty/main/dist/rose-pine.conf
#     change_kitty_theme             'Rose Pine'
#     ;;
#   "Rose Pine Dawn")
#     obtain_neovim_theme_from_git   rose-pine git@github.com:rose-pine/neovim.git
#     change_vim_background          light
#     change_vim_colorscheme         rose-pine
#     obtain_kitty_theme_from_curl   'Rose Pine Dawn' https://raw.githubusercontent.com/rose-pine/kitty/main/dist/rose-pine-dawn.conf
#     change_kitty_theme             'Rose Pine Dawn'
#     ;;
#   # "Rose Pine Moon")
#   #   obtain_neovim_theme_from_git   rose-pine git@github.com:rose-pine/neovim.git
#   #   change_vim_background          dark 'dark_variant=moon'
#   #   change_vim_colorscheme         rose-pine
#   #   obtain_kitty_theme_from_curl   'Rose Pine Moon' https://raw.githubusercontent.com/rose-pine/kitty/main/dist/rose-pine-moon.conf
#   #   change_kitty_theme             'Rose Pine Moon'
#   #   ;;
#   "Seoul256 Dark")
#     obtain_neovim_theme_from_git seoul256.vim git@github.com:junegunn/seoul256.vim.git
#     change_vim_background        dark
#     change_vim_colorscheme       seoul256
#     obtain_kitty_theme_from_curl seoul256 https://raw.githubusercontent.com/malikbenkirane/kitty-colors/master/seoul256.kitty-conf
#     change_kitty_theme           seoul256
#     ;;
#   "Seoul256 Light")
#     obtain_neovim_theme_from_git seoul256.vim git@github.com:junegunn/seoul256.vim.git
#     change_vim_background        light
#     change_vim_colorscheme       seoul256-light
#     obtain_kitty_theme_from_curl seoul256-light https://raw.githubusercontent.com/malikbenkirane/kitty-colors/master/seoul256-light.kitty-conf
#     change_kitty_theme           seoul256-light
#     ;;
#   "TokyoNight Night")
#     obtain_neovim_theme_from_git   tokyonight.nvim git@github.com:folke/tokyonight.nvim.git
#     change_vim_background          dark
#     change_vim_colorscheme         tokyonight-night
#     obtain_kitty_theme_from_kitten 'Tokyo Night'
#     change_kitty_theme             "Tokyo Night"
#     ;;
#   "TokyoNight Day")
#     obtain_neovim_theme_from_git   tokyonight.nvim git@github.com:folke/tokyonight.nvim.git
#     change_vim_background          light
#     change_vim_colorscheme         tokyonight-day
#     obtain_kitty_theme_from_kitten 'Tokyo Night Day'
#     change_kitty_theme             "Tokyo Night Day"
#     ;;
#   "TokyoNight Moon")
#     obtain_neovim_theme_from_git   tokyonight.nvim git@github.com:folke/tokyonight.nvim.git
#     change_vim_background          dark
#     change_vim_colorscheme         tokyonight-moon
#     obtain_kitty_theme_from_kitten 'Tokyo Night Storm'
#     change_kitty_theme             "Tokyo Night Storm"
#     ;;
#   "TokyoNight Storm")
#     obtain_neovim_theme_from_git   tokyonight.nvim git@github.com:folke/tokyonight.nvim.git
#     change_vim_background          dark
#     change_vim_colorscheme         tokyonight-storm
#     obtain_kitty_theme_from_kitten 'Tokyo Night Moon'
#     change_kitty_theme             "Tokyo Night Moon"
#     ;;
#   "Zenbones Dark")
#     obtain_neovim_theme_from_git zenbones.nvim git@github.com:mcchrish/zenbones.nvim.git
#     change_vim_background        dark
#     change_vim_colorscheme       zenbones zenbones_compat=1
#     obtain_kitty_theme_from_curl zenbones-dark https://raw.githubusercontent.com/mcchrish/zenbones.nvim/main/extras/kitty/zenbones_dark.conf
#     change_kitty_theme           zenbones-dark
#     ;;
#   "Zenbones Light")
#     obtain_neovim_theme_from_git zenbones.nvim git@github.com:mcchrish/zenbones.nvim.git
#     change_vim_background        light
#     change_vim_colorscheme       zenbones zenbones_compat=1
#     obtain_kitty_theme_from_curl zenbones-light https://raw.githubusercontent.com/mcchrish/zenbones.nvim/main/extras/kitty/zenbones_light.conf
#     change_kitty_theme           zenbones-light
#     ;;
#   "Zenbones Zenwritten Dark")
#     obtain_neovim_theme_from_git zenbones.nvim git@github.com:mcchrish/zenbones.nvim.git
#     change_vim_background        dark
#     change_vim_colorscheme       zenwritten zenbones_compat=1
#     obtain_kitty_theme_from_curl zenbones-zenwritten-dark https://raw.githubusercontent.com/mcchrish/zenbones.nvim/main/extras/kitty/zenwritten_dark.conf
#     change_kitty_theme           zenbones-zenwritten-dark
#     echo TODO: zenbones requires the \'lush\' lua rock \(can be installed manually\)
#     ;;
#   "Zenbones Zenwritten Light")
#     obtain_neovim_theme_from_git zenbones.nvim git@github.com:mcchrish/zenbones.nvim.git
#     change_vim_background        light
#     change_vim_colorscheme       zenwritten zenbones_compat=1
#     obtain_kitty_theme_from_curl zenbones-zenwritten-light https://raw.githubusercontent.com/mcchrish/zenbones.nvim/main/extras/kitty/zenwritten_light.conf
#     change_kitty_theme           zenbones-zenwritten-light
#     echo TODO: zenbones requires the \'lush\' lua rock \(can be installed manually\)
#     ;;
#   "Zenbones Neobones Light")
#     obtain_neovim_theme_from_git zenbones.nvim git@github.com:mcchrish/zenbones.nvim.git
#     change_vim_background        light
#     change_vim_colorscheme       neobones zenbones_compat=1
#     obtain_kitty_theme_from_curl zenbones-neobones-light https://raw.githubusercontent.com/mcchrish/zenbones.nvim/main/extras/kitty/neobones_light.conf
#     change_kitty_theme           zenbones-neobones-light
#     echo TODO: zenbones requires the \'lush\' lua rock \(can be installed manually\)
#     ;;
#   "Zenbones Neobones Dark")
#     obtain_neovim_theme_from_git zenbones.nvim git@github.com:mcchrish/zenbones.nvim.git
#     change_vim_background        dark
#     change_vim_colorscheme       neobones zenbones_compat=1
#     obtain_kitty_theme_from_curl zenbones-neobones-dark https://raw.githubusercontent.com/mcchrish/zenbones.nvim/main/extras/kitty/neobones_dark.conf
#     change_kitty_theme           zenbones-neobones-dark
#     echo TODO: zenbones requires the \'lush\' lua rock \(can be installed manually\)
#     ;;
#   "Zenbones Seoulbones Light")
#     obtain_neovim_theme_from_git zenbones.nvim git@github.com:mcchrish/zenbones.nvim.git
#     change_vim_background        light
#     change_vim_colorscheme       seoulbones zenbones_compat=1
#     obtain_kitty_theme_from_curl zenbones-seoulbones-light https://raw.githubusercontent.com/mcchrish/zenbones.nvim/main/extras/kitty/seoulbones_light.conf
#     change_kitty_theme           zenbones-seoulbones-light
#     echo TODO: zenbones requires the \'lush\' lua rock \(can be installed manually\)
#     ;;
#   "Zenbones Seoulbones Dark")
#     obtain_neovim_theme_from_git zenbones.nvim git@github.com:mcchrish/zenbones.nvim.git
#     change_vim_background        dark
#     change_vim_colorscheme       seoulbones zenbones_compat=1
#     obtain_kitty_theme_from_curl zenbones-seoulbones-dark https://raw.githubusercontent.com/mcchrish/zenbones.nvim/main/extras/kitty/seoulbones_dark.conf
#     change_kitty_theme           zenbones-seoulbones-dark
#     echo TODO: zenbones requires the \'lush\' lua rock \(can be installed manually\)
#     ;;
#   *)
#     echo "\"$theme\" is not a recognized theme"
#     ;;
# esac
# if [[ -n "$KITTY_PID" ]]; then
#   kill -SIGUSR1 "$KITTY_PID"
# fi
