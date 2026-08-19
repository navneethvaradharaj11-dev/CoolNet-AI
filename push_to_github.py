"""Helper script to push CoolNet AI commits to GitHub repository."""

import getpass
import os
import sys
from dulwich import porcelain
from dulwich.repo import Repo

REPO_URL = "https://github.com/navneethvaradharaj11-dev/coolnetai.git"


def push_to_github(token: str | None = None, branch: str = "main") -> None:
    """Push local branch to remote GitHub repository using Dulwich."""
    token = token or os.getenv("GITHUB_TOKEN") or os.getenv("GH_TOKEN")
    if not token:
        if len(sys.argv) > 1:
            token = sys.argv[1]
        else:
            token = getpass.getpass("Enter your GitHub Personal Access Token (PAT): ").strip()

    if not token:
        print("Error: GitHub Personal Access Token is required to push.")
        sys.exit(1)

    auth_url = f"https://oauth2:{token}@github.com/navneethvaradharaj11-dev/coolnetai.git"
    print(f"Connecting to {REPO_URL}...")
    
    r = Repo(".")
    # Ensure branch ref exists
    head_sha = r.head()
    r.refs[f"refs/heads/{branch}".encode("ascii")] = head_sha

    print(f"Pushing branch '{branch}' (commit: {head_sha.decode('ascii')[:7]})...")
    porcelain.push(
        r,
        remote_location=auth_url,
        refspecs=[f"refs/heads/{branch}".encode("ascii")],
    )
    print(f"Successfully pushed to {REPO_URL} on branch '{branch}'!")


if __name__ == "__main__":
    cli_token = sys.argv[1] if len(sys.argv) > 1 else None
    push_to_github(token=cli_token)
