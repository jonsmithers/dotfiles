if ! has fzf; then
  return
fi

emoji() {
  # https://www.thenegation.com/posts/nix-fzf-script-tutorial/
  [[ -f /tmp/emoji.json ]] || curl -sSL "https://raw.githubusercontent.com/github/gemoji/0eca75db9301421efc8710baf7a7576793ae452a/db/emoji.json" > /tmp/emoji.json
  cat /tmp/emoji.json |
    jq -r '.[] | (.emoji + " :" + .aliases[0] + ": "+ .category + " » " + .description)' |
    fzf \
      --delimiter " " \
      --bind 'enter:become(printf {1} | pbcopy)' \
      --bind 'ctrl-c:become(printf {2} | pbcopy)'
}

source "$HOME/.config/zsh/fzf-git-widgets.zsh"

function gfixup {
  local commit=$(FZF_PROMPT='Fixup Commit: ' fzfCommit)
  if [[ -z "$commit" ]]; then
    return 1
  fi
  set -x
  git commit --fixup "$commit" --allow-empty > /dev/null || return 1
  git rebase --interactive "$commit"~ --autosquash || return 1
}

function gcleanup {
  local branches
  branches=$(git for-each-ref --sort=committerdate refs/heads/ \
    --format='%(committerdate:relative)|%(refname:short)' \
    | grep -v "^.*|$(git rev-parse --abbrev-ref HEAD)$" \
    | column -t -s'|' \
    | fzf --multi --no-sort --border --prompt='Delete branches: ' --height=60% \
      --header='TAB to select, ENTER to delete' \
      --preview='git log --oneline --graph --max-count=20 {NF}' \
    | awk '{print $NF}')
  if [[ -z "$branches" ]]; then
    return 0
  fi
  echo "$branches" | while read -r branch; do
    (set -x; git branch -D "$branch" )
  done
}
function gcleanup-remote {
  local remote="${1:-origin}"
  git fetch "$remote" --prune
  local branches
  branches=$(git for-each-ref --sort=committerdate "refs/remotes/$remote/" \
    --format='%(committerdate:relative)|%(refname:lstrip=3)' \
    | grep -v "^.*|HEAD$" \
    | grep -v "^.*|$(git rev-parse --abbrev-ref HEAD)$" \
    | column -t -s'|' \
    | fzf --multi --no-sort --border --prompt="Delete $remote branches: " --height=60% \
      --header='TAB to select, ENTER to delete' \
      --preview="git log --oneline --graph --max-count=20 $remote/{NF}" \
    | awk '{print $NF}')
  if [[ -z "$branches" ]]; then
    return 0
  fi
  echo "$branches" | while read -r branch; do
    (set -x; git push "$remote" --delete "$branch" )
  done
}
git-prune-worktrees() {
  local gone_branches worktrees selected

  # gone_branches=$(git branch -vv | awk '/: gone\]/{print $1}')
  gone_branches=$(git branch -vv | awk '/: gone\]/{sub(/^[* +]+/, ""); print $1}')
  if [[ -z "$gone_branches" ]]; then
    echo "No branches with gone upstreams found."
    return 0
  fi

  worktrees=$(git worktree list | while IFS= read -r line; do
    branch=$(echo "$line" | sed 's/.*\[//;s/\].*//');
    for gb in ${(f)gone_branches}; do
      [[ "$branch" == "$gb" ]] && echo "$line"
    done
  done)

  if [[ -z "$worktrees" ]]; then
    echo "No worktrees with gone upstreams found."
    return 0
  fi

  selected=$(echo "$worktrees" | fzf --reverse --header-border=rounded --height=8 --multi --header="The following worktrees have branches with missing upstreams")
  if [[ -z "$selected" ]]; then
    echo "No worktrees selected."
    return 0
  fi

  echo "$selected" | while IFS= read -r line; do
    wt_path=$(echo "$line" | awk '{print $1}')
    echo "Removing worktree: $wt_path"
    (set -x; git worktree remove "$wt_path" )
  done
}
