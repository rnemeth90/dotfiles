#!/usr/bin/env python3

from github import Github
import subprocess
import argparse
import os
import sys

parser = argparse.ArgumentParser(description="")
parser.add_argument("--repos", help="A comma-separated list of repositories")
parser.add_argument("--default_branch", nargs="?", default="wip/491082", help="The default branch to checkout (default: develop)")
parser.add_argument("--src", help="The source files to copy")
parser.add_argument("--dst", help="The destination directory to copy files to", nargs="?",default="tools")
parser.add_argument("--commit_message", help="The commit message", nargs="?",default="chore: add versioning scripts")
args = parser.parse_args()

print("Arguments received:")
print(f"Repos: {args.repos}")
print(f"Default Branch: {args.default_branch}")
print(f"Source: {args.src}")
print(f"Destination: {args.dst}")

# Write a function to create a pull request for each repository
def create_pull_request(repo, branch_name, src, dst, commit_message):
    print(f"Creating pull request for {repo} on branch {branch_name} with source {src} and destination {dst}")
    # This function would contain the logic to create a pull request using the GitHub API or similar
    # For example, you might use the PyGithub library to create a pull request

    github.token = os.getenv("GITHUB_TOKEN")
    g = Github(github.token)
    repository = g.get_repo(repo)
    try:
        # Create a new branch for the pull request
        repo_branch = repository.get_branch(branch_name)
    except Exception as e:
        print(f"Error: Could not find branch '{branch_name}' in repository '{repo}': {e}", file=sys.stderr)
        return

    
    # For now, we will just print the details
    print(f"Pull request created for {repo} with commit message: '{commit_message}'")


def main():
    local_repositories = args.repos.split(",")
    for repo in local_repositories:
        if not os.path.isdir(repo):
            print(f"Error: Repository directory '{repo}' does not exist.", file=sys.stderr)
            continue

        git_checkout(repo, args.default_branch)
        copy_files(repo, args.src, args.dst)
        git_commit_and_push(repo, args.commit_message)


def git_checkout(repo, branch_name):
    try:
        subprocess.run(["git", "checkout", "-b", branch_name], cwd=repo, check=True)
    except subprocess.CalledProcessError:
        print(f"Error: Failed to checkout branch '{branch_name}' in '{repo}'", file=sys.stderr)
        sys.exit(1)

def copy_files(repo, src, dst):
    src_path = os.path.join(repo, src)
    dst_path = os.path.join(repo, dst)

    if not os.path.exists(src_path):
        print(f"Warning: Source directory '{src_path}' does not exist. Skipping copy.", file=sys.stderr)
        return

    os.makedirs(dst_path, exist_ok=True)

    try:
        subprocess.run(f"cp -R {src_path}/* {dst_path}/", shell=True, check=True, executable="/bin/bash")
    except subprocess.CalledProcessError as e:
        print(f"Error: Failed to copy files from {src_path}/* to {dst_path}: {e}", file=sys.stderr)
        sys.exit(1)

def git_commit_and_push(repo, commit_message):
    try:
        subprocess.run(["git", "add", "."], cwd=repo, check=True)
        subprocess.run(["git", "commit", "-m", commit_message], cwd=repo, check=True)
        subprocess.run(["git", "push"], cwd=repo, check=True)
    except subprocess.CalledProcessError:
        print(f"Error: Git commit/push failed in '{repo}'", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
