function fish_user_key_bindings

    # hybrid vim and emacs bindings
    # https://github.com/fish-shell/fish-shell/pull/3068
    for mode in default insert visual
        fish_default_key_bindings -M $mode
    end
    fish_vi_key_bindings --no-erase

    fzf_key_bindings

    function fzf_for_git_branch
        switch (commandline -t)[-1]
        case "!"
            # git branches without "origin/"
            # git branch --all | grep -v HEAD | sed "s/.* //" | sed "s#remotes/[^/]*/##" | sort -u | fzf > $TMPDIR/fzf.result;

            # git branches with "origin/"
            git branch --all | grep -v HEAD | sed "s/.* //" | sed "s#remotes/##" | sort -u | fzf > $TMPDIR/fzf.result;
            commandline -t (cat $TMPDIR/fzf.result); commandline -f repaint
        case "*"
            commandline -i 'B'
        end
    end

    function fzf_for_local_git_branch
        switch (commandline -t)[-1]
        case "!"
            # git branches without "origin/"
            # git branch --all | grep -v HEAD | sed "s/.* //" | sed "s#remotes/[^/]*/##" | sort -u | fzf > $TMPDIR/fzf.result;

            # git branches with "origin/"
            git branch | grep -v HEAD | sed "s/.* //" | sed "s#remotes/##" | sort -u | fzf > $TMPDIR/fzf.result;
            commandline -t (cat $TMPDIR/fzf.result); commandline -f repaint
        case "*"
            commandline -i 'B'
        end
    end

    bind -M insert B fzf_for_git_branch
    bind -M insert L fzf_for_local_git_branch

    bind ! bind_bang
    bind '$' bind_dollar
    bind -M insert ! bind_bang
    bind -M insert '$' bind_dollar

end
