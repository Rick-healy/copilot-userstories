#!/bin/bash
#
# Script to initialize a Git repository and push it to GitHub
#
# This script performs the following tasks:
# 1. Initializes the current folder as a git repo with a 'main' branch
# 2. Creates a README.md file with an optional user-provided summary (only if it doesn't exist)
# 3. Stages all current files and subfolders
# 4. Commits changes with a default message
# 5. Creates a repository in the user's GitHub account
# 6. Pushes all local changes to the remote repository

# Clear the screen for better readability
clear

# Function to check if a command exists
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# Check for required tools
if ! command_exists git; then
  echo "Error: Git is not installed. Please install Git and try again."
  exit 1
fi

if ! command_exists gh; then
  echo "Error: GitHub CLI is not installed. Please install it and try again."
  exit 1
fi

# Get the current directory name to use as the default repository name
repo_name=$(basename "$(pwd)")
echo -e "\033[36mUsing '$repo_name' as the repository name...\033[0m"

# Check if user is authenticated with GitHub CLI
echo -e "\033[36mChecking GitHub CLI authentication status...\033[0m"
if ! gh auth status 2>/dev/null; then
  echo -e "\033[33mYou need to authenticate with GitHub CLI first.\033[0m"
  echo -e "\033[36mRunning 'gh auth login'...\033[0m"
  gh auth login
  if [ $? -ne 0 ]; then
    echo "Error: GitHub CLI authentication failed. Please try again."
    exit 1
  fi
fi

# Step 1: Initialize git repository with main branch
echo -e "\033[32m1. Initializing git repository with main branch...\033[0m"
git init
git checkout -b main

# Step 2: Create README.md with optional summary (only if it doesn't exist already)
if [ ! -f "README.md" ]; then
  echo -e "\033[32m2. Creating README.md file...\033[0m"
  echo -n "Enter a summary for the README (leave blank for default): "
  read summary

  if [ -z "$summary" ]; then
    summary="# $repo_name\n\nThis is a README file for the $repo_name repository."
  else
    summary="# $repo_name\n\n$summary"
  fi

  echo -e "$summary" > README.md
else
  echo -e "\033[33m2. README.md already exists. Skipping creation...\033[0m"
fi

# Step 3: Stage all files
echo -e "\033[32m3. Staging all files in the repository...\033[0m"
git add .

# Step 4: Commit changes
echo -e "\033[32m4. Committing changes...\033[0m"
git commit -m "Initial changes"

# Step 5: Create GitHub repository
echo -e "\033[32m5. Creating GitHub repository...\033[0m"
echo -n "Create repository under organization account? (y/n, default: n): "
read account_type

if [[ "$account_type" == "y" || "$account_type" == "Y" ]]; then
  echo -n "Enter organization name: "
  read org_name
  echo -e "\033[36mCreating repository $repo_name under organization $org_name...\033[0m"
  gh repo create "$org_name/$repo_name" --private --source=. --remote=origin --push
else
  echo -e "\033[36mCreating repository $repo_name under your personal account...\033[0m"
  gh repo create "$repo_name" --private --source=. --remote=origin --push
fi

if [ $? -ne 0 ]; then
  echo "Error: Failed to create GitHub repository. Please check your GitHub access and try again."
  exit 1
fi

# Step 6: Push changes to remote repository
echo -e "\033[32m6. Pushing changes to remote repository...\033[0m"
git push -u origin main

echo -e "\n\033[32mRepository initialization complete! Your local repository is now connected to GitHub.\033[0m"
echo -e "\033[36mRepository URL: $(gh repo view --json url -q '.url')\033[0m"