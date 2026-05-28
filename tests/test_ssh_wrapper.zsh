#!/usr/bin/env zsh
set -euo pipefail

repo_root="${0:A:h:h}"
functions_dir="$repo_root/home/dot_config/zsh/functions"
mock_bin="$(mktemp -d)"
trap 'rm -rf "$mock_bin"' EXIT

cat > "$mock_bin/kitten" <<'MOCK'
#!/bin/sh
printf 'kitten:%s\n' "$*"
MOCK
chmod +x "$mock_bin/kitten"

cat > "$mock_bin/ssh" <<'MOCK'
#!/bin/sh
printf 'ssh:%s\n' "$*"
MOCK
chmod +x "$mock_bin/ssh"

runner="$mock_bin/run-ssh.zsh"
cat > "$runner" <<'RUNNER'
#!/usr/bin/env zsh
set -euo pipefail
PATH="$1"
functions_dir="$2"
fpath=("$functions_dir" $fpath)
autoload -Uz ssh
ssh babbie
RUNNER
chmod +x "$runner"

assert_eq() {
    local expected="$1"
    local actual="$2"
    local label="$3"

    if [[ "$actual" != "$expected" ]]; then
        printf 'not ok - %s\nexpected: %s\nactual:   %s\n' "$label" "$expected" "$actual" >&2
        exit 1
    fi
}

run_ssh_tty() {
    local path_value="$1"
    KITTY_WINDOW_ID=1 ZELLIJ= /usr/bin/script -qefc "/usr/bin/zsh '$runner' '$path_value' '$functions_dir'" /dev/null | tr -d '\r'
}

run_ssh_pipe() {
    local path_value="$1"
    local kitty_window_id="$2"
    local zellij="$3"

    KITTY_WINDOW_ID="$kitty_window_id" ZELLIJ="$zellij" /usr/bin/zsh "$runner" "$path_value" "$functions_dir"
}

assert_eq "kitten:ssh babbie" "$(run_ssh_tty "$mock_bin")" \
    "plain Kitty ssh uses kitten ssh"

assert_eq "ssh:babbie" "$(run_ssh_pipe "$mock_bin" 1 0)" \
    "local Zellij ssh stays on OpenSSH"

assert_eq "ssh:babbie" "$(run_ssh_pipe "$mock_bin" "" "")" \
    "non-Kitty ssh stays on OpenSSH"

rm "$mock_bin/kitten"
assert_eq "ssh:babbie" "$(run_ssh_tty "$mock_bin")" \
    "missing kitten falls back to OpenSSH"

printf 'ok - ssh wrapper routes Kitty sessions through kitten only when safe\n'
