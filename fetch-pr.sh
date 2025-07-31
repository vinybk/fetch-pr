#!/bin/bash

CONFIG_FILE="./config.fetch-pr"

show_help() {
  cat <<EOF
Usage: $0 <pr-number> | --reconfigure | --help

Fetches and sets up a GitHub Pull Request locally.

Arguments:
  <pr-number>     The pull request number to fetch and run
  --help          Show this help message
  --reconfigure   Reset saved project config and re-enter values

On first run or after --reconfigure, you will be prompted to enter:
  - GitHub repo URL (e.g., https://github.com/user/project.git)
  - Post-clone script (e.g., npm install | npm run build | npm run dev)
EOF
}

prompt_for_config() {
  echo "Configuring project settings..."

  read -rp "GitHub repo URL (e.g., https://github.com/user/project.git): " REPO_URL

  echo -e "\n📂 Where should we store PR folders?"
  echo "  → A new folder named pr-<number> will be created for each PR (e.g., pr-123)."
  echo "  → Please choose the parent directory where these folders should go."
  echo "  Tip: Use /tmp for a clean temporary workspace (💥 deleted on reboot!)"
  echo ""
  read -rp "Parent folder for PRs (e.g., /home/user/dev or /tmp): " PR_BASE_DIR

  echo -e "\n🛠️  Enter the post-clone script to run (pipe-separated commands):"
  echo "  Example: npm install | npm run build | npm run dev"
  read -rp "> " POST_CLONE_SCRIPT

  cat > "$CONFIG_FILE" <<EOF
REPO_URL="$REPO_URL"
PR_BASE_DIR="$PR_BASE_DIR"
POST_CLONE_SCRIPT="$POST_CLONE_SCRIPT"
EOF

  echo -e "\n✅ Config saved to $CONFIG_FILE"
}


# --help
if [[ "$1" == "--help" ]]; then
  show_help
  exit 0
fi

# --reconfigure
if [[ "$1" == "--reconfigure" ]]; then
  rm -f "$CONFIG_FILE"
  prompt_for_config

  if [[ -n "$2" ]]; then
    set -- "$2"  # shift PR number into position $1
  else
    echo -e "To fetch a pull request, run:\n  $0 <pr-number>"
    exit 0
  fi
fi

# First run
if [[ ! -f "$CONFIG_FILE" ]]; then
  prompt_for_config

  if [[ -n "$1" ]]; then
    echo "Continuing with PR #$1..."
  else
    echo -e "To fetch a pull request, run:\n  $0 <pr-number>"
    exit 0
  fi
fi

source "$CONFIG_FILE"

# Check PR number
if [[ -z "$1" ]]; then
  echo "Error: No PR number provided."
  echo "Usage: $0 <pr-number>"
  exit 1
fi

PR_NUM="$1"
DIR_NAME="pr-$PR_NUM"
TARGET_DIR="$PR_BASE_DIR/$DIR_NAME"

mkdir -p "$PR_BASE_DIR" || exit 1
cd "$PR_BASE_DIR" || exit 1

# Handle existing directory
if [[ -d "$TARGET_DIR" ]]; then
  echo "Directory $TARGET_DIR already exists."
  read -rp "Do you want to re-download it? (y/n) " CONFIRM
  if [[ "$CONFIRM" =~ ^[Yy]$ ]]; then
    rm -rf "$TARGET_DIR" || exit 1
    git clone "$REPO_URL" "$TARGET_DIR" || exit 1
    cd "$TARGET_DIR" || exit 1
    git fetch origin pull/"$PR_NUM"/head:pr-"$PR_NUM" || exit 1
    git checkout pr-"$PR_NUM" || exit 1
  else
    echo "Using existing folder."
    cd "$TARGET_DIR" || exit 1
  fi
else
  git clone "$REPO_URL" "$TARGET_DIR" || exit 1
  cd "$TARGET_DIR" || exit 1
  git fetch origin pull/"$PR_NUM"/head:pr-"$PR_NUM" || exit 1
  git checkout pr-"$PR_NUM" || exit 1
fi


# Run post-clone script
IFS='|' read -ra COMMANDS <<< "$POST_CLONE_SCRIPT"
for CMD in "${COMMANDS[@]}"; do
  eval "$CMD" || exit 1
done
