function fish_prompt --description 'Write out the prompt'
	set -l last_status $status

	# Just calculate this once, to save a few cycles when displaying the prompt
	if not set -q __fish_prompt_hostname
		set -g __fish_prompt_hostname (hostname|cut -d . -f 1)
	end

	# Hack; fish_config only copies the fish_prompt function (see #736)
	if not set -q -g __fish_classic_git_functions_defined
		set -g __fish_classic_git_functions_defined

		function __fish_repaint_user --on-variable fish_color_user --description "Event handler, repaint when fish_color_user changes"
			if status --is-interactive
				commandline -f repaint ^/dev/null
			end
		end
		
		function __fish_repaint_host --on-variable fish_color_host --description "Event handler, repaint when fish_color_host changes"
			if status --is-interactive
				commandline -f repaint ^/dev/null
			end
		end
		
		function __fish_repaint_status --on-variable fish_color_status --description "Event handler; repaint when fish_color_status changes"
			if status --is-interactive
				commandline -f repaint ^/dev/null
			end
		end

		function __fish_repaint_bind_mode --on-variable fish_key_bindings --description "Event handler; repaint when fish_key_bindings changes"
			if status --is-interactive
				commandline -f repaint ^/dev/null
			end
		end

		# initialize our new variables
		if not set -q __fish_classic_git_prompt_initialized
			set -qU fish_color_user; or set -U fish_color_user -o green
			set -qU fish_color_host; or set -U fish_color_host -o cyan
			set -qU fish_color_status; or set -U fish_color_status red
			set -U __fish_classic_git_prompt_initialized
		end
	end

	set -l color_cwd
	set -l prefix
	switch $USER
	case root toor
		if set -q fish_color_cwd_root
			set color_cwd $fish_color_cwd_root
		else
			set color_cwd $fish_color_cwd
		end
		set suffix '#'
	case '*'
		set color_cwd $fish_color_cwd
		set suffix '>'
	end

  set -l is_git_repository (git rev-parse --is-inside-work-tree ^/dev/null)
  # Print coloured arrows when git push (up) and / or git pull (down) can be run.
  #
  # Red means the local branch and the upstream branch have diverted.
  # Yellow means there are more than 3 commits to push or pull.
	set -l git_upstream_difference
  if test -n "$is_git_repository"
    git rev-parse --abbrev-ref '@{upstream}' >/dev/null ^&1; and set -l has_upstream
    if set -q has_upstream
      set -l commit_counts (git rev-list --left-right --count 'HEAD...@{upstream}' ^/dev/null)

      set -l commits_to_push (echo $commit_counts | cut -f 1 ^/dev/null)
      set -l commits_to_pull (echo $commit_counts | cut -f 2 ^/dev/null)

			set -l git_outgoing_color
      if test $commits_to_push != 0
        if test $commits_to_pull -ne 0
					set git_outgoing_color (set_color red)
        else if test $commits_to_push -gt 3
					set git_outgoing_color (set_color yellow)
        else
					set git_outgoing_color (set_color green)
        end

				set git_upstream_difference $git_upstream_difference $git_outgoing_color "⇡"
      end

			set -l git_incoming_color
      if test $commits_to_pull != 0
        if test $commits_to_push -ne 0
					set git_incoming_color (set_color red)
          # set_color red
        else if test $commits_to_pull -gt 3
					set git_incoming_color (set_color yellow)
          # set_color yellow
        else
					set git_incoming_color (set_color green)
          # set_color green
        end
				set git_upstream_difference $git_upstream_difference $git_incoming_color "⇣"
      end
			if test -n "$git_upstream_difference"
				set git_upstream_difference (set_color normal) ":" $git_upstream_difference
			end
    end
  end

	# set -l prompt_status
	# if test $last_status -ne 0
	# 	set prompt_status ' ' (set_color $fish_color_status) "[$last_status]" "$normal"
	# end

	# echo -n -s '' (set_color $color_cwd) (prompt_pwd) $gitcolor (__fish_vcs_prompt) $normal $prompt_status "\$ "
	echo -n -s '' (set_color $color_cwd) (prompt_pwd) (set_color red) (__fish_vcs_prompt) $git_upstream_difference (set_color normal) "\$ "
end
