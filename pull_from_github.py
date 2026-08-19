"""Script to pull all latest files from GitHub repository into local workspace."""

import base64
import os
import subprocess
import sys
import httpx

if hasattr(sys.stdout, "reconfigure"):
    sys.stdout.reconfigure(encoding="utf-8")

REPO_OWNER = "navneethvaradharaj11-dev"
REPO_NAME = "coolnetai"
BASE_URL = f"https://api.github.com/repos/{REPO_OWNER}/{REPO_NAME}"


def get_token() -> str | None:
    token = os.getenv("GITHUB_TOKEN") or os.getenv("GH_TOKEN")
    if not token:
        try:
            token = subprocess.check_output(["gh", "auth", "token"], text=True).strip()
        except Exception:
            pass
    return token


def pull_from_github() -> None:
    token = get_token()
    headers = {
        "Accept": "application/vnd.github+json",
        "User-Agent": "CoolNet-AI",
    }
    if token:
        headers["Authorization"] = f"Bearer {token}"

    print(f"Fetching latest files from https://github.com/{REPO_OWNER}/{REPO_NAME} (branch: main)...")

    with httpx.Client(headers=headers, timeout=60.0) as client:
        # Get latest commit on main
        commit_resp = client.get(f"{BASE_URL}/commits/main")
        if commit_resp.status_code != 200:
            raise RuntimeError(f"Failed to fetch branch main: {commit_resp.status_code} {commit_resp.text}")

        commit_data = commit_resp.json()
        commit_sha = commit_data["sha"]
        commit_msg = commit_data["commit"]["message"].split("\n")[0]
        tree_sha = commit_data["commit"]["tree"]["sha"]

        print(f"[OK] Latest remote commit: {commit_sha[:7]} - \"{commit_msg}\"")

        # Get full recursive tree
        tree_resp = client.get(f"{BASE_URL}/git/trees/{tree_sha}?recursive=1")
        if tree_resp.status_code != 200:
            raise RuntimeError(f"Failed to fetch tree: {tree_resp.status_code} {tree_resp.text}")

        tree_items = [item for item in tree_resp.json().get("tree", []) if item["type"] == "blob"]
        print(f"Found {len(tree_items)} remote files in repository.")

        root_dir = os.path.abspath(os.path.join(os.path.dirname(__file__)))
        updated_count = 0
        unchanged_count = 0

        for item in tree_items:
            rel_path = item["path"]
            local_path = os.path.join(root_dir, rel_path.replace("/", os.sep))
            os.makedirs(os.path.dirname(local_path), exist_ok=True)

            # Fetch blob content
            blob_resp = client.get(f"{BASE_URL}/git/blobs/{item['sha']}")
            if blob_resp.status_code != 200:
                print(f"  [WARN] Could not fetch blob for {rel_path}")
                continue

            blob_data = blob_resp.json()
            if blob_data["encoding"] == "base64":
                remote_bytes = base64.b64decode(blob_data["content"])
            else:
                remote_bytes = blob_data["content"].encode("utf-8")

            # Check if local file exists and is identical
            if os.path.exists(local_path):
                with open(local_path, "rb") as fp:
                    local_bytes = fp.read()
                if local_bytes == remote_bytes:
                    unchanged_count += 1
                    continue

            # Write updated file
            with open(local_path, "wb") as fp:
                fp.write(remote_bytes)
            print(f"  [PULLED] {rel_path}")
            updated_count += 1

        print("\n==================================================")
        print(f"[SUCCESS] Pull complete! {updated_count} files updated, {unchanged_count} files already up to date.")
        print(f"Local workspace is now at commit: {commit_sha[:7]}")
        print("==================================================")


if __name__ == "__main__":
    pull_from_github()
