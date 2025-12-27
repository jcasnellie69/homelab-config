# Repo-based Wiki automation

This repo includes a small automation to publish pages from `WIKI/` into the GitHub wiki for this repository.

How it works
- A GitHub Actions workflow `.github/workflows/push-wiki.yml` performs two steps:
  1. Enables the repository wiki via the GitHub API
  2. Clones the generated wiki git repo and copies markdown files from `WIKI/` into it, then commits and pushes

What you need to do
1. Create a repository secret named `WIKI_PAT` containing a PAT with `repo` scope (or admin access) so the workflow can enable the wiki and push changes.
   - Repo → Settings → Secrets and variables → Actions → New repository secret
2. From the GitHub UI, open the Actions tab → 'Push Wiki from Repo' workflow → Run workflow (no inputs required).

Security notes
- Do NOT paste PATs into chat. Use repository secrets. Revoke the PAT if it is exposed.
