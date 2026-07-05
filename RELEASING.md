# Releasing

GitFlow release process. Most of it is automated by GitHub Actions; this
describes what the automation does and the few manual approval/submit steps.

## Versioning

- **Marketing version** (`MARKETING_VERSION`) lives in `Version.xcconfig` — the
  single source of truth. Bumped when cutting a release.
- **Build number** (`CURRENT_PROJECT_VERSION`) is set by CI, never edited by
  hand: TestFlight uses `run_number + 1000`, App Store uses `run_number + 100`.
- `develop` always carries the **next** version and runs one minor ahead of the
  last release.

## 1. Cut a release — automated (`release-cut.yml`)

Runs automatically **every Wednesday 06:00 UTC**, or manually via
**Actions → Release Cut → Run workflow** (with an optional version override).

It does, from `develop`:
1. Reads the version from `Version.xcconfig` (e.g. `1.4.0`).
2. Creates `release/1.4.0`.
3. Pushes a direct version bump to `develop` → next minor (`1.5.0`).
4. Opens the PR **`release/1.4.0` → `main`** (title `Release 1.4.0`).

No manual branch creation or develop bump needed.

## 2. Stabilize on the release branch

- The `release/1.4.0 → main` PR triggers **`testflight.yml`**: it builds the
  release candidate and uploads it to TestFlight. The PR description becomes the
  "What to Test" notes — so **write release notes in the PR description**.
- Fixes go on `release/1.4.0` (branch from it, PR back into it). Each update to
  the release PR re-uploads a new TestFlight build.

## 3. Ship — merge to `main`

Merge the `release/1.4.0 → main` PR (squash). On the push to `main`, two
workflows run automatically:

- **`tag-and-backmerge.yml`** — tags `v1.4.0` and back-merges `main` into
  `develop` (keeping develop's higher version).
- **`appstore.yml`** — builds and uploads the build to App Store Connect
  (`fastlane release`, no submit). This job is gated by the **`appstore`**
  environment (required reviewer, `main` only), so **it waits for your approval**
  in the Actions UI.

## 4. Submit for review — manual

`appstore.yml` uploads the build but does **not** submit. To release:
1. Ensure the version's metadata/screenshots/what's-new are complete in App
   Store Connect.
2. Select the uploaded build and press **Submit for Review** in the ASC UI.

## Hotfix (urgent production fix)

```bash
git checkout main && git pull
git checkout -b hotfix/1.4.1
# edit Version.xcconfig -> MARKETING_VERSION = 1.4.1, plus the fix
git push -u origin hotfix/1.4.1
```

- Open PR `hotfix/1.4.1 → main`. It builds/uploads to TestFlight for
  verification (same as a release PR).
- On merge to `main`, `tag-and-backmerge.yml` tags `v1.4.1` and back-merges into
  `develop`; `appstore.yml` uploads the build (pending your approval).

## Notes

- Never edit the build number; CI owns it.
- App Store uploads pause for approval via the `appstore` environment; TestFlight
  uploads are not gated.
- The release-cut, tag-and-backmerge, and develop-bump steps rely on
  `GIT_AUTH_TOKEN` having write access and being in the branch-protection bypass
  list.
