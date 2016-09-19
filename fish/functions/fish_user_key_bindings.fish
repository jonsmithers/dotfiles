function fish_user_key_bindings

    bind ! bind_bang
    bind '$' bind_dollar
    bind -M insert ! bind_bang
    bind -M insert '$' bind_dollar

    fish_vi_key_bindings
    fzf_key_bindings

end

