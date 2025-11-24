# Flutter/Dart Development with FVM

## Ultra-Zen Philosophy
**"Language foundation lives in dotfiles; project specifics manifest per-repository"**

## Architecture
- **FVM (Flutter Version Manager)** - Version manager for Flutter SDK
- **Global Default** - Makes `dart` and `flutter` commands available everywhere
- **Per-Project Override** - Projects specify their own Flutter versions via `.fvm/fvm_config.json`
- **Fish PATH Integration** - Automatic shell integration for seamless command access
- **Dotfiles Foundation** - Language toolchain managed in dotfiles, not per-project

## Philosophy: Foundation vs Project Tooling

### ✅ Dotfiles Layer (Foundation)
What belongs in this chezmoi configuration:
- **fvm installation** - The version manager itself
- **Global default Flutter version** - System-wide `dart` and `flutter` commands
- **PATH configuration** - Shell integration for command availability
- **Bootstrap script** - Automated installation on fresh systems

### ✅ Project Layer (Specifics)
What stays in individual Flutter projects:
- **Per-project Flutter versions** - `.fvm/fvm_config.json` overrides global default
- **Dependencies** - `pubspec.yaml` and `pubspec.lock`
- **Project-specific tooling** - Melos, build_runner, code generation packages
- **Development dependencies** - Test frameworks, linters, formatters

### Why This Separation Works
1. **Zero Friction** - New terminal → `dart --version` just works
2. **Project Autonomy** - Each project controls its own Flutter version
3. **Global Utilities** - `pub global activate` packages available everywhere
4. **YAGNI Compliance** - Foundation is minimal; complexity lives in projects

## Configuration Files
- **Installation Script**: `home/run_once_install-fvm.sh.tmpl` - Automated fvm setup
- **Fish PATH**: `home/dot_config/fish/config.fish.tmpl` - Shell integration
- **Documentation**: `docs/ai-context/apps/flutter.md` - This file

## Installation Flow

### What Happens on `chezmoi apply`
1. **Script Execution**: `run_once_install-fvm.sh.tmpl` runs automatically
2. **FVM Installation**: Downloads and installs fvm to `~/.fvm/bin/`
3. **Flutter Download**: Installs stable Flutter version to `~/.fvm/versions/`
4. **Global Default**: Sets `~/.fvm/default` symlink to stable version
5. **PATH Setup**: Fish config adds fvm paths to shell environment

### Manual Installation (if needed)
```bash
# If fvm installation script fails, manual fallback:
pub global activate fvm
fvm install stable
fvm global stable

# Or use standalone installer:
curl -fsSL https://fvm.app/install.sh | bash
```

## Usage

### System-Wide Commands
After chezmoi apply and shell restart:
```bash
dart --version                  # Dart SDK from global Flutter version
flutter --version               # Global Flutter version
flutter doctor                  # Check Flutter installation

pub global activate <package>   # Install global Dart packages
pub global list                 # List global packages
```

### Project-Specific Usage
In Flutter projects with `.fvm/fvm_config.json`:
```bash
cd my-flutter-project
fvm use 3.24.0                  # Set project-specific version
fvm flutter run                 # Use project's Flutter version
fvm dart analyze                # Use project's Dart SDK

# Or configure IDE to use .fvm/flutter_sdk symlink
```

### FVM Management Commands
```bash
fvm list                        # List installed Flutter versions
fvm install <version>           # Install specific Flutter version
fvm global <version>            # Change global default version
fvm releases                    # List available Flutter releases
fvm remove <version>            # Remove installed version
```

## PATH Structure

After installation, these directories are in PATH:
```bash
~/.fvm/default/bin/             # flutter, dart commands (global version)
~/.pub-cache/bin/               # pub global packages
```

Project-specific override happens via:
```bash
.fvm/flutter_sdk/bin/           # Symlink to project-specific version
```

## Directory Structure
```
~/.fvm/
├── bin/                        # fvm executable
├── versions/                   # Installed Flutter versions
│   ├── stable/                 # Stable channel
│   ├── 3.24.0/                 # Specific versions
│   └── beta/                   # Beta channel (if installed)
├── default -> versions/stable/ # Global default symlink
└── fvm_config.json             # Global fvm configuration

~/.pub-cache/
├── bin/                        # Global Dart packages
└── hosted/                     # Package downloads
```

## Benefits

### For Dotfiles
- **Predictable Foundation** - `dart` and `flutter` always available
- **Fresh System Setup** - One command (`chezmoi apply`) gets everything
- **YAGNI Compliant** - Minimal configuration, maximum utility
- **Shell Integration** - Works immediately without manual PATH setup

### For Projects
- **Version Isolation** - Each project pins its Flutter version
- **Team Consistency** - `.fvm/fvm_config.json` committed to git
- **CI/CD Integration** - Build systems use project's Flutter version
- **Safe Upgrades** - Test new Flutter versions per-project

### For Development
- **Zero Context Switching** - Same commands everywhere (`flutter`, `dart`)
- **Global Tools** - Utilities like `melos`, `very_good_cli` available system-wide
- **IDE Integration** - VS Code/IntelliJ recognize both global and project versions
- **Quick Scripts** - Dart scripts run with global SDK, no per-project setup

## Troubleshooting

### `dart: command not found`
```bash
# Check PATH configuration
echo $PATH | grep -o '[^:]*fvm[^:]*'

# Should show: ~/.fvm/default/bin

# Restart shell to reload PATH
exec fish

# Verify fvm installation
which fvm
fvm list
```

### FVM Not Installing Flutter
```bash
# Check fvm logs
fvm install stable --verbose

# Manual Flutter cache clear
rm -rf ~/.fvm/versions/stable
fvm install stable

# Check network connectivity (Flutter downloads from googleapis)
ping -c 3 storage.googleapis.com
```

### Project Override Not Working
```bash
# In project directory:
cat .fvm/fvm_config.json     # Should specify "flutterSdkVersion"

# Recreate symlink
fvm use <version>

# Check symlink
ls -la .fvm/flutter_sdk
```

### Global Packages Not Found
```bash
# Ensure pub-cache/bin is in PATH
echo $PATH | grep pub-cache

# Reinstall global package
pub global activate <package>

# List installed globals
pub global list
```

## Integration with Helix Editor

Helix LSP configuration for Dart/Flutter projects:

### Global Dart LSP (from fvm default)
Helix automatically finds `dart` in PATH and uses its LSP.

### Project-Specific Override
Add to project `.helix/languages.toml`:
```toml
[[language]]
name = "dart"
language-servers = ["dart"]

[language-server.dart]
command = ".fvm/flutter_sdk/bin/dart"
args = ["language-server", "--protocol=lsp"]
```

This ensures Helix uses the project's Flutter version, not the global one.

## Architecture Decision Rationale

### Why fvm over system packages?
- **Version Control** - Projects need different Flutter versions
- **Frequent Updates** - Flutter releases monthly, system packages lag
- **Channel Management** - Stable, beta, master channels per-project
- **Global Tooling** - System-wide utilities without polluting projects

### Why global default?
- **Zero Friction** - Terminal commands work immediately
- **Script Execution** - Dart scripts run without project context
- **Global Packages** - Tools like `melos`, `very_good_cli` available everywhere
- **Testing** - Quick prototypes without project setup

### Why PATH in dotfiles?
- **Automatic Setup** - Works on fresh systems after `chezmoi apply`
- **Shell Consistency** - Same behavior across all terminal sessions
- **No Manual Steps** - Users don't need to remember to configure PATH
- **Follows Patterns** - Matches Go, Node.js, Python toolchain setup

---

*"The river of code flows from a single source; each tributary may diverge, yet all draw from the same wellspring."*
