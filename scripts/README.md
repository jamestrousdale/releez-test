# Test repo scripts

These scripts manage the git state of the playground repo.

## Setup scenario

The repo simulates a monorepo with two independent packages:

- **core** — last released as `core-0.1.0`, with 2 unreleased commits queued
  (`feat` + `fix`, so the next version will be `0.2.0`)
- **ui** — last released as `ui-0.1.0`, with 1 unreleased commit queued
  (`feat`, so the next version will be `0.2.0`)

The `initial-state` tag marks the starting point. All reset/squash operations
are relative to it.

## Scripts

### `init.sh` — run once

Initialises the git repo, creates the initial commit, applies the
`core-0.1.0` / `ui-0.1.0` release tags, adds unreleased commits for both
projects, and tags `initial-state` at HEAD.

```
cd /path/to/this/repo
./scripts/init.sh
```

### `reset.sh` — return to clean slate

Hard-resets to `initial-state` and removes untracked files. Use this whenever
you want to start an experiment over from scratch.

```
./scripts/reset.sh
```

### `squash.sh` — save current state as new baseline

Squashes all commits since `initial-state` into one and moves the
`initial-state` tag to the new HEAD. Use this when you've been experimenting,
want to keep the current state, and want `reset.sh` to return here instead of
the original setup.

Note: version tags (`core-0.1.0`, `ui-0.1.0`, etc.) are not affected.

```
./scripts/squash.sh
```

## Typical workflow

```bash
./scripts/init.sh            # first time only

releez projects changed      # see what needs releasing
releez release start         # start releases for changed projects

# …experiment, inspect branches, run releez commands…

./scripts/reset.sh           # back to clean slate for next experiment
```
