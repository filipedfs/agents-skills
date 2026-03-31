#!/bin/bash

# Target directory for the functions
TARGET_DIR="$HOME/.agents-skills/functions"
CLAUDE_SKILLS_DIR="$HOME/.claude/skills"

# Create the target directory if it doesn't exist
echo "Creating directory $TARGET_DIR..."
mkdir -p "$TARGET_DIR"

echo "Creating directory $CLAUDE_SKILLS_DIR..."
mkdir -p "$CLAUDE_SKILLS_DIR"

# Copy all files from the local functions/ directory to the target directory
echo "Copying functions to $TARGET_DIR..."
cp -v functions/*.zsh "$TARGET_DIR/" 2>/dev/null || cp -v functions/* "$TARGET_DIR/"

# Copy all skills from the local skills/ directory to the claude skills directory
echo "Copying skills to $CLAUDE_SKILLS_DIR..."
if [ -d "skills" ]; then
  cp -rv skills/* "$CLAUDE_SKILLS_DIR/"
fi

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

# Function to add the snippet to a file
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

# Add the snippet to .zshrc and .bashrc
add_to_rc "$HOME/.zshrc"
add_to_rc "$HOME/.bashrc"

echo "Installation complete! Please restart your terminal or run 'source ~/.zshrc' or 'source ~/.bashrc' to load the functions."
