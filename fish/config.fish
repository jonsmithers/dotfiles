function fish_hybrid_bindings
  for mode in default insert visual
    fish_default_key_bindings -M $mode
  end
  fish_vi_key_bindings --no-erase
end
set -g fish_key_bindings fish_hybrid_bindings

export NOTI_PUSHBULLET_ACCESSTOKEN=o.5RKGbICfF91y9S6zifyMPs6YTLdM0tdp

function init_echo
  # echo $argv
end

function fish_title
    # user can set "use_title" to override default title
    set resulting_title $use_title $_
    echo $resulting_title[1]
end

set fish_greeting ""
# function fish_greeting
#  set -l cows_dir /usr/local/Cellar/cowsay/3.04/share/cows
#        set -l perms (ls $cows_dir/*.cow | gshuf -n1)
#        echo $perms
#  set -l avatar (ls $cows_dir | gshuf -n1|cut -d'.' -f1)
#  echo $avatar
#  cowsay -f $avatar 'Le chat miaule, what should I do?'
#end

# temporary experimental stuff
  function disable_vi_mode
    set -g fish_key_bindings fish_default_key_bindings
  end
  function powerline
    function fish_prompt
      ~/git/powerline-shell/powerline-shell.py $status --shell bare ^/dev/null --cwd-max-depth 1 --cwd-mode dironly --mode patched
    end
  end

  function fish_mode_prompt # erase this function because I want to display mode in right prompt
  end

# Filesystem navigation
  # http://jeroenjanssens.com/2013/08/16/quickly-navigate-your-filesystem-from-the-command-line.html
  export MARKPATH=$HOME/.marks
  function jump
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
      alias dropthebass="osascript -e 'set volume 10'"
      alias stfu="osascript -e 'set volume output muted true'"
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

      function download
        # let's you download a file over a spotty connection.
        # wget not available on Mac, and I think curl works pretty well
        wget --continue --progress=dot:mega --tries=0 "$1"
      end
  end
  switch (hostname)
    case asus-zenbook
      init_echo "asus init"
      set PATH ~/.npm-global/bin $PATH # npm config set prefix '~/.npm-global'
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
      alias ja='jump a'
      alias jab='jump ab'
      alias jaj='jump aj'
      alias jajb='jump ajb'
      alias ju='jump uc2'
      alias juj='jump uc2js'
      alias asma='jump asma'
      alias uc2='jump uc2'
      alias leaf='jump leaf'
      alias tomcat='~/programs/runBranch.sh'
      alias debugmeteor="env NODE_OPTIONS='--debug' meteor run"
      alias slatetail='tail -f /var/log/system.log | grep --line-buffered "Slate" | sed "s/.*.local Slate\[[0-9]*\]:/> /"'
      alias wfs='/Users/smithers/git/UC2/uc2-app/support/scripts/waitForServer.js'
      alias bumble='mount_smbfs -N //guest:@(cat ~/.config/.ip_bumble)/FileShare ~/FileShare'

      function uc2b
        echo (wfs; and ~/bin/browseUc2) &
      end

      function copyIP
        ifconfig | grep 192 | sed -E 's/.*inet ([0-9.]+).*/http:\/\/\1:7770\/dist\//' | pbcopy
        echo 'copied '(pbpaste)
      end

      function killMicrosoft
        kill (ps -ef | grep Microsoft\ Database | tr -s ' ' | cut -d' ' -f 3)
        kill (ps -ef | grep Microsoft\ Outlook | tr -s ' ' | cut -d' ' -f 3)
        kill (ps -ef | grep Microsoft\ Alerts | tr -s ' ' | cut -d' ' -f 3)
        kill (ps -ef | grep Microsoft\ AU | tr -s ' ' | cut -d' ' -f 3)
        open "https://qpm.leidos.com/"
      end

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

if test -d ~/bin
  set PATH ~/bin $PATH
end

# global aliases
  alias g='git number'
  alias gn='git number'
  alias gim='g -c vim'
  alias deletemergedbranches='git branch --merged | grep -v "\*" | grep -v \' master$\' | grep -v \' dev$\' | xargs -n 1 git branch -d'
  alias installgitcommithook='curl https://raw.githubusercontent.com/jonsmithers/git-commit-prepender/dev/prepare-commit-msg > ./.git/hooks/prepare-commit-msg'
  alias gatom='g -c atom'
  alias todos='agl "(TODO|todo).*(([sS](mithers|MITHERS))|JJS|jjs)" -A 2 -B 2'
  alias todosgrep='git grep -I --ignore-case -E "todo.*(smithers|JJS)"'
  alias doge='echo "DOGE HERE. MUCH BASH. SUCH TERMINAL"'
  alias shortgrep='grep --invert-match -E ".{200}"'
  alias ll='ls -lhAS'

  alias dsk='jump dsk'
  alias dls='jump dls'

  alias agl='ag --pager="less -R"'
  alias grep='grep --color=auto -I'
  #                              ^ ignore binary files
  #                  ^ highlight matches
  alias igrep='grep --invert-match'
  alias fzfp='fzf --preview "head --lines=40 {}"'

  function giff
    g -c vim $argv[1] +Gdiff
  end

  function howtousexargs
    echo "ls | tr '\n' '\0' | xargs -0 -n1 -p"
    echo "ls | sed '/s/.*/\"&\"/'"
  end

  if command -v lpass > /dev/null
    function laspas
      lpass show -c --password (lpass ls | fzf | awk '{print $(NF)}' | sed 's/\]//g')
    end
  end

  if command -v aws > /dev/null
    # aws completion https://github.com/aws/aws-cli/issues/1079#issuecomment-242923826
    complete --command aws --no-files --arguments '(begin; set --local --export COMP_SHELL fish; set --local --export COMP_LINE (commandline); aws_completer | sed \'s/ $//\'; end)'
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
        echo "nah"
        return
      else
        # attach to existing session or create one
        tmux a; or tmux
      end
    end
  end

  function gd
    echo "cd "(dirname (git list $argv[1]))
    cd (dirname (git list $argv[1]))
  end
  alias fd="cd (find . -type d | fzf)"

  function download
    wget --continue --progress=dot:mega --tries=0 $argv
  end

#Screen
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
  # screen -RR to attach to most recent session
  function starttourd
    jt
    screen -d -m -S t gulp serve
    jl
    screen -d -m -S l nodemon server-index.js
    jm
    screen -d -m -S m nodemon
    jt
  end
  function startuc2
    uc2js
    screen -d -m -S http http-server -p 8000 -c-1
  end
  function startalacritty
    screen -d -m -S alac ~/git/alacritty/target/release/alacritty
  end

#FZF

  if command -v rg > /dev/null
    set -x FZF_DEFAULT_COMMAND 'rg -g "!dist" -g "!jmeter" -g "!*min.js" --files'
    set -x FZF_CTRL_T_COMMAND 'rg --files'
  else
    echo "(consider installing rg)"
  end

  function fzfhelp
  echo ' fdr    - cd to selected parent directory'
  echo ' cdf    - cd into the directory of the selected file'
  echo ' fstash - manage git stash. enter to see contents, C-d to diff against HEAD, C-b to checkout as branch'
  echo ' fshow  - git commit browser'
  echo ' fco    - checkout branch or tag'
  echo ' fbr    - fuzzy find branch'
  end

  function fco
    # If we assign results to a local var, newlines are converted to spaces.
    # That's no good. Instead we store in a local file.

    git branch --all | grep -v HEAD | sed "s/.* //" | sed "s#remotes/[^/]*/##" | sort -u | fzf > /tmp/fzf.result;
    echo  git checkout (cat /tmp/fzf.result)
    spin "git checkout (cat /tmp/fzf.result)"

    # TODO: use tmp file instead of local var for the following code
    # set -l tags branches target
    # set tags (git tag | awk '{print "\x1b[31;1mtag\x1b[m\t" $1}'); or return 1
    # set branches (git branch --all | grep -v HEAD | sed "s/.* //" | sed "s#remotes/[^/]*/##" | sort -u | awk '{print "\x1b[34;1mbranch\x1b[m\t" $1}' ) # | \
    # set target (
    #   (echo $tags; echo $branches) | \
    #   fzf-tmux -l30 -- --no-hscroll --ansi +m -d "\t" -n 2); or return
    # git checkout (echo "$target" | awk '{print $2}')
  end

  function cpbr
    # If we assign results to a local var, newlines are converted to spaces.
    # That's no good. Instead we store in a local file.

    git branch --all | grep -v HEAD | sed "s/.* //" | sed "s#remotes/[^/]*/##" | sort -u | fzf > /tmp/fzf.result;
    echo (cat /tmp/fzf.result) | pbcopy
  end
