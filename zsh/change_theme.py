#!/usr/bin/env python3

# This script prompts for choice of theme and then configures vim and kitty to
# have matching themes.
#
# Additional Ghostty Setup
# =======================
#
# None.
#
# Additional Neovim Setup
# ====================
#
# 1. If the script doesn't see the theme plugins in your vimrc, it will
#    automatically download colorscheme plugins into vim's native plugin
#    directory:
#
#        git clone <theme-repo> ~/.nvim/pack/<theme>/start/<theme>
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

import subprocess
import sys
import fileinput
import re
from dataclasses import dataclass
from typing import Union, Literal
from os import path, environ, getenv
from collections import namedtuple

Url = namedtuple("Url", ["url"])
ThemeGhosttyName = namedtuple("Name", ["name"]) # TODO rename to ThemeGhosttyName

ThemeType = Union[Literal['light'], Literal['dark']]
@dataclass
class Theme:
  """
  "dark" or "light".

  Neovim's "background" is set to this value.
  """
  type: ThemeType
  """ Name displayed for selecting this theme. """
  name: str
  """ git remote url to neovim plugin repo. """
  neovim_repo: str
  """ directory name for downloaded plugin. """
  neovim_dir_name: str
  """ neovim's "colorscheme" is set to this value. """
  neovim_name: str
  neovim_global_vars: Union[str, None]
  ghostty_source: Union[ThemeGhosttyName]

themes = [

    Theme(name="Kanso Ink",              type="dark",  neovim_repo="git@github.com:webhooked/kanso.nvim.git",         neovim_dir_name="kanso.nvim",       neovim_name="kanso-ink",        neovim_global_vars=None,                                                                      ghostty_source=ThemeGhosttyName("Kanso Ink")),
    Theme(name="Kanso Mist",             type="dark",  neovim_repo="git@github.com:webhooked/kanso.nvim.git",         neovim_dir_name="kanso.nvim",       neovim_name="kanso-mist",       neovim_global_vars=None,                                                                      ghostty_source=ThemeGhosttyName("Kanso Mist")),
    Theme(name="Kanso Pearl",            type="light", neovim_repo="git@github.com:webhooked/kanso.nvim.git",         neovim_dir_name="kanso.nvim",       neovim_name="kanso-pearl",      neovim_global_vars=None,                                                                      ghostty_source=ThemeGhosttyName("Kanso Pearl")),
    Theme(name="Catppuccin Frappe",      type="dark",  neovim_repo="https://github.com/catppuccin/nvim.git",          neovim_dir_name="catppuccin",       neovim_name="catppuccin",       neovim_global_vars="catppuccin_flavour=frappe",                                               ghostty_source=ThemeGhosttyName("Catppuccin Frappe")),
    Theme(name="Catppuccin Latte",       type="light", neovim_repo="https://github.com/catppuccin/nvim.git",          neovim_dir_name="catppuccin",       neovim_name="catppuccin",       neovim_global_vars="catppuccin_flavour=latte",                                                ghostty_source=ThemeGhosttyName("Catppuccin Latte")),
    Theme(name="Catppuccin Macchiato",   type="dark",  neovim_repo="https://github.com/catppuccin/nvim.git",          neovim_dir_name="catppuccin",       neovim_name="catppuccin",       neovim_global_vars="catppuccin_flavour=macchiato",                                            ghostty_source=ThemeGhosttyName("Catppuccin Macchiato")),
    Theme(name="Catppuccin Mocha",       type="dark",  neovim_repo="https://github.com/catppuccin/nvim.git",          neovim_dir_name="catppuccin",       neovim_name="catppuccin",       neovim_global_vars="catppuccin_flavour=mocha",                                                ghostty_source=ThemeGhosttyName("Catppuccin Mocha")),
    Theme(name="Flexoki Light",          type="light", neovim_repo="git@github.com:kepano/flexoki-neovim.git",        neovim_dir_name="flexoki-neovim",   neovim_name="flexoki-light",    neovim_global_vars="",                                                                        ghostty_source=ThemeGhosttyName("Flexoki Light")),
    Theme(name="Flexoki Dark",           type="dark",  neovim_repo="git@github.com:kepano/flexoki-neovim.git",        neovim_dir_name="flexoki-neovim",   neovim_name="flexoki-dark",     neovim_global_vars="",                                                                        ghostty_source=ThemeGhosttyName("Flexoki Dark")),
    Theme(name="Kanagawa Dragon",        type="dark",  neovim_repo="git@github.com:rebelot/kanagawa.nvim.git",        neovim_dir_name="kanagawa.nvim",    neovim_name="kanagawa-dragon",  neovim_global_vars=None,                                                                      ghostty_source=ThemeGhosttyName("Kanagawa Dragon")),
    Theme(name="Kanagawa Lotus",         type="light", neovim_repo="git@github.com:rebelot/kanagawa.nvim.git",        neovim_dir_name="kanagawa.nvim",    neovim_name="kanagawa-lotus",   neovim_global_vars=None,                                                                      ghostty_source=ThemeGhosttyName("Kanagawa Lotus")),
    Theme(name="Kanagawa Wave",          type="dark",  neovim_repo="git@github.com:rebelot/kanagawa.nvim.git",        neovim_dir_name="kanagawa.nvim",    neovim_name="kanagawa-wave",    neovim_global_vars=None,                                                                      ghostty_source=ThemeGhosttyName("Kanagawa Wave")),
    Theme(name="Nord",                   type="dark",  neovim_repo="https://github.com/shaunsingh/nord.nvim.git",     neovim_dir_name="nord.nvim",        neovim_name="nord",             neovim_global_vars=None,                                                                      ghostty_source=ThemeGhosttyName("Nord")),
    Theme(name="Rose Pine Main",         type="dark",  neovim_repo="git@github.com:rose-pine/neovim.git",             neovim_dir_name="rose-pine",        neovim_name="rose-pine-main",   neovim_global_vars=None,                                                                      ghostty_source=ThemeGhosttyName("Rose Pine")),
    Theme(name="Rose Pine Moon",         type="dark",  neovim_repo="git@github.com:rose-pine/neovim.git",             neovim_dir_name="rose-pine",        neovim_name="rose-pine-moon",   neovim_global_vars=None,                                                                      ghostty_source=ThemeGhosttyName("Rose Pine Moon")),
    Theme(name="Rose Pine Dawn",         type="dark",  neovim_repo="git@github.com:rose-pine/neovim.git",             neovim_dir_name="rose-pine",        neovim_name="rose-pine-dawn",   neovim_global_vars=None,                                                                      ghostty_source=ThemeGhosttyName("Rose Pine Dawn")),
    Theme(name="Tokyo Night Day",        type="light", neovim_repo="git@github.com:folke/tokyonight.nvim",            neovim_dir_name="tokyonight.nvim",  neovim_name="tokyonight-day",   neovim_global_vars=None,                                                                      ghostty_source=ThemeGhosttyName("TokyoNight Day")),
    Theme(name="Tokyo Night Storm",      type="dark", neovim_repo="git@github.com:folke/tokyonight.nvim",             neovim_dir_name="tokyonight.nvim",  neovim_name="tokyonight-storm", neovim_global_vars=None,                                                                      ghostty_source=ThemeGhosttyName("TokyoNight Storm")),
    Theme(name="Tokyo Night Moon",       type="dark", neovim_repo="git@github.com:folke/tokyonight.nvim",             neovim_dir_name="tokyonight.nvim",  neovim_name="tokyonight-moon",  neovim_global_vars=None,                                                                      ghostty_source=ThemeGhosttyName("TokyoNight Moon")),
    Theme(name="Tokyo Night Night",      type="dark", neovim_repo="git@github.com:folke/tokyonight.nvim",             neovim_dir_name="tokyonight.nvim",  neovim_name="tokyonight-night", neovim_global_vars=None,                                                                      ghostty_source=ThemeGhosttyName("TokyoNight Night")),
    Theme(name="Gruvbox Dark",           type="dark",  neovim_repo="git@github.com:sainnhe/gruvbox-material.git",     neovim_dir_name="gruvbox-material", neovim_name="gruvbox-material", neovim_global_vars="gruvbox_material_background=medium,gruvbox_material_foreground=original", ghostty_source=ThemeGhosttyName("Gruvbox Dark")),
    Theme(name="Gruvbox Light",          type="light", neovim_repo="git@github.com:sainnhe/gruvbox-material.git",     neovim_dir_name="gruvbox-material", neovim_name="gruvbox-material", neovim_global_vars="gruvbox_material_background=medium,gruvbox_material_foreground=original", ghostty_source=ThemeGhosttyName("Gruvbox Light")),
    Theme(name="Gruvbox Material Dark",  type="dark",  neovim_repo="git@github.com:sainnhe/gruvbox-material.git",     neovim_dir_name="gruvbox-material", neovim_name="gruvbox-material", neovim_global_vars="gruvbox_material_background=medium,gruvbox_material_foreground=material", ghostty_source=ThemeGhosttyName("Gruvbox Material Dark")),
    Theme(name="Gruvbox Material Light", type="light", neovim_repo="git@github.com:sainnhe/gruvbox-material.git",     neovim_dir_name="gruvbox-material", neovim_name="gruvbox-material", neovim_global_vars="gruvbox_material_background=medium,gruvbox_material_foreground=material", ghostty_source=ThemeGhosttyName("Gruvbox Material Light")),
    Theme(name="Gruvbox Material",       type="dark",  neovim_repo="git@github.com:sainnhe/gruvbox-material.git",     neovim_dir_name="gruvbox-material", neovim_name="gruvbox-material", neovim_global_vars="gruvbox_material_background=hard,gruvbox_material_foreground=material",   ghostty_source=ThemeGhosttyName("Gruvbox Material")),
    Theme(name="Zenbones Dark",          type="dark",  neovim_repo="git@github.com:zenbones-theme/zenbones.nvim.git", neovim_dir_name="zenbones.nvim",    neovim_name="zenbones",         neovim_global_vars="zenbones_compat=1",                                                       ghostty_source=ThemeGhosttyName("Zenbones Dark")),

    # Theme(name="Ayu Dark",                    type="dark",  neovim_repo="git@github.com:ayu-theme/ayu-vim.git",                       neovim_dir_name="ayu-vim",          neovim_name="ayu",              neovim_global_vars=None,                               kitty_source=Name("Ayu")  ),
    # Theme(name="Ayu Light",                   type="light", neovim_repo="git@github.com:ayu-theme/ayu-vim.git",                       neovim_dir_name="ayu-vim",          neovim_name="ayu",              neovim_global_vars="ayucolor=light",                   kitty_source=Name("Ayu Light"),                                                                                         kitty_name="Ayu Light"  ),
    # Theme(name="Ayu Mirage",                  type="dark",  neovim_repo="git@github.com:ayu-theme/ayu-vim.git",                       neovim_dir_name="ayu-vim",          neovim_name="ayu",              neovim_global_vars="ayucolor=mirage",                  kitty_source=Name("Ayu Mirage"),                                                                                        kitty_name="Ayu Mirage" ),
    # Theme(name="Gruvbox Material Dark Hard",  type="dark",  neovim_repo="git@github.com:sainnhe/gruvbox-material.git",                neovim_dir_name="gruvbox-material", neovim_name="gruvbox-material", neovim_global_vars="gruvbox_material_background=hard", kitty_source=Name("Gruvbox Dark Hard"),                                                                                 kitty_name="Gruvbox Dark Hard" ),
    # Theme(name="Gruvbox Material Dark Soft",  type="dark",  neovim_repo="git@github.com:sainnhe/gruvbox-material.git",                neovim_dir_name="gruvbox-material", neovim_name="gruvbox-material", neovim_global_vars="gruvbox_material_background=hard", kitty_source=Name("Gruvbox Dark Soft"),                                                                                 kitty_name="Gruvbox Dark Soft" ),
    # Theme(name="Gruvbox Material Light Hard", type="light", neovim_repo="git@github.com:sainnhe/gruvbox-material.git",                neovim_dir_name="gruvbox-material", neovim_name="gruvbox-material", neovim_global_vars="gruvbox_material_background=hard", kitty_source=Name("Gruvbox Light Hard"),                                                                                kitty_name="Gruvbox Light Hard" ),
    # Theme(name="Gruvbox Material Light Soft", type="light", neovim_repo="git@github.com:sainnhe/gruvbox-material.git",                neovim_dir_name="gruvbox-material", neovim_name="gruvbox-material", neovim_global_vars="gruvbox_material_background=hard", kitty_source=Name("Gruvbox Light Soft"),                                                                                kitty_name="Gruvbox Light Soft" ),
    # Theme(name="JetBrains Darcula",           type="dark",  neovim_repo="git@github.com:santos-gabriel-dario/darcula-solid.nvim.git", neovim_dir_name="darcula-solid",    neovim_name="darcula",          neovim_global_vars=None,                               kitty_source=Name("Jet Brains Darcula"),                                                                                kitty_name="Jet Brains Darcula" ),
    # Theme(name="Nightfox Nightfox",           type="dark",  neovim_repo="git@github.com:EdenEast/nightfox.nvim.git",                  neovim_dir_name="nightfox.nvim",    neovim_name="nightfox",         neovim_global_vars=None,                               kitty_source=Url("https://raw.githubusercontent.com/EdenEast/nightfox.nvim/main/extra/nightfox/nightfox_kitty.conf"),   kitty_name="nightfox-nightfox" ),
    # Theme(name="Nightfox Carbonfox",          type="dark",  neovim_repo="git@github.com:EdenEast/nightfox.nvim.git",                  neovim_dir_name="nightfox.nvim",    neovim_name="carbonfox",        neovim_global_vars=None,                               kitty_source=Url("https://raw.githubusercontent.com/EdenEast/nightfox.nvim/main/extra/carbonfox/nightfox_kitty.conf"),  kitty_name="nightfox-carbonfox" ),
    # Theme(name="Nightfox Dayfox",             type="dark",  neovim_repo="git@github.com:EdenEast/nightfox.nvim.git",                  neovim_dir_name="nightfox.nvim",    neovim_name="dayfox",           neovim_global_vars=None,                               kitty_source=Url("https://raw.githubusercontent.com/EdenEast/nightfox.nvim/main/extra/dayfox/nightfox_kitty.conf"),     kitty_name="nightfox-dayfox" ),
    # Theme(name="Nightfox Dawnfox",            type="dark",  neovim_repo="git@github.com:EdenEast/nightfox.nvim.git",                  neovim_dir_name="nightfox.nvim",    neovim_name="dawnfox",          neovim_global_vars=None,                               kitty_source=Url("https://raw.githubusercontent.com/EdenEast/nightfox.nvim/main/extra/dawnfox/nightfox_kitty.conf"),    kitty_name="nightfox-dawnfox" ),
    # Theme(name="Nightfox Duskfox",            type="dark",  neovim_repo="git@github.com:EdenEast/nightfox.nvim.git",                  neovim_dir_name="nightfox.nvim",    neovim_name="duskfox",          neovim_global_vars=None,                               kitty_source=Url("https://raw.githubusercontent.com/EdenEast/nightfox.nvim/main/extra/duskfox/nightfox_kitty.conf"),    kitty_name="nightfox-duskfox" ),
    # Theme(name="Nightfox Nordfox",            type="dark",  neovim_repo="git@github.com:EdenEast/nightfox.nvim.git",                  neovim_dir_name="nightfox.nvim",    neovim_name="nordfox",          neovim_global_vars=None,                               kitty_source=Url("https://raw.githubusercontent.com/EdenEast/nightfox.nvim/main/extra/nordfox/nightfox_kitty.conf"),    kitty_name="nightfox-nordfox" ),
    # Theme(name="Nightfox Terafox",            type="dark",  neovim_repo="git@github.com:EdenEast/nightfox.nvim.git",                  neovim_dir_name="nightfox.nvim",    neovim_name="terafox",          neovim_global_vars=None,                               kitty_source=Url("https://raw.githubusercontent.com/EdenEast/nightfox.nvim/main/extra/terafox/nightfox_kitty.conf"),    kitty_name="nightfox-terafox" ),
    # Theme(name="Nordic",                      type="dark",  neovim_repo="git@github.com:AlexvZyl/nordic.nvim.git",                    neovim_dir_name="nordic.nvim",      neovim_name="nordic",           neovim_global_vars=None,                               kitty_source=Url("https://raw.githubusercontent.com/AlexvZyl/nordic.nvim/refs/heads/main/platforms/kitty/nordic.conf"), kitty_name="nordic" ),
    # Theme(name="One Dark",                    type="dark",  neovim_repo="git@github.com:joshdick/onedark.vim.git",                    neovim_dir_name="onedark.vim",      neovim_name="onedark",          neovim_global_vars=None,                               kitty_source=Name("One Dark"),                                                                                          kitty_name=("One Dark") ),
    # Theme(name="One Light",                   type="light", neovim_repo="git@github.com:rakr/vim-one.git",                            neovim_dir_name="vim-one",          neovim_name="one",              neovim_global_vars=None,                               kitty_source=Name("One Half Light"),                                                                                    kitty_name=("One Half Light") ),
    # # Theme(name="Rose Pine",                   type="dark",  neovim_repo="git@github.com:rose-pine/neovim.git",                        neovim_dir_name="rose-pine",        neovim_name="rose-pine",        neovim_global_vars=None,                               ),
    # # Theme(name="Rose Pine Dawn",              type="light", neovim_repo="git@github.com:rose-pine/neovim.git",                        neovim_dir_name="rose-pine",        neovim_name="rose-pine",        neovim_global_vars=None,                               ),
    # Theme(name="Seoul256 Dark",               type="dark",  neovim_repo="git@github.com:junegunn/seoul256.vim.git",                   neovim_dir_name="seoul256.vim",     neovim_name="seoul256",         neovim_global_vars=None,                               kitty_source=Url("https://raw.githubusercontent.com/malikbenkirane/kitty-colors/master/seoul256.kitty-conf"),           kitty_name="seoul256" ),
    # Theme(name="Seoul256 Light",              type="light", neovim_repo="git@github.com:junegunn/seoul256.vim.git",                   neovim_dir_name="seoul256.vim",     neovim_name="seoul256-light",   neovim_global_vars=None,                               kitty_source=Url("https://raw.githubusercontent.com/malikbenkirane/kitty-colors/master/seoul256-light.kitty-conf"),     kitty_name="seoul256-light" ),
    # Theme(name="TokyoNight Night",            type="dark",  neovim_repo="git@github.com:folke/tokyonight.nvim.git",                   neovim_dir_name="tokyonight.nvim",  neovim_name="tokyonight-night", neovim_global_vars=None,                               kitty_source=Name("Tokyo Night"),                                                                                       kitty_name=("Tokyo Night") ),
    # Theme(name="TokyoNight Day",              type="light", neovim_repo="git@github.com:folke/tokyonight.nvim.git",                   neovim_dir_name="tokyonight.nvim",  neovim_name="tokyonight-day",   neovim_global_vars=None,                               kitty_source=Name("Tokyo Night Day"),                                                                                   kitty_name=("Tokyo Night Day") ),
    # Theme(name="TokyoNight Moon",             type="dark",  neovim_repo="git@github.com:folke/tokyonight.nvim.git",                   neovim_dir_name="tokyonight.nvim",  neovim_name="tokyonight-moon",  neovim_global_vars=None,                               kitty_source=Name("Tokyo Night Storm"),                                                                                 kitty_name=("Tokyo Night Storm") ),
    # Theme(name="TokyoNight Storm",            type="dark",  neovim_repo="git@github.com:folke/tokyonight.nvim.git",                   neovim_dir_name="tokyonight.nvim",  neovim_name="tokyonight-storm", neovim_global_vars=None,                               kitty_source=Name("Tokyo Night Moon"),                                                                                  kitty_name=("Tokyo Night Moon") ),
    # Theme(name="Zenbones Dark",               type="dark",  neovim_repo="git@github.com:mcchrish/zenbones.nvim.git",                  neovim_dir_name="zenbones.nvim",    neovim_name="zenbones",         neovim_global_vars="zenbones_compat=1",                kitty_source=Url("https://raw.githubusercontent.com/mcchrish/zenbones.nvim/main/extras/kitty/zenbones_dark.conf"),      kitty_name="zenbones-dark" ),
    # Theme(name="Zenbones Light",              type="light", neovim_repo="git@github.com:mcchrish/zenbones.nvim.git",                  neovim_dir_name="zenbones.nvim",    neovim_name="zenbones",         neovim_global_vars="zenbones_compat=1",                kitty_source=Url("https://raw.githubusercontent.com/mcchrish/zenbones.nvim/main/extras/kitty/zenbones_light.conf"),     kitty_name="zenbones-light" ),
    # Theme(name="Zenbones Neobones Dark",      type="dark",  neovim_repo="git@github.com:mcchrish/zenbones.nvim.git",                  neovim_dir_name="zenbones.nvim",    neovim_name="neobones",         neovim_global_vars="zenbones_compat=1",                kitty_source=Url("https://raw.githubusercontent.com/mcchrish/zenbones.nvim/main/extras/kitty/neobones_dark.conf"),      kitty_name="zenbones-neobones-dark" ),
    # Theme(name="Zenbones Neobones Light",     type="light", neovim_repo="git@github.com:mcchrish/zenbones.nvim.git",                  neovim_dir_name="zenbones.nvim",    neovim_name="neobones",         neovim_global_vars="zenbones_compat=1",                kitty_source=Url("https://raw.githubusercontent.com/mcchrish/zenbones.nvim/main/extras/kitty/neobones_light.conf"),     kitty_name="zenbones-neobones-light" ),
    # Theme(name="Zenbones Seoulbones Dark",    type="dark",  neovim_repo="git@github.com:mcchrish/zenbones.nvim.git",                  neovim_dir_name="zenbones.nvim",    neovim_name="seoulbones",       neovim_global_vars="zenbones_compat=1",                kitty_source=Url("https://raw.githubusercontent.com/mcchrish/zenbones.nvim/main/extras/kitty/seoulbones_dark.conf"),    kitty_name="zenbones-seoulbones-dark" ),
    # Theme(name="Zenbones Seoulbones Light",   type="light", neovim_repo="git@github.com:mcchrish/zenbones.nvim.git",                  neovim_dir_name="zenbones.nvim",    neovim_name="seoulbones",       neovim_global_vars="zenbones_compat=1",                kitty_source=Url("https://raw.githubusercontent.com/mcchrish/zenbones.nvim/main/extras/kitty/seoulbones_light.conf"),   kitty_name="zenbones-seoulbones-light" ),
    # Theme(name="Zenbones Zenwritten Dark",    type="dark",  neovim_repo="git@github.com:mcchrish/zenbones.nvim.git",                  neovim_dir_name="zenbones.nvim",    neovim_name="zenwritten",       neovim_global_vars="zenbones_compat=1",                kitty_source=Url("https://raw.githubusercontent.com/mcchrish/zenbones.nvim/main/extras/kitty/zenwritten_dark.conf"),    kitty_name="zenbones-zenwritten-dark" ),
    # Theme(name="Zenbones Zenwritten Light",   type="light", neovim_repo="git@github.com:mcchrish/zenbones.nvim.git",                  neovim_dir_name="zenbones.nvim",    neovim_name="zenwritten",       neovim_global_vars="zenbones_compat=1",                kitty_source=Url("https://raw.githubusercontent.com/mcchrish/zenbones.nvim/main/extras/kitty/zenwritten_light.conf"),   kitty_name="zenbones-zenwritten-light" ),
    ]

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
    # print("LINES START")
    # print(file_content)
    # print("LINES END")
    pattern = re.compile(rf"{start_pattern}.*?{end_pattern}", re.DOTALL)
    new_content=re.sub(pattern, f"{start_pattern}\n{replacement}\n{end_pattern}\n", file_content)
    with open(path.expanduser(file), 'w') as fw:
      # print('NEW CONTENT')
      # print(new_content)
      # print('^^^^')
      fw.write(new_content)

fzf_result = subprocess.run(args=["fzf", "--border=rounded", "--prompt='Choose a Theme: '"], input="\n".join(t.name for t in themes), text=True, capture_output=True)

if fzf_result.returncode != 0:
  exit(fzf_result.returncode)

theme = next(t for t in themes if t.name == fzf_result.stdout.strip())

print("Procuring neovim theme")
def procure_neovim_theme():
  expected_path = path.expanduser(f"~/.config/nvim/pack/{theme.neovim_dir_name}/start/{theme.neovim_dir_name}")
  if path.isdir(path.expanduser(f"~/.config/nvim/pack/{theme.neovim_dir_name}/start/{theme.neovim_dir_name}")):
    print(f"  Found {theme.neovim_dir_name} in {expected_path}")
  else:
    print("Obtaining neovim theme from git repo")
    subprocess.run(["git", "clone", theme.neovim_repo, expected_path])
procure_neovim_theme()

print(f"Updating ~/.zshenv with colorscheme={theme.neovim_name} type={theme.type}")
replace_or_add_line("~/.zshenv", "^export VIM_BACKGROUND=.*",    f"export VIM_BACKGROUND={theme.type}")
replace_or_add_line("~/.zshenv", "^export VIM_COLORSCHEME=.*",   f"export VIM_COLORSCHEME={theme.neovim_name}")
replace_or_add_line("~/.zshenv", "^export VIM_THEME_GLOBALS=.*", f"export VIM_THEME_GLOBALS='{'' if theme.neovim_global_vars is None else theme.neovim_global_vars}'")

print(f"Updating ~/.config/ghostty/config with \"{theme.ghostty_source.name}\"")
replace_or_add_lines(
    file="~/.config/ghostty/config",
    start_pattern="# begin auto-generated ghostty theme setting",
    end_pattern="# end auto-generated ghostty theme setting",
    replacement=f"theme = {theme.ghostty_source.name}"
)

