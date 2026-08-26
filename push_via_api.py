"""Direct GitHub API push script for CoolNet AI with robust network retry."""

import base64
import os
import subprocess
import sys
import time
import httpx

if hasattr(sys.stdout, "reconfigure"):
    sys.stdout.reconfigure(encoding="utf-8")

REPO_OWNER = "navneethvaradharaj11-dev"
REPO_NAME = "coolnetai"
BASE_URL = f"https://api.github.com/repos/{REPO_OWNER}/{REPO_NAME}"


def get_token() -> str:
    token = os.getenv("GITHUB_TOKEN") or os.getenv("GH_TOKEN")
    if not token:
        try:
            token = subprocess.check_output(["gh", "auth", "token"], text=True).strip()
        except Exception:
            pass
    if not token and len(sys.argv) > 1:
        token = sys.argv[1]
    if not token:
        raise RuntimeError("No GitHub token available.")
    return token


def execute_request(method: str, url: str, headers: dict, json_data: dict | None = None, max_retries: int = 8) -> httpx.Response:
    for attempt in range(1, max_retries + 1):
        try:
            with httpx.Client(headers=headers, timeout=60.0) as client:
                if method.upper() == "GET":
                    resp = client.get(url)
                elif method.upper() == "POST":
                    resp = client.post(url, json=json_data)
                elif method.upper() == "PATCH":
                    resp = client.patch(url, json=json_data)
                elif method.upper() == "PUT":
                    resp = client.put(url, json=json_data)
                else:
                    raise ValueError(f"Unknown method {method}")

                if resp.status_code in (200, 201, 409, 422):
                    return resp
                print(f"  [Retry {attempt}/{max_retries}] HTTP {resp.status_code}: {resp.text[:100]}")
        except Exception as e:
            print(f"  [Network wait {attempt}/{max_retries}] {e} - retrying in {attempt * 2}s...")
            time.sleep(attempt * 2)

    raise RuntimeError(f"Failed request to {url} after {max_retries} attempts.")


def push_all_files() -> None:
    token = get_token()
    headers = {
        "Authorization": f"Bearer {token}",
        "Accept": "application/vnd.github+json",
        "User-Agent": "CoolNet-AI",
    }

    root_dir = os.path.abspath(os.path.dirname(__file__))
    files_to_upload = []

    ignore_dirs = {".git", "__pycache__", ".venv", "venv", ".idea", ".vscode", "build", "dist"}
    ignore_files = {".DS_Store", "Thumbs.db"}

    for dirpath, dirnames, filenames in os.walk(root_dir):
        dirnames[:] = [d for d in dirnames if d not in ignore_dirs]
        for f in filenames:
            if f in ignore_files:
                continue
            full_path = os.path.join(dirpath, f)
            rel_path = os.path.relpath(full_path, root_dir).replace("\\", "/")
            files_to_upload.append((rel_path, full_path))

    print(f"Found {len(files_to_upload)} files to push to {REPO_OWNER}/{REPO_NAME}...")

    # 1. Check or initialize branch main
    ref_resp = execute_request("GET", f"{BASE_URL}/git/ref/heads/main", headers=headers)
    if ref_resp.status_code != 200:
        readme_path = os.path.join(root_dir, "README.md")
        with open(readme_path, "rb") as fp:
            readme_content = base64.b64encode(fp.read()).decode("ascii")
        execute_request(
            "PUT",
            f"{BASE_URL}/contents/README.md",
            headers=headers,
            json_data={
                "message": "Initial commit: CoolNet AI LLM Explanation Layer",
                "content": readme_content,
                "branch": "main",
            },
        )
        ref_resp = execute_request("GET", f"{BASE_URL}/git/ref/heads/main", headers=headers)

    latest_commit_sha = ref_resp.json()["object"]["sha"]
    commit_resp = execute_request("GET", f"{BASE_URL}/git/commits/{latest_commit_sha}", headers=headers)
    base_tree_sha = commit_resp.json()["tree"]["sha"]
    print(f"[OK] Base commit: {latest_commit_sha[:7]} (tree: {base_tree_sha[:7]})")

    # 2. Upload Blobs
    tree_items = []
    for rel_path, full_path in files_to_upload:
        with open(full_path, "rb") as fp:
            content_bytes = fp.read()

        blob_payload = {
            "content": base64.b64encode(content_bytes).decode("ascii"),
            "encoding": "base64",
        }

        blob_resp = execute_request("POST", f"{BASE_URL}/git/blobs", headers=headers, json_data=blob_payload)
        if blob_resp.status_code not in (200, 201):
            raise RuntimeError(f"Failed to create blob for {rel_path}: {blob_resp.status_code} {blob_resp.text}")

        blob_sha = blob_resp.json()["sha"]
        tree_items.append({
            "path": rel_path,
            "mode": "100644",
            "type": "blob",
            "sha": blob_sha,
        })
        print(f"  [OK] Uploaded blob: {rel_path} ({blob_sha[:7]})")

    # 3. Create Tree
    print("\nCreating complete Git tree...")
    tree_resp = execute_request(
        "POST",
        f"{BASE_URL}/git/trees",
        headers=headers,
        json_data={"base_tree": base_tree_sha, "tree": tree_items},
    )
    if tree_resp.status_code not in (200, 201):
        raise RuntimeError(f"Failed to create tree: {tree_resp.status_code} {tree_resp.text}")
    new_tree_sha = tree_resp.json()["sha"]
    print(f"[OK] Git Tree created: {new_tree_sha}")

    # 4. Create Commit
    print("Creating final commit...")
    commit_resp = execute_request(
        "POST",
        f"{BASE_URL}/git/commits",
        headers=headers,
        json_data={
            "message": "CoolNet AI: LLM Explanation Layer complete implementation",
            "tree": new_tree_sha,
            "parents": [latest_commit_sha],
        },
    )
    if commit_resp.status_code not in (200, 201):
        raise RuntimeError(f"Failed to create commit: {commit_resp.status_code} {commit_resp.text}")
    new_commit_sha = commit_resp.json()["sha"]
    print(f"[OK] Commit created: {new_commit_sha}")

    # 5. Update branch ref to new commit
    print("Updating branch ref 'main'...")
    update_ref = execute_request(
        "PATCH",
        f"{BASE_URL}/git/refs/heads/main",
        headers=headers,
        json_data={"sha": new_commit_sha, "force": True},
    )
    if update_ref.status_code not in (200, 201):
        raise RuntimeError(f"Failed to update ref: {update_ref.status_code} {update_ref.text}")

    print(f"\n[SUCCESS] Successfully pushed all files to https://github.com/{REPO_OWNER}/{REPO_NAME} on branch 'main'!")


if __name__ == "__main__":
    push_all_files()
