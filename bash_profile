# Git Completion
  if [ -f ~/.git-completion.sh ]; then
    source ~/.git-completion.sh
    PS1='[\[$(tput setaf 5)\]\u \[$(tput setaf 2)\]\w\[$(tput setaf 1)\]$(__git_ps1 " (%s)")\[$(tput sgr0)\]]$ '
    PS1='\[$(tput setaf 2)\]\w\[$(tput setaf 1)\]$(__git_ps1 " (%s)")\[$(tput sgr0)\]$ '
  fi

# Filesystem navigation
  # http://jeroenjanssens.com/2013/08/16/quickly-navigate-your-filesystem-from-the-command-line.html
  export MARKPATH=$HOME/.marks
  function jump {
      cd -P "$MARKPATH/$1" 2>/dev/null || return 1; #echo "No such mark: $1"
  }
  function mark {
      mkdir -p "$MARKPATH"; ln -s "$(pwd)" "$MARKPATH/$1"
  }
  function unmark {
      rm -i "$MARKPATH/$1"
  }
  #function marks() is created in OS-specific section

# Platform specific stuff
  ##### APPLE #####
  if [ "$(uname)" == "Darwin" ]; then
    echo "bash_profile: apple init"
    # Filesystem navigation
      function marks {
        \ls -l "$MARKPATH" | tail -n +2 | sed 's/  / /g' | cut -d' ' -f9- | awk -F ' -> ' '{printf "%-10s -> %s\n", $1, $2}'
      } 
  ###### LINUX #####
  elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
    echo "bash_profile: linux init"
    function download {
      # let's you download a file over a spotty connection.
      # wget not available on Mac, and I think curl works pretty well 
      wget --continue --progress=dot:mega --tries=0 "$1"
      
      wget --continue --progress=dot:mega --tries=0 "$1"
    }
    # Filesytem navigation
      function marks {
          ls -l "$MARKPATH" | sed 's/  / /g' | cut -d' ' -f9- | sed 's/ -/  -/g' && echo
      } 
  ##### WINDOWS #####
  elif [ "$(expr substr $(uname -s) 1 10)" == "MINGW32_NT" ]; then 
    echo "I'm so sorry"
  fi
# Machine specific stuff
  ##### Home Laptop #####
  if [ "$(hostname)" == "Zamperini" ]; then
    echo "bash_profile: zamperini init"
    alias open="xdg-open"

  ##### Work Laptop #####
  elif [[ "$(hostname)" =~ Smithers(\.local)? ]]; then
    echo "bash_profile: work laptop init"
    PATH=$PATH:~/programs/scala-2.11.4/bin
    ## Inserted programmatically
      [[ -s "$HOME/.profile" ]] && source "$HOME/.profile" # Load the default .profile
      [[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*
    ## Aliases
      alias dc2f='jump dc2f'
      alias asma='jump asma'
      alias uc2='jump uc2'
      alias leaf='jump leaf'
      alias risc2='jump risc2'
      alias slatetail='tail -f /var/log/system.log | grep --line-buffered "Slate" | sed "s/.*.local Slate\[[0-9]*\]:/> /"' 
      alias sfailp='(echo -e "\e[0;31muh oh!" && pushbullet push all note "Failure" "Something went wrong." && mplayer -msglevel all=-1 "/Applications/iMovie.app/Contents/Resources/iMovie Sound Effects/Crowd Boo.mp3")'
      alias sdonep='(echo -e "\e[0;36myus!" && pushbullet push all note "Success" "It worked!" && mplayer -msglevel all=-1 "/Applications/Wunderlist.app/Contents/Resources/WLCompletionSound.mp3")' 
      alias sfail='(echo -e "\e[0;31muh oh!" && terminal-notifier -title "Failure" -message "Something went wrong." && mplayer -msglevel all=-1 "/Applications/iMovie.app/Contents/Resources/iMovie Sound Effects/Crowd Boo.mp3")'
      alias sdone='(echo -e "\e[0;36myus!" && terminal-notifier -title "Success" -message "It worked!" && mplayer -msglevel all=-1 "/Applications/Wunderlist.app/Contents/Resources/WLCompletionSound.mp3")'
      alias notify='getLastExitStatus && sdone || sfail'
      alias notifyp='getLastExitStatus && sdonep || sfailp'
      alias n='notify'
      alias np='notifyp'
      function getLastExitStatus {
        return $?
      }
    # Functions
      function uploadjars {
        function dummy {
          source ~/.bash_profile #alias scoping can be weird. http://superuser.com/questions/708462/alias-scoping-in-bash-functions
        }
        dummy
        echo -e " \e[36m ::::: \e[33m REMEMBER TO EXIT OUT OF .CLASS FILES \e[36m ::::: \e[39m" \
        && jump leaf \
        && buildr test=no upload \
        && echo "jumping to $1" \
        && jump $1 \
        && echo -e "\e[33m Deleting old jars \e[39m" \
        && rm -r ./lib/repository/com/leidos/dc2f \
        && buildr clean artifacts:sources eclipse \
        || echo "something went wrong?"
      }
      function subl() {
        "/Applications/Sublime Text.app/Contents/SharedSupport/bin/subl" "$@"
      }
      function javaws() {
        /System/Library/Java/Support/Deploy.bundle/Contents/Home/bin/javaws "$@"
      }
      function ecl() {
        /Users/smithers/programs/eclipse/Eclipse "$@" &
      }
      function sikuli() {
        /Applications/SikuliX-IDE.app/Contents/sikuli-ide.jar -r "$1"
      }
      function git-gui()
      {
        /usr/local/git/libexec/git-core/git-gui "$@"
      }
  else echo "No machine intialization $(hostname)"
  fi

## aliases
  alias git-gui='/usr/local/git/libexec/git-core/git-gui'

  alias g='git number'
  alias gn='git number'
  alias gim='g -c vim'
  alias gatom='g -c atom'
  alias todos='git grep -I --ignore-case -E "todo.*(smithers|JJS)"'
  alias doge='echo "DOGE HERE. MUCH BASH. SUCH TERMINAL"'
  alias shortgrep='grep --invert-match -E ".{200}"'

  alias dsk='jump dsk'
  alias dls='jump dls'

  alias grep='grep --color=auto -I'
  #                              ^ ignore binary files
  #                  ^ highlight matches
  alias igrep='grep --invert-match'

## functions
  extract () {
    # credit: http://nparikh.org/notes/zshrc.txt
    # Usage: extract <file>
    # Description: extracts archived files / mounts disk images
    # Note: .dmg/hdiutil is Mac OS X-specific.
    if [ -f $1 ]; then
      case $1 in
        *.tar.bz2)  tar -jxvf $1                        ;;
        *.tar.gz)   tar -zxvf $1                        ;;
        *.bz2)      bunzip2 $1                          ;;
        *.dmg)      hdiutil mount $1                    ;;
        *.gz)       gunzip $1                           ;;
        *.tar)      tar -xvf $1                         ;;
        *.tbz2)     tar -jxvf $1                        ;;
        *.tgz)      tar -zxvf $1                        ;;
        *.zip)      unzip $1                            ;;
        *.ZIP)      unzip $1                            ;;
        *.pax)      cat $1 | pax -r                     ;;
        *.pax.Z)    uncompress $1 --stdout | pax -r     ;;
        *.Z)        uncompress $1                       ;;
        *)          echo "'$1' cannot be extracted/mounted via extract()" ;;
      esac
    else
      echo "'$1' is not a valid file"
    fi
  }

  function encrypt {
       openssl aes-256-cbc -a -salt -in "$1" -out "$2"
  }
  function decrypt {
       openssl aes-256-cbc -d -a -in "$1" -out "$2"
  }
  
  function searchfortext {
      grep -r -I "$1" .
  }
  function d() { cd "$@" && ls;} 
  function statsfor {
    git log --author="$1" --pretty=tformat: --numstat | awk '{ add += $1 ; subs += $2 ; loc += $1 - $2 } END \
    { printf "added lines: %s removed lines : %s total lines: %s\n",add,subs,loc }'
  }
  
shopt -s globstar # HAIL THE GLOBSTAR
shopt -s cdspell # cd ignores minor spelling mistakes
shopt -s autocd # omit cd and just put a directory

#export PATH=/usr/local/bin:$PATH TRASH
# acronymns
# function whats { TRASH
#   awk "/${1}/" ~/acronyms
# }
