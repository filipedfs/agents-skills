start-agent() {
  local agent="copilot"
  local branch_name=""

  # Parse arguments
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --agent)
        if [[ -n "$2" && "$2" != --* ]]; then
          agent="$2"
          shift 2
        else
          echo "Error: --agent requires a value (copilot, claude, cursor)."
          return 1
        fi
        ;;
      *)
        if [[ -z "$branch_name" ]]; then
          branch_name="$1"
          shift
        else
          echo "Error: Unexpected argument '$1'."
          return 1
        fi
        ;;
    esac
  done

  if [ -z "$branch_name" ]; then
    echo "Usage: start-agent [--agent <agent>] <branch-name>"
    return 1
  fi

  # Ensure we are inside a Git repository before proceeding
  local repo_root
  if ! repo_root=$(git rev-parse --show-toplevel 2>/dev/null); then
    echo "Error: You must run this command from inside a Git repository."
    return 1
  fi

  # Extract the repository name dynamically
  local repo_name
  repo_name=$(basename "$repo_root")

  # Define the centralized directory: ~/.worktrees/<repo-name>/<branch-name>
  local base_dir="$HOME/.worktrees/$repo_name"
  local target_dir="$base_dir/$branch_name"
  local original_dir="$PWD"

  # 1. Check if the directory already exists
  if [ -d "$target_dir" ]; then
    echo "Directory '$target_dir' already exists. Reusing existing worktree..."
  else
    # Check if the branch already exists locally
    if git show-ref --verify --quiet "refs/heads/$branch_name"; then
      echo "Branch '$branch_name' exists. Creating worktree..."
      git worktree add "$target_dir" "$branch_name"
    else
      echo "Branch '$branch_name' does not exist. Creating new branch and worktree..."
      git worktree add "$target_dir" -b "$branch_name"
    fi
  fi

  # 2. Navigate into the worktree
  cd "$target_dir" || return

  # 3. Launch the selected agent
  case "$agent" in
    copilot)
      copilot \
        --agent orchestrator \
        --allow-tool 'shell(grep)' \
        --allow-tool 'shell(cat)' \
        --allow-tool 'shell(mkdir)' \
        --allow-tool 'shell(ls)' \
        --allow-tool 'shell(find)' \
        --allow-tool 'shell(fvm flutter analyze)' \
        --allow-tool 'shell(fvm flutter test)' \
        --allow-tool 'shell(fvm flutter gen l10n)'
      ;;
    claude)
      claude
      ;;
    gemini)
      gemini
      ;;
    cursor)
      cursor .
      ;;
    *)
      echo "Error: Unknown agent '$agent'."
      cd "$original_dir" || return
      return 1
      ;;
  esac

  # 4. Check for uncommitted changes
  local has_changes=false
  if [ -n "$(git status --porcelain)" ]; then
    has_changes=true
  fi

  # 5. Return to the original directory
  cd "$original_dir" || return

  # 6. Prompt for removal
  echo ""
  local confirm

  if [ "$has_changes" = true ]; then
    echo "⚠️  WARNING: You have uncommitted changes in the worktree!"
    printf "Do you want to FORCE remove the worktree and LOSE those changes? (y/N): "
    read -r confirm
  else
    echo "Worktree is clean."
    printf "Do you want to remove the worktree directory? (The branch will NOT be deleted) (y/N): "
    read -r confirm
  fi

  # 7. Handle removal and cleanup
  if [[ "$confirm" =~ ^[Yy]$ ]]; then
    if [ "$has_changes" = true ]; then
      git worktree remove --force "$target_dir"
    else
      git worktree remove "$target_dir"
    fi
    echo "✅ Worktree removed successfully."

    # Clean up lingering empty parent directories (e.g., the 'feature' folder)
    if [ -d "$base_dir" ]; then
      find "$base_dir" -type d -empty -delete 2>/dev/null
    fi
  else
    echo "ℹ️  Worktree kept at '$target_dir'."
  fi
}

