function git-maintain-cleanup-branches {
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

function git-maintain-cleanup-branches-remote {
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

function git-maintain-prune-worktrees() {
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

function git-maintain-cleanup-merged-worktrees() {
  local main_worktree
  local -a merged_worktrees

  main_worktree=$(git worktree list --porcelain | head -1 | awk '{print $2}')

  while read -r wt; do
    [[ "$wt" == "$main_worktree" ]] && continue

    local branch
    branch=$(git -C "$wt" rev-parse --abbrev-ref HEAD 2>/dev/null)
    [[ -z "$branch" || "$branch" == "HEAD" ]] && continue

    local state
    state=$(gh pr view "$branch" --json state --jq '.state' 2>/dev/null)

    if [[ "$state" == "MERGED" ]]; then
      merged_worktrees+=("$wt|$branch")
    fi
  done < <(git worktree list --porcelain | grep '^worktree ' | awk '{print $2}')

  if [[ ${#merged_worktrees[@]} -eq 0 ]]; then
    echo "No worktrees with merged PRs found."
    return 0
  fi

  echo "Worktrees with merged PRs:"
  echo ""
  for entry in "${merged_worktrees[@]}"; do
    echo "  ${entry%%|*}  (${entry##*|})"
  done

  echo ""
  read -q "confirm?Delete these worktrees? [y/N] "
  echo ""

  if [[ "$confirm" != "y" ]]; then
    echo "Aborted."
    return 0
  fi

  for entry in "${merged_worktrees[@]}"; do
    local wt="${entry%%|*}" branch="${entry##*|}"
    echo "Removing: $wt ($branch)"
    git worktree remove --force "$wt"
    git branch -D "$branch" 2>/dev/null
  done

  echo "Done."
}

