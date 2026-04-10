#!/bin/bash

# Target directories
TARGET_DIR="$HOME/.agents-skills/functions"
CLAUDE_SKILLS_DIR="$HOME/.claude/skills"
CLAUDE_AGENTS_DIR="$HOME/.claude/agents"
COPILOT_AGENTS_DIR="$HOME/.copilot/agents"
COPILOT_SKILLS_DIR="$HOME/.copilot/skills"

# Create a directory if it doesn't exist
ensure_dir() {
  local dir="$1"
  echo "Creating directory $dir..."
  mkdir -p "$dir"
}

# Copy files from a source directory to a target directory
# Usage: copy_files <source_dir> <target_dir> [cp_flags]
copy_files() {
  local src="$1"
  local dest="$2"
  local flags="${3:--v}"

  echo "Copying $src to $dest..."
  if [ -d "$src" ]; then
    cp $flags "$src"/* "$dest/" 2>/dev/null || cp $flags "$src"/* "$dest/"
  else
    echo "Source directory $src not found. Skipping..."
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
      echo "Snippet already exists in $rc_file. Skipping..."
    else
      echo "Adding snippet to $rc_file..."
      echo "$SNIPPET" >> "$rc_file"
    fi
  else
    echo "File $rc_file not found. Skipping..."
  fi
}

# Create all target directories
ensure_dir "$TARGET_DIR"
ensure_dir "$CLAUDE_SKILLS_DIR"
ensure_dir "$CLAUDE_AGENTS_DIR"
ensure_dir "$COPILOT_AGENTS_DIR"
ensure_dir "$COPILOT_SKILLS_DIR"

# Install files to their target directories
copy_files "functions" "$TARGET_DIR"
copy_files "skills" "$CLAUDE_SKILLS_DIR" "-rv"
copy_files "agents" "$CLAUDE_AGENTS_DIR"
copy_files "agents" "$COPILOT_AGENTS_DIR"
copy_files "skills" "$COPILOT_SKILLS_DIR" "-rv"

# Add shell integration snippet to .zshrc and .bashrc
add_to_rc "$HOME/.zshrc"
add_to_rc "$HOME/.bashrc"

echo "Installation complete! Please restart your terminal or run 'source ~/.zshrc' or 'source ~/.bashrc' to load the functions."
