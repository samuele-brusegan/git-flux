# Merge vs Rebase

Both **merge** and **rebase** integrate changes from one branch into another,
but they produce very different histories.

## Merge

```bash
git switch main
git merge feature
```

Creates a new *merge commit* that ties the two histories together.
History is preserved exactly as it happened — including the divergence.

- ✅ Non-destructive, true to history
- ❌ Can produce a cluttered graph with many merge commits

## Rebase

```bash
git switch feature
git rebase main
```

Replays your feature commits *on top of* the latest `main`, creating a
linear history as if you had started from the newest commit.

- ✅ Clean, linear history
- ❌ Rewrites commit SHAs — never rebase shared/public branches

## Golden rule

> Rebase your *local* work to keep it tidy, but **merge** when integrating
> branches that others may have based work on.
