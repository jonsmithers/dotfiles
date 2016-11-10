function fish_user_key_bindings

    # hybrid vim and emacs bindings
    # https://github.com/fish-shell/fish-shell/pull/3068
    for mode in default insert visual
        fish_default_key_bindings -M $mode
    end
    fish_vi_key_bindings --no-erase

    fzf_key_bindings

    bind ! bind_bang
    bind '$' bind_dollar
    bind -M insert ! bind_bang
    bind -M insert '$' bind_dollar

end

