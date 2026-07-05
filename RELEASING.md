# Releasing

GitFlow release process. Weekly cadence: a `release/*` branch is cut from
`develop` (currently manual; automation planned).

## Versioning

- **Marketing version** (`MARKETING_VERSION`) lives in `Version.xcconfig` — the
  single source of truth. Bumped when cutting a release.
- **Build number** (`CURRENT_PROJECT_VERSION`) is set by CI from
  `github.run_number` — never edited by hand.
- `develop` always carries the **next** version and runs one minor ahead of the
  last release.

## Cut a release (weekly, from `develop`)

Say `develop` is at `1.4.0`.

```bash
git checkout develop && git pull

# 1. Cut the release branch (inherits develop's version, 1.4.0).
git checkout -b release/1.4.0
git push -u origin release/1.4.0
```

Opening a PR **`release/1.4.0` → `main`** triggers the TestFlight workflow: it
builds the release candidate and uploads it to TestFlight (the PR description
becomes the "What to Test" notes).

```bash
# 2. Immediately bump develop to the next minor, so it's ready for the next cut.
git checkout develop
# edit Version.xcconfig -> MARKETING_VERSION = 1.5.0
git checkout -b feature/bump-develop-1.5.0
git commit -am "chore(version): bump develop to 1.5.0"
git push -u origin feature/bump-develop-1.5.0
# open PR into develop
```

## Stabilize & ship

- Fixes for the release go on `release/1.4.0` (branch from it, PR back into it).
  Each PR update re-uploads a new TestFlight build.
- When the release is approved:
  1. Merge the `release/1.4.0 → main` PR (squash).
  2. Tag `main`: `git tag -a v1.4.0 -m "Release 1.4.0" && git push origin v1.4.0`.
  3. Merge the release branch back into `develop` (keep develop's higher
     version — do not let it revert to 1.4.0).
  4. Delete the release branch.

## Hotfix (urgent production fix)

`main` is at `v1.4.0`:

```bash
git checkout main && git pull
git checkout -b hotfix/1.4.1
# edit Version.xcconfig -> MARKETING_VERSION = 1.4.1, plus the fix
git push -u origin hotfix/1.4.1
```

- PR `hotfix/1.4.1` → `main` (builds/uploads to TestFlight for verification).
- On merge: tag `v1.4.1`, then merge into `develop` (keeping develop's higher
  version).

## Notes

- Never edit the build number; CI owns it.
- The `testflight` GitHub Environment gates TestFlight uploads (required
  approval), so an RC uploads only after the deploy job is approved.
