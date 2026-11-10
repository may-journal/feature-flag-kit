# Workflows

GitHub Actions for this repo, all on the Go [fitness-runner](https://github.com/may-journal/fitness-runner) toolchain. The org-settings job in [may-journal/.github](https://github.com/may-journal/.github) syncs the shared callers here by pull request. Locally the synced hooks run the same suite on commit.

## ci

The org-level `Fitness suite` required workflow runs the full suite on every PR. The repo keeps no local ci.yml.

## issue-check, close-check and comment-check

The synced `issue-check.yml` judges each issue against its template, Plans included. The synced `close-check.yml` reopens an issue closed with unchecked checklist items, and `comment-check.yml` judges comments.

## auto-merge-on-ready

The synced `auto-merge-on-ready.yml` turns on auto-merge when a draft is marked ready.

## requirements

Fitness's `requirements` check is on. It passes only when every acceptance has a test.
