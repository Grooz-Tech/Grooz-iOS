# Grooz iOS — Developer Setup

Get the project building and signing locally.

## 1. Tooling

```bash
brew install fastlane tuist
```

Install the shared git hooks:

```bash
git config core.hooksPath .githooks
```

## 2. Secrets

Create `fastlane/.env` (gitignored) with `MATCH_PASSWORD` from **1Password**:

```bash
cat > fastlane/.env <<EOF
MATCH_PASSWORD=<from 1Password>
EOF
```

## 3. Certificates & profiles

Fetch and install the signing certs/profiles:

```bash
fastlane certificates
```

## 4. Generate the Xcode project

```bash
tuist generate
```

## Run tests

```bash
fastlane test
```
