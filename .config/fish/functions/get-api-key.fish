function get-api-key --description "Retrieve an API key from pass"
    if test (count $argv) -eq 0
        echo "Usage: get-api-key <service>"
        echo "Example: get-api-key openrouter"
        return 1
    end

    set -l service $argv[1]
    set -l key_path "api/$service"

    # Check if key exists
    if not pass show $key_path >/dev/null 2>&1
        echo "API key for '$service' not found in pass" >&2
        echo "Add it with: pass insert api/$service" >&2
        return 1
    end

    # Return the key (single line, no output)
    pass show $key_path 2>/dev/null | head -n1
end
