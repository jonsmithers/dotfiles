# mix default and vim keybindings
function fish_hybrid_bindings
  for mode in default insert visual
    fish_default_key_bindings -M $mode
  end
  fish_vi_key_bindings --no-erase
end
set -g fish_key_bindings fish_hybrid_bindings

function init_echo
  # echo $argv
end

set fish_greeting ""

# simple filesystem navigation
  # http://jeroenjanssens.com/2013/08/16/quickly-navigate-your-filesystem-from-the-command-line.html
set MARKPATH $HOME/.marks
function oldjump
  cd "$MARKPATH/$argv"; or echo No such mark $argv;
end
function mark
  mkdir -p "$MARKPATH"; ln -s (pwd) "$MARKPATH/$argv";
end
function unmark
  rm -i "$MARKPATH/$argv[1]"
end

switch (uname)
  case Darwin
    init_echo "Mac init"
    function marks
      ls -l "$MARKPATH" | tail -n +2 | sed 's/  / /g' | cut -d' ' -f9- | awk -F ' -> ' '{printf "%-10s -> %s\n", $1, $2}'
    end
    alias chrome="/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome"
    alias tmux="env TERM=screen-256color-bce tmux" # for vim inside tmux https://stackoverflow.com/questions/10158508/lose-vim-colorscheme-in-tmux-mode
    set TERM 'xterm-256color'
  case Linux
    init_echo "Linux init"
    function marks
        ls -l "$MARKPATH" | sed 's/  / /g' | cut -d' ' -f9- | sed 's/ -/  -/g'; and echo
    end

    alias open="xdg-open"
    alias pbcopy='xsel --clipboard --input'
    alias pbpaste='xsel --clipboard --output'
end
switch (hostname)
  case asus-zenbook
    init_echo "asus init"
    set PATH ~/.npm-global/bin $PATH # npm config set prefix '~/.npm-global'
    set PATH /var/lib/snapd/snap/bin/ $PATH # add snap binaries to path
    alias vim='gvim -v' # for clipboard support

    alias journal="gnome-terminal --command='wordsafe push /home/smithers/Dropbox/2-backup/journal__VeryImportant/journal --prepend-date-quietly' --full-screen --hide-menubar"
    alias morning="gnome-terminal --command='wordsafe push /home/smithers/Dropbox/2-backup/journal__VeryImportant/morning --prepend-date-quietly' --full-screen --hide-menubar"
  case zamperini4
    init_echo "zamperini4 init"
    alias jl='jump l'
    alias jt='jump t'
    alias jm='jump m'
    alias journal="gnome-terminal --command='wordsafe push /home/smithers/Dropbox/2-backup/journal__VeryImportant/journal --prepend-date-loudly'  --full-screen --hide-menubar"
    alias morning="gnome-terminal --command='wordsafe push /home/smithers/Dropbox/2-backup/journal__VeryImportant/morning --prepend-date-quietly' --full-screen --hide-menubar"
    #alias journal="guake -t; gnome-terminal --command='wordsafe j' --full-screen --hide-menubar"
    export TMPDIR="/tmp/" # not sure why this suddenly became necessary
    set PATH /usr/local/go/bin $PATH
    set PATH /home/smithers/.linuxbrew/sbin $PATH
    set PATH /home/smithers/.linuxbrew/bin $PATH
    set XDG_DATA_DIRS /home/smithers/.linuxbrew/share:$XDG_DATA_DIRS
  case zamperini3
    init_echo "zamperini3 init"
    alias jl='jump l'
    alias jt='jump t'
    alias jm='jump m'
    alias vim='nvim'
    alias journal="gnome-terminal --command='wordsafe j' --full-screen --hide-menubar"
    #alias journal="guake -t; gnome-terminal --command='wordsafe j' --full-screen --hide-menubar"
    alias lamemp3='lame -V0 -h -b 160 --vbr-new'
    #wordsafe -E "nvim -c Goyo -c WM -c 'set nofoldenable'"
    #wordsafe -E "nvim -c Goyo -c WM -c 'set nofoldenable' + -c 'normal o' -c 'normal o\t' -c 'normal o' -c 'normal o' -c 'normal zt' +startinsert"

    set NODEJS_HOME /usr/lib/nodejs/node-v6.6.0
    set PATH $NODEJS_HOME/bin $PATH    # because node and npm are here
    set PATH ~/.npm-packages/bin $PATH # because ~/.npmrc has: "prefix = ${HOME}/.npm-packages"
    set PATH /usr/local/go/bin $PATH
    set -x GOPATH ~/go-workspace

  case zamperini2
    init_echo "bash_profile: zamperini2 init"
    alias journal="guake -t; gnome-terminal --command='wordsafe j' --title='Journal' --full-screen --hide-menubar"

    alias vim='nvim'
    alias tourweb='open https://github.com/jonsmithers/TourApp'

    alias lamemp3='lame -V0 -h -b 160 --vbr-new'

    set PATH /usr/local/go/bin/ $PATH
    set PATH /home/smithers/.gopath/bin $PATH
    set -x GOPATH /home/smithers/.gopath

  case Smithers.local
    init_echo "Work Lappy init"

    # get gradle completion behavior on gw
    complete --command gw --wraps gradle

    source ~/bin/work_stuff.fish

    function movtogif
      if [ "2" = (count $argv) ]
        ffmpeg  -i $argv[1] -s $argv[2] -pix_fmt rgb24 -r 10 -f gif - | gifsicle --optimize=3 --delay=10
      else
        echo "movtogif FILE.mov AxB > OUTPUT.gif"
      end
    end

    # iterm2 integration
    test -e {$HOME}/.iterm2_shell_integration.fish ; and source {$HOME}/.iterm2_shell_integration.fish

    # init rbenv
    status --is-interactive; and source (rbenv init -|psub)

    # shortcut in case I need bash
    alias bash='bash --init-file ~/.bash_startup'

    export GOPATH=/Users/smithers/gocode
    function setjavaversion
        switch $argv[1]
        case "7"
            export JAVA_HOME=/Library/Java/JavaVirtualMachines/jdk1.7.0_72.jdk/Contents/Home/
        case "8"
            export JAVA_HOME=/Library/Java/JavaVirtualMachines/jdk1.8.0_131.jdk/Contents/Home
        case "*"
            echo "can't handle input" $argv[1]
        end
    end
    setjavaversion 8
    export CLICOLOR=1
    export LSCOLORS="Gxfxcxdxbxegedabagacad"

    function sfailp
      echo -e "\e[0;31muh oh!"
      noti -p -t "Failure" -m "Something went wrong."
      # mplayer -msglevel all=-1 "/Applications/iMovie.app/Contents/Resources/iMovie Sound Effects/Crowd Boo.mp3"
      return 1
    end
    function sdonep
      echo -e "\e[0;36myus!"
      noti -p -t "Success" -m "It worked!"
      # mplayer -msglevel all=-1 "/Applications/Wunderlist.app/Contents/Resources/WLCompletionSound.mp3"
    end
    function sfail
      echo -e "\e[0;31muh oh!"
      noti -t "Failure" -m "Something went wrong."
      # mplayer -msglevel all=-1 "/Applications/iMovie.app/Contents/Resources/iMovie Sound Effects/Crowd Boo.mp3"
      return 1
    end
    function sdone
      echo -e "\e[0;36myus!"
      noti -t "Success" -m "It worked!"
      # mplayer -msglevel all=-1 "/Applications/Wunderlist.app/Contents/Resources/WLCompletionSound.mp3"
    end
    function notify
      getLastExitStatus; and sdone; or sfail
    end
    function notifyp
      getLastExitStatus; and sdonep; or sfailp
    end
    alias n='notify'
    alias np='notifyp'
    function getLastExitStatus
      return $status
    end
    function subl
      "/Applications/Sublime Text.app/Contents/SharedSupport/bin/subl" $argv
    end
  case '*'
    echo No machine installation for (hostname)
end

# global functions
if command -v git-number > /dev/null
  alias g='git number'
  function giff
    git-number -c vim $argv[1] +Gvdiff
  end
  if command -v gvim > /dev/null
    alias gim='git-number -c gvim -v'
  else
    alias gim='git-number -c vim'
  end
  function gd
    echo "cd "(dirname (git list $argv[1]))
    cd (dirname (git list $argv[1]))
  end
end
if command -v fzf > /dev/null
  alias fd="cd (find . -type d | fzf)"
  alias fzfp='fzf --preview "head --lines=40 {}"'
  if command -v lpass > /dev/null
    function laspas
      if not lpass status
        lpass login spambox.js@gmail.com
      end
      lpass show -c --password (lpass ls | fzf | awk '{print $(NF)}' | sed 's/\]//g')
    end
  end
else
  echo "(consider installing fzf)"
end
alias deletemergedbranches='git branch --merged | grep -v "\*" | grep -v \' master$\' | grep -v \' dev$\' | xargs -n 1 git branch -d'
alias installgitcommithook='curl https://raw.githubusercontent.com/jonsmithers/git-commit-prepender/dev/prepare-commit-msg > ./.git/hooks/prepare-commit-msg'
alias doge='echo "DOGE HERE. MUCH BASH. SUCH TERMINAL"'
alias ll='ls -lhAS'
if command -v wget > /dev/null
  function spottydownload
    # let's you download a file over a spotty connection.
    wget --continue --progress=dot:mega --tries=0 $argv
  end
end
alias killallscreens='screen -ls | grep Detached | cut -d. -f1 | xargs kill'
alias killalljava='ps -ef | grep java | grep -v grep | tr -s " " | cut -d" " -f3 | xargs kill'
function gitDaemon
  echo "check that your git port is open (9418)"
  echo "    nmap localhost"
  echo
  echo "share your ip"
  echo "    ifconfig | grep 192"
  echo
  echo "clone from other machine"
  echo "    git clone git://[IP-ADDRESS]/"
  echo "    git remote add smithers git://[IP-ADDRESS]/"
  git daemon --export-all --base-path=.
end
if command -v rg > /dev/null
  set -x FZF_DEFAULT_COMMAND 'rg -g "!dist" -g "!jmeter" -g "!*min.js" --files'
  set -x FZF_CTRL_T_COMMAND 'rg --files'
else
  echo "(consider installing rg)"
end
function encrypt
  openssl aes-256-cbc -a -salt -in "$argv[1]" -out "$argv[2]"
end
function decrypt
  openssl aes-256-cbc -d -a -in "$argv[1]" -out "$argv[2]"
end
if command -v tmux > /dev/null
  function tsh -d "Get a tmux session, preferably an existing one"
    if test 'new' = "$argv[1]"
      if tmux ls
        tmux attach \; new-window \; send-keys "cd "(pwd) \; send-keys Enter
      else
        tmux new-session          \; send-keys "cd "(pwd) \; send-keys Enter
      end
    else if test 'help' = "$argv[1]"
      echo "\
      USAGE:

      tsh
      Attach to existing session or create a new one if none exists

      tsh new
      Create new session in current working directory"
      return
    else
      # attach to existing session or create one
      tmux a; or tmux
    end
  end
end

# make binaries at ~/bin available as commands
if test -d ~/bin
  set PATH ~/bin $PATH
end

# initialize jump if available
if command -v jump > /dev/null
  status --is-interactive; and source (jump shell fish | psub)
end

# initialize autojump (if available)
# [ -f /usr/share/autojump/autojump.fish ]; and source /usr/share/autojump/autojump.fish
# for path in /usr/local/Cellar/autojump/*/share/autojump/autojump.fish # "for" allows me to execute a glob that might not match anything
#   source $path; and break
# end

# initialize direnv (if available)
if command -v direnv > /dev/null
  eval (direnv hook fish)
end

# aws completion https://github.com/aws/aws-cli/issues/1079#issuecomment-242923826
if command -v aws > /dev/null
  complete --command aws --no-files --arguments '(begin; set --local --export COMP_SHELL fish; set --local --export COMP_LINE (commandline); aws_completer | sed \'s/ $//\'; end)'
end
