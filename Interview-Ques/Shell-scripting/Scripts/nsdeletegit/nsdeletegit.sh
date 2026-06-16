#!/bin/bash

# CSV filename
csv_file="/c/Users/src00/Desktop/input.csv"

# Git repo path
repo_path="/c/Users/src00/Desktop/dfs-acm-application-onboarding-crs"

# Store skipped namespaces
Skipped_ns=()

########################################################
# Step 1: Validate CSV
########################################################

echo "Input file exists"

if [[ ! -f "$csv_file" ]]; then
    echo "CSV file not found: $csv_file"
    exit 1
fi


########################################################
# Step 2: Validate Repo
########################################################

echo "Repo path validation"

if [[ ! -d "$repo_path" ]]; then
    echo "GitHub path invalid: $repo_path"
    exit 1
fi

cd "$repo_path" || {
    echo "Failed to change directory"
    exit 1
}


########################################################
# Step 3: Pull latest
########################################################

echo "Switching to master and pulling latest"

git checkout master &&
git pull origin master || {
    echo "Failed to update master"
    exit 1
}


########################################################
# Step 4: Create branch
########################################################

read -p "Enter new git sub-branch: " branch_name

git checkout -b "$branch_name" || {
    echo "Failed to create branch"
    exit 1
}


########################################################
# Cleanup function
########################################################

cleanup_branch() {

echo "Error occurred. Cleanup started"

git checkout master

git branch -D "$branch_name"

git reset --hard origin/master

echo "Branch deleted"

exit 1
}


########################################################
# Trap interruption
########################################################

trap cleanup_branch INT TERM


########################################################
# Step 5: Process CSV
########################################################

echo "Namespace deletion started"

exec 3< "$csv_file"

read -r <&3

while IFS=',' read -r base cluster ns <&3
do

base=$(echo "$base" | tr -d '\r' | xargs)

cluster=$(echo "$cluster" | tr -d '\r' | xargs)

ns=$(echo "$ns" | tr -d '\r' | xargs)


dir="$base/$cluster/$ns"

echo "Checking directory"

pwd

ls -ld "$dir"


########################################################
# Directory validation
########################################################

if [[ -d "$dir" ]]
then

cd "$dir" || {

echo "Failed to enter directory"

Skipped_ns+=("$base/$cluster/$ns")

continue
}

echo "Now inside: $(pwd)"


########################################################
# Search yaml files
########################################################

yaml_files=$(ls *.yaml 2>/dev/null)


if [[ -z "$yaml_files" ]]
then

echo "No yaml found"

cd "$repo_path"

Skipped_ns+=("$base/$cluster/$ns")

continue

else

echo "Found yaml files"

echo "$yaml_files"


########################################################
# Delete yaml
########################################################

rm *.yaml


echo "Deletion done"

cd "$repo_path"

fi


else

echo "Directory does not exist"

cd "$repo_path"

Skipped_ns+=("$base/$cluster/$ns")

continue

fi


done < <(tail -n +2 "$csv_file")


########################################################
# Git operations
########################################################

echo "Yaml deletion completed"

cd "$repo_path" || {

echo "Failed to return"

cleanup_branch

}


########################################################
# Git status
########################################################

git status


########################################################
# Stage changes
########################################################

git add .


echo "Changes added"


########################################################
# Commit
########################################################

read -p "Enter commit message: " commit_comment


git commit -m "$commit_comment" || {

echo "Commit failed"

cleanup_branch

}


########################################################
# Push
########################################################

git push origin "$branch_name" || {

echo "Push failed"

cleanup_branch

}


echo "All changes committed and pushed"
