function fish_user_key_bindings

    fzf_key_bindings

    function fzf_for_git_branch
        switch (commandline -t)[-1]
        case "!"
            # git branches without "origin/"
            # git branch --all | grep -v HEAD | sed "s/.* //" | sed "s#remotes/[^/]*/##" | sort -u | fzf > /tmp/fzf.result;

            # git branches with "origin/"
            git branch --all | grep -v HEAD | sed "s/.* //" | sed "s#remotes/##" | sort -u | fzf > /tmp/fzf.result;
            commandline -t (cat /tmp/fzf.result); commandline -f repaint
        case "*"
            commandline -i 'B'
        end
    end

    function fzf_for_local_git_branch
        switch (commandline -t)[-1]
        case "!"
            # git branches without "origin/"
            # git branch --all | grep -v HEAD | sed "s/.* //" | sed "s#remotes/[^/]*/##" | sort -u | fzf > /tmp/fzf.result;

            # git branches with "origin/"
            git branch | grep -v HEAD | sed "s/.* //" | sed "s#remotes/##" | sort -u | fzf > /tmp/fzf.result;
            commandline -t (cat /tmp/fzf.result); commandline -f repaint
        case "*"
            commandline -i 'L'
        end
    end

    function fzf_for_tags
        switch (commandline -t)[-1]
        case "!"
            git tag | grep -v HEAD | sed "s/.* //" | sed "s#remotes/##" | sort -u | fzf > /tmp/fzf.result;
            commandline -t (cat /tmp/fzf.result); commandline -f repaint
        case "*"
            commandline -i 'T'
        end
    end

    function fzf_for_directories
        switch (commandline -t)[-1]
        case "!"
            find . -type d | fzf --multi | tr '\n' ' ' > /tmp/fzf.result;
            commandline -t (cat /tmp/fzf.result); commandline -f repaint
        case "*"
            commandline -i 'D'
        end
    end

    bind -M insert B fzf_for_git_branch
    bind -M insert L fzf_for_local_git_branch
    bind -M insert T fzf_for_tags
    bind -M insert D fzf_for_directories

    bind ! bind_bang
    bind '$' bind_dollar
    bind -M insert ! bind_bang
    bind -M insert '$' bind_dollar

end
