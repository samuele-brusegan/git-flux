# Branching Strategies

A **branch** is a movable pointer to a commit. Branches let multiple lines of
work progress in parallel without interfering with each other.

## Common strategies

### Feature branching
Each new feature lives on its own branch, merged back when complete.

```bash
git switch -c feature/login
# ...work...
git switch main
git merge feature/login
```

### Trunk-based development
Everyone commits to a single `main` branch frequently, using short-lived
branches and feature flags to keep `main` releasable.

### Git Flow
A more structured model with `develop`, `release/*`, and `hotfix/*` branches.
Best suited to projects with scheduled releases.

## Choosing one

- Small teams shipping continuously → trunk-based.
- Teams with versioned releases → Git Flow.
- Most projects → simple feature branching.
