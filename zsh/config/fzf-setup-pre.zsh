if has rg; then
  export FZF_DEFAULT_COMMAND="rg --hidden --files --glob !.git"
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
fi
export FZF_DEFAULT_OPTS='
  --info=inline
  --bind ctrl-q:toggle-all
  --bind ctrl-j:preview-down+preview-down+preview-down+preview-down
  --bind ctrl-k:preview-up
  --bind ctrl-u:preview-page-up
# --bind ctrl-d:preview-page-down (need this to delete chars)
  --pointer=➜
  --ellipsis=…
  --marker=✓
  --bind ctrl-'"\\\\\\"':toggle-preview
  --bind '"'"'alt-q:change-preview-window(right,70%|down,40%,border-horizontal|hidden|right)'"'"'
  --bind '"'"'alt-Q:change-preview-window(right|hidden|down,40%,border-horizontal|right,70%)'"'"'
  --bind ctrl-y:preview-up
  --bind ctrl-r:prev-history
  --bind ctrl-t:next-history
  --bind ctrl-p:up
  --bind ctrl-n:down
  '
# select previous       | ctrl-p | :-( not show previous history search
# carot to end          | ctrl-e | :-( not scroll down
# carot to start        | ctrl-a |
# preview down          | ctrl-j | :-( not select next
# preview page down     |        |
# preview page up       | ctrl-u |
# preview up            | ctrl-k | :-( not kill line :-( not select previous
# rotate preview layout | alt-Q  |
# rotate preview layout | alt-q  |
# toggle all items      | alt-a  |
# toggle all items      | ctrl-q |
# toggle preview        | ctrl-/ | ??? doesn't work in kitty/nvim
# toggle preview        | ctrl-\ |

# https://blog.jez.io/fzf-bazel/
_fzf_complete_bazel_test() {
  _fzf_complete '-m' "$@" < <(command bazel query "kind('(test|test_suite) rule', //...)")
}

_fzf_complete_bazel() {
  if ! has bazel; then
    return
  fi
  local tokens
  tokens=(${(z)LBUFFER})

  if [ ${#tokens[@]} -ge 3 ] && [ "${tokens[2]}" = "test" ]; then
    _fzf_complete_bazel_test "$@"
  else
    # Might be able to make this better someday, by listing all repositories
    # that have been configured in a WORKSPACE.
    # See https://stackoverflow.com/questions/46229831/ or just run
    #     bazel query //external:all
    # This is the reason why things like @ruby_2_6//:ruby.tar.gz don't show up
    # in the output: they're not a dep of anything in //..., but they are deps
    # of @ruby_2_6//...
    # _fzf_complete '-m' "$@" < <(command bazel query --keep_going --noshow_progress "kind('(binary rule)|(generated file)', deps(//...))" 2> /dev/null)
    _fzf_complete '-m' "$@" < <(command bazel query "executables(//...)")
  fi
}

# https://github.com/junegunn/fzf/blob/d1f037059ab57aa1c70abe124b2b72a710f4a28f/shell/completion.zsh#L352-L388
_fzf_complete_caffeinate() {
  local transformer
  transformer='
    if [[ $FZF_KEY =~ ctrl|alt|shift ]] && [[ -n $FZF_NTH ]]; then
      nths=( ${FZF_NTH//,/ } )
      new_nths=()
      found=0
      for nth in ${nths[@]}; do
        if [[ $nth = $FZF_CLICK_HEADER_NTH ]]; then
          found=1
        else
          new_nths+=($nth)
        fi
      done
      [[ $found = 0 ]] && new_nths+=($FZF_CLICK_HEADER_NTH)
      new_nths=${new_nths[*]}
      new_nths=${new_nths// /,}
      echo "change-nth($new_nths)+change-prompt($new_nths> )"
    else
      if [[ $FZF_NTH = $FZF_CLICK_HEADER_NTH ]]; then
        echo "change-nth()+change-prompt(> )"
      else
        echo "change-nth($FZF_CLICK_HEADER_NTH)+change-prompt($FZF_CLICK_HEADER_WORD> )"
      fi
    fi
  '
  _fzf_complete -m --header-lines=1 --no-preview --wrap --color fg:dim,nth:regular \
    --bind "click-header:transform:$transformer" -- "$@" < <(
    command ps -eo user,pid,ppid,start,time,command 2> /dev/null ||
      command ps -eo user,pid,ppid,time,args 2> /dev/null || # For BusyBox
      command ps --everyone --full --windows # For cygwin
  )
}
_fzf_complete_caffeinate_post() {
  __fzf_exec_awk '{print $2}'
}
