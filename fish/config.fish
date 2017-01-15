fish_user_key_bindings

export NOTI_PUSHBULLET_TOK=o.5RKGbICfF91y9S6zifyMPs6YTLdM0tdp
export FZF_DEFAULT_COMMAND='ag -g ""'

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
  function changeModeIndicator
    function fish_mode_prompt --description 'Displays the current mode'
      if [ $fish_key_bindings != 'fish_vi_key_bindings' ]
        return
      end
      switch $fish_bind_mode
      case default
        set_color --bold --background red white
      echo 'normal'
        case insert
      set_color normal
        echo 'insert'
      case visual
        set_color --bold --background magenta white
        echo 'visual'
      end
      set_color normal
      echo -n ' '
    end
  end
  changeModeIndicator

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
    case zamperini3
      init_echo "zamperini3 init"
      alias dsk='jump dsk'
      alias dls='jump dls'
      alias jl='jump l'
      alias jt='jump t'
      alias jm='jump m'
      alias vim='nvim'
      alias journal="gnome-terminal --command='wordsafe j' --full-screen --hide-menubar"
      #alias journal="guake -t; gnome-terminal --command='wordsafe j' --full-screen --hide-menubar"
      alias lamemp3='lame -V0 -h -b 160 --vbr-new'
      #wordsafe -E "nvim -c Goyo -c WM -c 'set nofoldenable'"

      set NODEJS_HOME /usr/lib/nodejs/node-v6.6.0
      set PATH $NODEJS_HOME/bin $PATH    # because node and npm are here
      set PATH ~/.npm-packages/bin $PATH # because ~/.npmrc has: "prefix = ${HOME}/.npm-packages"
      set PATH /usr/local/go/bin $PATH
      set -x GOPATH ~/go-workspace

    case zamperini2
      init_echo "bash_profile: zamperini2 init"
      alias journal="guake -t; gnome-terminal --command='wordsafe j' --title='Journal' --full-screen --hide-menubar"

      alias dsk='jump dsk'
      alias dls='jump dls'
      alias vim='nvim'
      alias tourweb='open https://github.com/jonsmithers/TourApp'

      alias lamemp3='lame -V0 -h -b 160 --vbr-new'

      set PATH /usr/local/go/bin/ $PATH
      set PATH /home/smithers/.gopath/bin $PATH
      set -x GOPATH /home/smithers/.gopath

    case Smithers.local
      init_echo "Work Lappy init"

      # iterm2 integration
      test -e {$HOME}/.iterm2_shell_integration.fish ; and source {$HOME}/.iterm2_shell_integration.fish

      # make buildr work
      set PATH /Users/smithers/.rvm/gems/ruby-2.2.2/bin/ $PATH
      # rvm default # shows an annoying warning in some contexts (like vim's :! shell execution)

      # shortcut in case I need bash
      alias bash='bash --init-file ~/.bash_startup'

      source ~/.iterm2_shell_integration.fish

      export GOPATH=/Users/smithers/gocode
      export JAVA_HOME=/Library/Java/JavaVirtualMachines/jdk1.7.0_72.jdk/Contents/Home/ #needed for buildr to work on dev 20150514
      export CLICOLOR=1
      export LSCOLORS="Gxfxcxdxbxegedabagacad"
      alias dc2f='jump dc2f'
      alias asma='jump asma'
      alias uc2='jump uc2'
      alias uc2js='jump uc2js'
      alias leaf='jump leaf'
      alias risc2='jump risc2'
      alias tomcat='~/programs/runBranch.sh'
      alias debugmeteor="env NODE_OPTIONS='--debug' meteor run"
      alias slatetail='tail -f /var/log/system.log | grep --line-buffered "Slate" | sed "s/.*.local Slate\[[0-9]*\]:/> /"'
      alias wfs='/Users/smithers/git/UC2/uc2-app/support/scripts/waitForServer.js'
      alias metadata='/Users/smithers/git/metadata/metadata'

      function uc2b
        echo (wfs; and ~/bin/browseUc2) &
      end

      function copyIP
        ifconfig | grep 192 | sed -E 's/.*inet ([0-9.]+).*/http:\/\/\1:8000/' | pbcopy
        echo 'copied '
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


# global aliases
  alias g='git number'
  alias gn='git number'
  alias gim='g -c nvim'
  alias deletemergedbranches='git branch --merged | grep -v "\*" | grep -v master | grep -v dev | xargs -n 1 git branch -d'
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

  function howtousexargs
    echo "ls | tr '\n' '\0' | xargs -0 -n1 -p"
    echo "ls | sed '/s/.*/\"&\"/'"
  end

#Screen
  alias killallscreens='screen -ls | grep Detached | cut -d. -f1 | xargs kill'
  function starttourd
    jt
    screen -d -m -S t gulp serve
    jl
    screen -d -m -S l nodemon server-index.js
    jm
    screen -d -m -S m nodemon
    jt
  end

#FZF
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

    git branch --all | grep -v HEAD | sed "s/.* //" | sed "s#remotes/[^/]*/##" | sort -u | fzf > $TMPDIR/fzf.result;
    echo  git checkout (cat $TMPDIR/fzf.result)
    spin "git checkout (cat $TMPDIR/fzf.result)"

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

    git branch --all | grep -v HEAD | sed "s/.* //" | sed "s#remotes/[^/]*/##" | sort -u | fzf > $TMPDIR/fzf.result;
    echo (cat $TMPDIR/fzf.result) | pbcopy
  end
