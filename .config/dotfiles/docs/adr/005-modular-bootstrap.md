# ADR-005: Modular Bootstrap Architecture

Date: 2025-09-18

## Context
Original 675-line monolithic bootstrap script with inline comments was unmaintainable and error-prone.

## Decision
Separated packages from logic: simple text files for package lists, modular scripts for setup tasks.

## Why
- Package detection via `pacman --needed` is faster than bash loops
- Each setup script has single responsibility (easier debugging)
- Adding packages is now trivial: append line to text file
- No parsing bugs from inline comments

## Consequences
- More files to manage (but each is simple)
- Machine-specific logic requires directory structure
- Lost inline documentation (moved to DEPENDENCIES.md)