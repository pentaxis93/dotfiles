# Changelog

All notable changes to these dotfiles will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project uses date-based versioning (YYYY.MM.DD).

## [2025.09.16] - Today

### Changed
- Replaced Starship prompt with Pure prompt for better async performance
- Updated bootstrap scripts to reflect Pure prompt usage

### Removed
- Starship prompt completely removed from system
- Removed all Starship references from documentation

## [2024.12.14] - Previous

### Added
- Complete Gruvbox Dark Hard color definitions for Alacritty (search, hints, footer_bar)
- README.md with comprehensive installation instructions
- CHANGELOG.md for tracking changes
- Extended troubleshooting section in CLAUDE.md

### Fixed
- SSH authorized_keys permissions changed from 755 to 600 (critical security fix)

### Security
- Fixed overly permissive SSH authorized_keys file permissions

## [2024.09.14] - Recent Updates

### Added
- Polybar auto-hide daemon for immersive video watching
- Comprehensive documentation best practices section in CLAUDE.md
- MPV configuration with Gruvbox theme
- Tool configurations (gh, lazygit, bat) without secrets
- Arrow and numpad key support in sxhkd
- Secure .gitignore covering all sensitive patterns

### Changed
- Volume and brightness intervals changed to 10% for better granularity
- Fish startup optimized by 35% with selective config loading

### Fixed
- Brightness control with well-documented sudoers approach
- Polybar-autohide workspace detection
- Robust error handling in polybar launch script

## [2024.09.13] - Initial Setup

### Added
- BSPWM window manager configuration
- SXHKD hotkey daemon setup
- Fish shell configuration with dots function
- Alacritty terminal with Gruvbox theme
- Helix editor configuration
- Shell prompt configuration (initially Starship, now Pure)
- Polybar status bar
- Custom scripts for brightness control
- CLAUDE.md for AI assistant context

### Notes
- Initial migration from previous setup
- Established bare Git repository pattern for dotfiles management
- Implemented Gruvbox Dark Hard theme system-wide