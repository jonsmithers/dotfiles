# https://gist.githubusercontent.com/britishtea/39ad478fa5180e1432a2/raw/c56527202e8152b2db40473608ef114a6736aaae/fish_right_prompt.fish
function fish_right_prompt -d "Write out the right prompt"
  set -l exit_code $status
  set -l is_git_repository (git rev-parse --is-inside-work-tree ^/dev/null)

  set_color black


  # Print a yellow fork symbol when in a subshell
  set -l max_shlvl 1
  test $TERM = "screen"; and set -l max_shlvl 3
  if test $SHLVL -gt $max_shlvl
    set_color yellow
    echo -n "⑂ "
    set_color black
  end

  # Print a red dot for failed commands.
  if test $exit_code -ne 0
    set_color red
    echo -n "•$exit_code•"
    set_color black
  end



  # Print coloured arrows when git push (up) and / or git pull (down) can be run.
  #
  # Red means the local branch and the upstream branch have diverted.
  # Yellow means there are more than 3 commits to push or pull.
  if test -n "$is_git_repository"
    git rev-parse --abbrev-ref '@{upstream}' >/dev/null ^&1; and set -l has_upstream
    if set -q has_upstream
      set -l commit_counts (git rev-list --left-right --count 'HEAD...@{upstream}' ^/dev/null)

      set -l commits_to_push (echo $commit_counts | cut -f 1 ^/dev/null)
      set -l commits_to_pull (echo $commit_counts | cut -f 2 ^/dev/null)

      if test $commits_to_push != 0
        if test $commits_to_pull -ne 0
          set_color red
        else if test $commits_to_push -gt 3
          set_color yellow
        else
          set_color green
        end

        echo -n "⇡ "
      end

      if test $commits_to_pull != 0
        if test $commits_to_push -ne 0
          set_color red
        else if test $commits_to_pull -gt 3
          set_color yellow
        else
          set_color green
        end

        echo -n "⇣ "
      end

      set_color grey
    end

    # Print a "stack symbol" if there are stashed changes.
    # if test (git stash list | wc -l) -gt 0
    #   echo -n "☰ "
    # end
  end

  # Print the username when the user has been changed.
  if test $USER != $LOGNAME
    echo -n "$USER@"
  end

  # Print the current directory. Replace $HOME with ~.
  # echo -n (pwd | sed -e "s|^$HOME|~|")

  # Print the current git branch name or shortened commit hash in colour.
  #
  # Green means the working directory is clean.
  # Yellow means all changed files have been staged.
  # Red means there are changed files that are not yet staged.
  #
  # Untracked files are ignored.
  if test -n "$is_git_repository"
    # echo -n ":"

    git diff-files --quiet --ignore-submodules ^/dev/null; or set -l has_unstaged_files
    git diff-index --quiet --ignore-submodules --cached HEAD ^/dev/null; or set -l has_staged_files

    if set -q has_unstaged_files
      set_color red
    else if set -q has_staged_files
      set_color yellow
    else
      set_color green
    end

    # set -l branch (git symbolic-ref --short HEAD ^/dev/null; or git show-ref --head -s --abbrev | head -n1 ^/dev/null)
    # echo -n \($branch\)
    echo -n (__fish_vcs_prompt) # invokes __fish_git_prompt

    set_color black
  end

  set_color normal
end
