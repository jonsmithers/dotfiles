fzfCommit() {
  local FZF_PROMPT="${FZF_PROMPT:=Commit: }"
  git log --oneline | fzf --border --prompt="$FZF_PROMPT" --height=10         --preview="git show {+1} --color=always" --no-sort --reverse | cut -d' ' -f1 | tr '\n' ' ' | sed 's/[[:space:]]$//';
}
fzfCommits() {
  local FZF_PROMPT="${FZF_PROMPT:=Commit: }"
  git log --oneline | fzf --border --prompt="$FZF_PROMPT" --height=10 --multi --preview="git show {+1} --color=always" --no-sort --reverse | cut -d' ' -f1 | tr '\n' ' ' | sed 's/[[:space:]]$//'
}
fzfTags() {
  git tag | grep -v HEAD | sed "s/.* //" | sed "s#remotes/##" | sort -u | fzf --border --prompt='Tag: ' --height=30 --multi --preview="git log --format=medium --graph --max-count 10 {+1}" | tr '\n' ' ' | sed 's/[[:space:]]$//'
}
fzfBranches() {
  git branch --all | grep -v HEAD | sed "s/.* //" | sed "s#remotes/##" | sort -u | fzf --border --prompt='Branch: ' --height=60% --multi --preview="git log --graph --max-count=10 {+1}" | tr '\n' ' ' | sed 's/[[:space:]]$//'
}
insertCommits() {
  if [[ "$LBUFFER[-1]" != "!" ]]; then
    LBUFFER+='C'
    return 0
  fi
  LBUFFER="${LBUFFER[1,-2]}$(fzfCommits)"
  local ret=$?
  zle reset-prompt
  return $ret
}
insertTags() {
  if [[ "$LBUFFER[-1]" != "!" ]]; then
    LBUFFER+='T'
    return 0
  fi
  LBUFFER="${LBUFFER[1,-2]}$(fzfTags)"
  local ret=$?
  zle reset-prompt
  return $ret
}
insertBranches() {
  if [[ "$LBUFFER[-1]" != "!" ]]; then
    LBUFFER+='B'
    return 0
  fi
  LBUFFER="${LBUFFER[1,-2]}$(fzfBranches)"
  local ret=$?
  zle reset-prompt
  return $ret
}

zle -N insertCommits
bindkey C insertCommits
zle -N insertTags
bindkey T insertTags
zle -N insertBranches
bindkey B insertBranches