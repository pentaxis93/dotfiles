function dotclaude --description "Launch Claude Code for dotfiles management"
    # Ensure we're in the right place for project discovery
    cd ~/.config/dotfiles || begin
        echo "Error: Dotfiles directory not found" >&2
        return 1
    end

    # Visual confirmation
    echo "🔧 Launching Claude Code in dotfiles mode..."
    echo "📁 Working directory: $(pwd)"

    # Launch with all arguments passed through
    # Environment variables now come from global settings
    claude code $argv
end