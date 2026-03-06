---
description: Create GitHub issues or pull requests using the gh CLI, always in English
---

This workflow standardizes the creation of GitHub issues and pull requests via the `gh` CLI. All titles, descriptions, labels, and comments must be written in **English**, regardless of the language used in the conversation.

### Creating an Issue

1. **Determine issue type**: bug report, feature request, or task.

2. **Create the issue**:
   ```bash
   gh issue create --title "Short, descriptive title" --body "$(cat <<'EOF'
   ## Description
   Clear explanation of the issue.

   ## Steps to reproduce (bugs only)
   1. Step one
   2. Step two

   ## Expected behavior
   What should happen.

   ## Actual behavior
   What happens instead.
   EOF
   )"
   ```

3. **Add labels** — use only the project's available labels:
   - `bug` — something isn't working
   - `dependencies` — dependency updates
   - `documentation` — documentation changes
   - `enhancement` — new feature or improvement

4. **Return the issue URL** to the user.

### Creating a Pull Request

1. **Check current state**:
   - Run `git status` to verify there are no uncommitted changes.
   - Run `git log main..HEAD --oneline` to review all commits that will be included.
   - Verify the branch is pushed to the remote (`git push -u origin <branch>` if needed).

2. **Draft the PR content**:
   - Title: under 70 characters, concise and descriptive.
   - Body: structured summary of **all** commits in the branch, not just the latest one.

3. **Create the PR**:
   If an issue was created earlier in the same conversation, link it by adding `Closes #<number>` at the end of the body.

   ```bash
   gh pr create --title "Short descriptive title" --body "$(cat <<'EOF'
   ## Summary
   - Bullet point describing change 1
   - Bullet point describing change 2

   Closes #123
   EOF
   )"
   ```

4. **Add reviewers or labels** if requested with `--reviewer` or `--label`.

5. **Return the PR URL** to the user.

### Rules

- All text in issues and PRs must be in **English**.
- Use imperative mood for titles: "Add feature X", "Fix crash when Y", not "Added" or "Fixes".
- Do not push to remote or create PRs without explicit user approval.
- When creating a PR, always review the full diff against the base branch, not just the last commit.
