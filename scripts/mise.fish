if status is-interactive
    fish_add_path --path "$HOME/.local/bin"
    mise activate fish | source
end
