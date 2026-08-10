#!/usr/bin/env bash

set -Eeuo pipefail

readonly dir="$(dirname "$0")"

usage() {
  cat >&2 <<USAGE
Usage: $(basename "$0") [OPTIONS]

Description:
  Find all pipeline YAML files referencing the helm repository
  (either adam/helm.git on ADO or aprimo-org/helm on GitHub),
  then for each git repo: stash changes, checkout default branch, pull,
  create a wip/601095 branch, add the ref line, commit, and push.

  Skips any repos under "personify" directories.

Options:
  -v        Enable verbose output
  -d        Dry run (show what would be done without making changes)
  -h        Show this help message
USAGE
  exit 1
}

verbose=""
dry_run=""

while getopts "hvd" OPT; do
  case "${OPT}" in
    h) usage ;;
    v) verbose=true ;;
    d) dry_run=true ;;
    *) usage ;;
  esac
done
shift $((OPTIND - 1))

BRANCH_NAME="wip/601095"
REF_VALUE="refs/heads/${BRANCH_NAME}"
SEARCH_DIRS=(
  "$HOME/repos/aprimo"
  "$HOME/repos/github.com/rnemeth_aprimo"
)

# Patterns to match helm repo references
HELM_NAME_PATTERNS=(
  "name: adam/helm.git"
  "name: aprimo-org/helm"
)

log() {
  echo "[INFO] $*"
}

logv() {
  if [ "$verbose" = "true" ]; then
    echo "[VERBOSE] $*"
  fi
}

warn() {
  echo "[WARN] $*" >&2
}

err() {
  echo "[ERROR] $*" >&2
}

add_ref_line() {
  local file="$1"
  local pattern="$2"

  # Check if a ref line already exists right after the name line
  if grep -A1 "$pattern" "$file" | grep -q "ref:"; then
    logv "Updating existing ref line in $file"
    local escaped
    escaped=$(echo "$pattern" | sed 's/[\/\.]/\\&/g')
    perl -i -0pe "s/(${escaped}\\s*\\n\\s*ref: refs\\/heads\\/)\\S+/\${1}wip\\/601095/" "$file"
  else
    logv "Adding ref line to $file"
    local escaped
    escaped=$(echo "$pattern" | sed 's/[\/\.]/\\&/g')
    perl -i -pe "if (/^(\\s*)(${escaped})\\s*\$/) { \$indent = \$1; \$_ .= \"\${indent}ref: refs/heads/wip/601095\\n\" }" "$file"
  fi
}

process_repo() {
  local repo="$1"
  local stashed=false

  log "Processing: $repo"

  cd "$repo"

  # Stash any uncommitted changes
  if ! git diff --quiet HEAD 2>/dev/null || [ -n "$(git ls-files --others --exclude-standard)" ]; then
    log "Stashing uncommitted changes"
    if [ "$dry_run" = "true" ]; then
      logv "Would stash changes"
    else
      git stash push -m "auto-stash before add-helm-ref" --include-untracked
      stashed=true
    fi
  fi

  # Determine default branch
  local default_branch
  default_branch=$(git remote show origin 2>/dev/null | awk '/HEAD branch/ {print $NF}')
  if [ -z "$default_branch" ]; then
    warn "Could not determine default branch for $repo, skipping"
    return 1
  fi
  logv "Default branch: $default_branch"

  if [ "$dry_run" = "true" ]; then
    log "Would: checkout $default_branch, pull, create $BRANCH_NAME, modify files, commit, push"
    # Find files that would be modified
    for pattern in "${HELM_NAME_PATTERNS[@]}"; do
      local files
      files=$(grep -rl "$pattern" "$repo" --include="*.yaml" --include="*.yml" 2>/dev/null || true)
      for f in $files; do
        logv "Would modify ($pattern): $f"
      done
    done
    return 0
  fi

  # Checkout default branch and pull
  git checkout "$default_branch"
  git pull

  # Create new branch
  if git show-ref --verify --quiet "refs/heads/$BRANCH_NAME" 2>/dev/null; then
    warn "Branch $BRANCH_NAME already exists in $repo, skipping"
    if [ "$stashed" = "true" ]; then
      git stash pop || true
    fi
    return 1
  fi
  git checkout -b "$BRANCH_NAME"

  # Find and modify pipeline files in this repo
  local modified=false

  for pattern in "${HELM_NAME_PATTERNS[@]}"; do
    local files
    files=$(grep -rl "$pattern" "$repo" --include="*.yaml" --include="*.yml" 2>/dev/null || true)
    for f in $files; do
      add_ref_line "$f" "$pattern"
      modified=true
      log "Modified: $f"
    done
  done

  if [ "$modified" = "true" ]; then
    git add -A
    git commit -m "Add helm chart ref for $BRANCH_NAME"
    if timeout 30 git push -u origin "$BRANCH_NAME"; then
      log "Pushed $BRANCH_NAME for $repo"
    else
      warn "Push failed for $repo (permission denied or timeout)"
    fi
  else
    warn "No files modified in $repo"
  fi
}

main() {
  local repo_roots=()

  # Find all YAML files referencing helm repos, get their repo roots
  for search_dir in "${SEARCH_DIRS[@]}"; do
    if [ ! -d "$search_dir" ]; then
      warn "Directory not found: $search_dir"
      continue
    fi

    for pattern in "${HELM_NAME_PATTERNS[@]}"; do
      while IFS= read -r file; do
        # Skip personify directories
        if [[ "$file" == *"/personify/"* ]]; then
          logv "Skipping (personify): $file"
          continue
        fi

        local repo_root
        repo_root=$(git -C "$(dirname "$file")" rev-parse --show-toplevel 2>/dev/null) || continue
        repo_roots+=("$repo_root")
      done < <(grep -rl "$pattern" "$search_dir" --include="*.yaml" --include="*.yml" 2>/dev/null || true)
    done
  done

  # Deduplicate repo roots
  local unique_repos=()
  while IFS= read -r r; do
    unique_repos+=("$r")
  done < <(printf '%s\n' "${repo_roots[@]}" | sort -u)

  log "Found ${#unique_repos[@]} repositories to process"

  local success=0 failed=0

  for repo in "${unique_repos[@]}"; do
    if process_repo "$repo"; then
      ((success++))
    else
      ((failed++))
    fi
  done

  echo ""
  log "Done. Success: $success, Skipped/Failed: $failed"
}

main "$@"
