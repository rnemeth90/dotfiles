#!/usr/bin/env bash

# This script will be used to remove the following lines from all helm values files in all subdirectories:
# image:
#   repository: prod02registry02acr.azurecr.io/aprimo/pxpscoring
# This script will take a list of directories as arguments and process all files named values.yaml in those directories.

COMMIT_CHANGES=false
DRY_RUN=false

while [[ "$1" == --* ]]; do
  case "$1" in
    --commit) COMMIT_CHANGES=true ;;
    --dry-run) DRY_RUN=true ;;
  esac
  shift
done

# We first need to create a git branch in the directory
create_branch() {
  local branch_name="wip/522977"
  
  if git rev-parse --verify "$branch_name" >/dev/null 2>&1; then
    git checkout "$branch_name"
  else
    git checkout -b "$branch_name"
  fi
}

# Verify we are on the develop branch and do a git pull
verify_develop_branch() {
  local current_branch
  current_branch=$(git rev-parse --abbrev-ref HEAD)
  
  if [[ "$current_branch" != "develop" ]]; then
    echo "You are not on the develop branch. Attempting to switch to develop."
    git checkout develop
    # exit 1
  fi
  
  git pull origin develop
}

# Git add the chagnes and commit them, then do a git push
create_commit_and_push() {
  local commit_message="Update container repository"
  
  git add .
  git commit -m "$commit_message"
  git push origin "$(git rev-parse --abbrev-ref HEAD)"
}

# cd into the directory passed in as arguments and create a branch
cd_to_directory() {
  local dir="$1"

  if [[ -d "$dir" ]]; then
    cd "$dir" || exit
    if [[ ! -d .git ]]; then
      echo "No git repository in $dir. Skipping."
      return 1
    fi
  else
    echo "Directory not found: $dir"
    return 1
  fi
}

remove_lines() {
  local file="$1"
  if [[ -f "$file" ]]; then
    if $DRY_RUN; then
      echo "Would process file: $file"
      return 0
    else
      echo "Processing file: $file"
      sed -i '' '/image:/d' $file
      sed -i '' '/repository:/d' $file
    fi
  else
    echo "File not found: $file"
  fi
}

update_build() {
  local file="$1"
  if [[ -f "$file" ]]; then
    if $DRY_RUN; then
      echo "Would process file: $file"
      return 0
    else
      echo "Processing file: $file"
      sed -i '' 's/prod02registry02acr/prod02registry01acr/g' $file
      sed -i '' 's/Personify/Aprimo/g' $file
    fi
  else
    echo "File not found: $file"
  fi
}

# Main script execution
main() {
  for dir in "$@"; do
    cd_to_directory "$dir" || continue

    verify_develop_branch
    create_branch
    
    # find all values.yaml files in the current directory and its subdirectories
    find . -type f -name '*.values.yaml' | while read -r file; do
      remove_lines "$file"
    done

    # find all values.yaml files in the current directory and its subdirectories
    find . -type f -name 'build.yaml' | while read -r file; do
      update_build "$file"
    done

    if $COMMIT_CHANGES; then
      create_commit_and_push
    fi
  done
}

# Check if at least one directory is provided
if [[ $# -lt 1 ]]; then
  echo "Usage: $0 <directory1> <directory2> ..."
  exit 1
fi

# Call the main function with all script arguments
main "$@"

if $DRY_RUN; then
  echo "Dry run complete. No files were modified."
elif $COMMIT_CHANGES; then
  echo "All changes have been committed and pushed."
else
  echo "Changes have been made and staged, but not committed. Run with --commit to push changes."
fi
