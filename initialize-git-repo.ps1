#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Initializes a Git repository, creates a README file, and pushes to GitHub.
.DESCRIPTION
    This script performs the following tasks:
    1. Initializes the current folder as a git repo with a 'main' branch
    2. Creates a README.md file with an optional user-provided summary (only if it doesn't exist already)
    3. Stages all current files and subfolders
    4. Commits changes with a default message
    5. Creates a repository in the user's GitHub account
    6. Pushes all local changes to the remote repository
.PARAMETER summary
    An optional summary for the README.md file.
.EXAMPLE
    ./initialize-git-repo.ps1
#>

# Clear the screen for better readability
Clear-Host

# Function to check if a command exists
function Test-CommandExists {
    param ($command)
    $exists = $null -ne (Get-Command $command -ErrorAction SilentlyContinue)
    return $exists
}

# Check for required tools
if (-not (Test-CommandExists "git")) {
    Write-Error "Git is not installed. Please install Git and try again."
    exit 1
}

if (-not (Test-CommandExists "gh")) {
    Write-Error "GitHub CLI is not installed. Please install it and try again."
    exit 1
}

# Get the current directory name to use as the default repository name
$repoName = Split-Path -Leaf (Get-Location)
Write-Host "Using '$repoName' as the repository name..." -ForegroundColor Cyan

# Check if user is authenticated with GitHub CLI
Write-Host "Checking GitHub CLI authentication status..." -ForegroundColor Cyan
$ghAuthStatus = gh auth status 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "You need to authenticate with GitHub CLI first." -ForegroundColor Yellow
    Write-Host "Running 'gh auth login'..." -ForegroundColor Cyan
    gh auth login
    if ($LASTEXITCODE -ne 0) {
        Write-Error "GitHub CLI authentication failed. Please try again."
        exit 1
    }
}

# Step 1: Initialize git repository with main branch
Write-Host "1. Initializing git repository with main branch..." -ForegroundColor Green
git init
git checkout -b main

# Step 2: Create README.md with optional summary (only if it doesn't exist already)
if (-not (Test-Path -Path "README.md" -PathType Leaf)) {
    Write-Host "2. Creating README.md file..." -ForegroundColor Green
    $summary = Read-Host "Enter a summary for the README (leave blank for default)"

    if ([string]::IsNullOrWhiteSpace($summary)) {
        $summary = "# $repoName`n`nThis is a README file for the $repoName repository."
    } else {
        $summary = "# $repoName`n`n$summary"
    }

    $summary | Out-File -FilePath "README.md" -Encoding UTF8
} else {
    Write-Host "2. README.md already exists. Skipping creation..." -ForegroundColor Yellow
}

# Step 3: Stage all files
Write-Host "3. Staging all files in the repository..." -ForegroundColor Green
git add .

# Step 4: Commit changes
Write-Host "4. Committing changes..." -ForegroundColor Green
git commit -m "Initial changes"

# Step 5: Create GitHub repository
Write-Host "5. Creating GitHub repository..." -ForegroundColor Green
$accountType = Read-Host "Create repository under organization account? (y/n, default: n)"

if ($accountType -eq "y" -or $accountType -eq "Y") {
    $orgName = Read-Host "Enter organization name"
    Write-Host "Creating repository $repoName under organization $orgName..." -ForegroundColor Cyan
    gh repo create "$orgName/$repoName" --private --source=. --remote=origin --push
} else {
    Write-Host "Creating repository $repoName under your personal account..." -ForegroundColor Cyan
    gh repo create "$repoName" --private --source=. --remote=origin --push
}

if ($LASTEXITCODE -ne 0) {
    Write-Error "Failed to create GitHub repository. Please check your GitHub access and try again."
    exit 1
}

# Step 6: Push changes to remote repository
Write-Host "6. Pushing changes to remote repository..." -ForegroundColor Green
git push -u origin main

Write-Host "`nRepository initialization complete! Your local repository is now connected to GitHub." -ForegroundColor Green
Write-Host "Repository URL: $(gh repo view --json url -q '.url')" -ForegroundColor Cyan