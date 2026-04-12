#!/bin/bash

# Colored logging helpers
if [ -t 1 ]; then
  COLOR_SUCCESS="\033[0;32m"
  COLOR_WARN="\033[1;33m"
  COLOR_ERROR="\033[0;31m"
  COLOR_RESET="\033[0m"
else
  COLOR_SUCCESS=""
  COLOR_WARN=""
  COLOR_ERROR=""
  COLOR_RESET=""
fi

log_success() {
  printf "${COLOR_SUCCESS}[SUCCESS]${COLOR_RESET} %s\n" "$1"
}

log_warn() {
  printf "${COLOR_WARN}[WARN]${COLOR_RESET} %s\n" "$1"
}

log_error() {
  printf "${COLOR_ERROR}[ERROR]${COLOR_RESET} %s\n" "$1" >&2
}

# Target directories
TARGET_DIR="$HOME/.agents-skills/functions"
CLAUDE_SKILLS_DIR="$HOME/.claude/skills"
CLAUDE_AGENTS_DIR="$HOME/.claude/agents"
COPILOT_AGENTS_DIR="$HOME/.copilot/agents"
COPILOT_SKILLS_DIR="$HOME/.copilot/skills"
CLAUDE_RULES_DIR="$HOME/.claude/rules"
COPILOT_RULES_DIR="$HOME/.copilot/rules"

# Create a directory if it doesn't exist
ensure_dir() {
  local dir="$1"
  if mkdir -p "$dir"; then
    log_success "Directory ready: $dir"
  else
    log_error "Failed to create directory: $dir"
  fi
}

# Copy files from a source directory to a target directory
# Usage: copy_files <source_dir> <target_dir> [cp_flags]
copy_files() {
  local src="$1"
  local dest="$2"
  local flags="${3:--v}"

  if [ -d "$src" ]; then
    if compgen -G "$src/*" > /dev/null; then
      if cp $flags "$src"/* "$dest/" 2>/dev/null || cp $flags "$src"/* "$dest/"; then
        log_success "Copied $src to $dest"
      else
        log_error "Failed to copy $src to $dest"
      fi
    else
      log_warn "Source directory $src is empty. Skipping..."
    fi
  else
    log_warn "Source directory $src not found. Skipping..."
  fi
}

# Snippet to add to shell configuration files
SNIPPET_HEADER="# Load all custom agents-skills functions"
SNIPPET="
$SNIPPET_HEADER
if [ -d \"\$HOME/.agents-skills/functions\" ]; then
  for func_file in \"\$HOME/.agents-skills/functions\"/*.zsh; do
    source \"\$func_file\"
  done
fi
"

# Add the snippet to a shell rc file
add_to_rc() {
  local rc_file="$1"
  if [ -f "$rc_file" ]; then
    if grep -Fq "$SNIPPET_HEADER" "$rc_file"; then
      log_warn "Snippet already exists in $rc_file. Skipping..."
    else
      if echo "$SNIPPET" >> "$rc_file"; then
        log_success "Added snippet to $rc_file"
      else
        log_error "Failed to add snippet to $rc_file"
      fi
    fi
  else
    log_warn "File $rc_file not found. Skipping..."
  fi
}

# Create all target directories
ensure_dir "$TARGET_DIR"
ensure_dir "$CLAUDE_SKILLS_DIR"
ensure_dir "$CLAUDE_AGENTS_DIR"
ensure_dir "$COPILOT_AGENTS_DIR"
ensure_dir "$COPILOT_SKILLS_DIR"
ensure_dir "$CLAUDE_RULES_DIR"
ensure_dir "$COPILOT_RULES_DIR"

# Install files to their target directories
copy_files "functions" "$TARGET_DIR"
copy_files "skills" "$CLAUDE_SKILLS_DIR" "-rv"
copy_files "agents" "$CLAUDE_AGENTS_DIR"
copy_files "agents" "$COPILOT_AGENTS_DIR"
copy_files "skills" "$COPILOT_SKILLS_DIR" "-rv"
copy_files "rules" "$CLAUDE_RULES_DIR"
copy_files "rules" "$COPILOT_RULES_DIR"

# Add shell integration snippet to .zshrc and .bashrc
add_to_rc "$HOME/.zshrc"
add_to_rc "$HOME/.bashrc"

log_success "Installation complete! Restart your terminal or run 'source ~/.zshrc' or 'source ~/.bashrc' to load the functions."
