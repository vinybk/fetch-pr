fetch-pr.sh
===========

> A simple interactive script to fetch and run GitHub pull requests locally — with your project setup, your way.

---

What it does
------------

This script automates the process of:

1. Cloning a GitHub repository
2. Checking out a specific pull request by number
3. Running your custom post-clone script (e.g., install, build, dev)

It remembers your project settings so you only have to configure it once.

---

Usage
-----

    ./fetch-pr.sh <pr-number>

### Example:

    ./fetch-pr.sh 124

This will:

- Clone the configured repository into a folder like `pr-124`
- Check out PR #124
- Run your saved setup script

---

First-time setup
----------------

When you run the script for the first time (or use `--reconfigure`), it will ask:

- The GitHub repo URL (e.g., `https://github.com/yourname/yourrepo.git`)
- Where to store the PR folders (suggestion: `/tmp` for auto-cleaning after reboot)
- What script to run after cloning (pipe-separated commands)

Example post-clone script:

    npm install | npm run build | npm run dev

These values are saved to `config.fetch-pr` in the same directory as the script.

---

Options
-------

    ./fetch-pr.sh <pr-number>     # Fetch and run a PR
    ./fetch-pr.sh --reconfigure   # Reset config and enter new values
    ./fetch-pr.sh --help          # Show help

---

Example folder structure
------------------------

    fetch-pr.sh
    config.fetch-pr

Pull requests will be cloned into subfolders like:

    /tmp/pr-123
    ~/projects/guia/pr-456

---

Tips
----

- Use `/tmp` as the parent folder if you want your PR folders to disappear automatically on reboot.
- Works great for testing external PRs on projects with a build/dev cycle.

---

Download
--------

You can get the latest version of this script from:

https://github.com/vinybk/fetch-pr

Clone the repo or download `fetch-pr.sh` manually.

Then make it executable:

    chmod +x fetch-pr.sh

And run:

    ./fetch-pr


---

Clean, customizable, and local.
-------------------------------

No `gh` CLI required. Just Bash, Git, and your usual dev tools.

    echo "Happy hacking! 🎉"
