# What is a Commit?

A **commit** is a snapshot of your entire project at a specific point in time.
Unlike a simple "save", a commit records *who* changed *what* and *why*.

## The three areas

| Area | Description |
|------|-------------|
| Working directory | The files you edit on disk |
| Staging area (index) | Changes selected for the next commit |
| Repository | The permanent history of commits |

## A typical flow

```bash
git add file.txt      # stage the change
git commit -m "Fix typo in greeting"
```

## Why commits matter

- Every commit has a unique SHA identifier.
- Commits form a chain: each points to its parent(s).
- You can return to any commit at any time.

> Tip: Write commit messages in the imperative mood — "Add login form",
> not "Added login form".
