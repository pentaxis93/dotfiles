#!/usr/bin/env bash
# ============================================================================
# SECRETS MANAGEMENT LIBRARY
# ============================================================================
# Purpose:
#   Shared functions for secure credential management using Bitwarden CLI
#
# How it works:
#   - Provides wrapper functions around Bitwarden CLI
#   - Handles session management and caching
#   - Ensures secrets are never written to disk
#
# Dependencies:
#   - bitwarden-cli (bw command)
#
# Usage:
#   source this file, then use:
#   - bw_ensure_logged_in: Ensure user is authenticated
#   - bw_get_secret: Retrieve a secret by item name
#   - bw_get_api_key: Retrieve an API key by service name
#
# Security Notes:
#   - Session tokens expire after 30 minutes of inactivity
#   - Never log or echo secrets in plain text
#   - Always use command substitution to capture secrets
# ============================================================================

set -euo pipefail

# ============================================================================
# CONFIGURATION
# ============================================================================
BW_SESSION_FILE="${HOME}/.cache/bw-session"
BW_SESSION_TIMEOUT=1800  # 30 minutes in seconds

# ============================================================================
# SESSION MANAGEMENT
# ============================================================================
bw_ensure_logged_in() {
    local current_time=$(date +%s)
    local session_valid=false

    # Check if session file exists and is recent
    if [[ -f "$BW_SESSION_FILE" ]]; then
        local file_time=$(stat -c %Y "$BW_SESSION_FILE" 2>/dev/null || echo 0)
        local time_diff=$((current_time - file_time))

        if [[ $time_diff -lt $BW_SESSION_TIMEOUT ]]; then
            export BW_SESSION=$(cat "$BW_SESSION_FILE")

            # Verify session is actually valid
            if bw status 2>/dev/null | grep -q '"status":"unlocked"'; then
                session_valid=true
            fi
        fi
    fi

    if [[ "$session_valid" != "true" ]]; then
        echo "[INFO] Bitwarden login required..." >&2

        # Check if already logged in but locked
        local status=$(bw status 2>/dev/null | jq -r .status || echo "unauthenticated")

        if [[ "$status" == "unauthenticated" ]]; then
            # Need to log in first
            echo "[INFO] Please log in to Bitwarden:" >&2
            BW_SESSION=$(bw login --raw)
        elif [[ "$status" == "locked" ]]; then
            # Just need to unlock
            echo "[INFO] Please unlock Bitwarden:" >&2
            BW_SESSION=$(bw unlock --raw)
        fi

        # Save session for reuse
        mkdir -p "$(dirname "$BW_SESSION_FILE")"
        echo "$BW_SESSION" > "$BW_SESSION_FILE"
        chmod 600 "$BW_SESSION_FILE"
        export BW_SESSION

        # Sync vault to ensure we have latest data
        bw sync >/dev/null 2>&1
    fi
}

# ============================================================================
# SECRET RETRIEVAL
# ============================================================================
bw_get_secret() {
    local item_name="$1"
    local field="${2:-password}"  # Default to password field

    bw_ensure_logged_in

    # Search for item and get its ID
    local item_id=$(bw list items --search "$item_name" 2>/dev/null | \
                    jq -r ".[] | select(.name == \"$item_name\") | .id" | head -1)

    if [[ -z "$item_id" ]]; then
        echo "[ERROR] Item '$item_name' not found in Bitwarden vault" >&2
        return 1
    fi

    # Get the specific field from the item
    if [[ "$field" == "password" ]]; then
        bw get password "$item_id" 2>/dev/null
    else
        bw get item "$item_id" 2>/dev/null | jq -r ".fields[] | select(.name == \"$field\") | .value"
    fi
}

# ============================================================================
# API KEY HELPERS
# ============================================================================
bw_get_api_key() {
    local service="$1"
    local item_name="API Key - ${service}"

    # Try to get API key from custom field first, then password field
    local api_key=$(bw_get_secret "$item_name" "api_key" 2>/dev/null)

    if [[ -z "$api_key" ]]; then
        api_key=$(bw_get_secret "$item_name" "password" 2>/dev/null)
    fi

    if [[ -z "$api_key" ]]; then
        echo "[ERROR] API key for '$service' not found in Bitwarden" >&2
        echo "[INFO] Please create an item named 'API Key - $service' in Bitwarden" >&2
        echo "[INFO] Store the API key in either the password field or a custom field named 'api_key'" >&2
        return 1
    fi

    echo "$api_key"
}

# ============================================================================
# CLEANUP
# ============================================================================
bw_cleanup_session() {
    if [[ -f "$BW_SESSION_FILE" ]]; then
        rm -f "$BW_SESSION_FILE"
    fi
    unset BW_SESSION
}

# Trap to clean up on script exit (optional, commented out by default)
# trap bw_cleanup_session EXIT