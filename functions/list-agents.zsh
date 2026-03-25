list-agents() {
  local base_dir="$HOME/.worktrees"
  
  # Check if the root directory exists
  if [ ! -d "$base_dir" ]; then
    echo "No active agents found. ($base_dir does not exist yet)"
    return 0
  fi

  echo "🔍 Active CLI Agents (Worktrees):"
  echo "--------------------------------------------------------"
  
  local found=false
  
  # Find all .git files (which indicate a worktree) and parse their paths
  while IFS= read -r git_file; do
    found=true
    
    # Get the folder containing the .git file
    local wt_dir
    wt_dir=$(dirname "$git_file")
    
    # Strip the base directory path to get just 'repo-name/branch-name'
    local relative_path="${wt_dir#$base_dir/}"
    
    # Extract the repository name (everything before the first slash)
    local repo_name="${relative_path%%/*}"
    
    # Extract the branch name (everything after the first slash)
    local branch_name="${relative_path#*/}"
    
    # Print in a neatly aligned format
    printf "📦 %-20s -> 🌿 %s\n" "$repo_name" "$branch_name"
    
  done < <(find "$base_dir" -type f -name ".git" 2>/dev/null)

  if [ "$found" = false ]; then
    echo "No active worktrees currently running."
  fi
  echo "--------------------------------------------------------"
}
