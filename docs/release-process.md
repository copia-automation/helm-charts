# Release Process

## Overview

Releases are automated via GitHub Actions and [release-drafter](https://github.com/release-drafter/release-drafter). The version number is determined by PR labels; you never need to manually edit `Chart.yaml`'s version field.

## PR Labels

Every PR must have at least one of the following labels (enforced by the `Require Pull Request Label` workflow):

| Label                  | Version bump            | Changelog category |
| ---------------------- | ----------------------- | ------------------ |
| `major`, `breaking`    | Major (0.x.0 → 1.0.0)   | —                  |
| `feature`              | Minor (0.57.x → 0.58.0) | Features           |
| `enhancement`          | Patch                   | Features           |
| `fix`, `bugfix`, `bug` | Patch                   | Bug Fixes          |
| `chore`                | Patch                   | Maintenance        |
| `dependencies`         | Patch                   | Dependencies       |

If multiple labeled PRs are merged before a release, the highest bump wins.

PRs that update the Copia app version (`appVersion` in Chart.yaml) should use the `feature` label, as each app release is a minor version bump to the chart.

## Workflow

1. **Open a PR** — add a label from the table above. The `Publish Beta Helm Chart` workflow packages the chart as `0.0.0-beta.pr<number>` and pushes it to the **dev** registry (`ghcr.io/copia-automation/helm-charts-dev`) for testing.

2. **Merge the PR** — the `Draft Release` workflow runs and creates/updates a draft GitHub Release. The draft accumulates all PRs merged since the last published release, grouped by label category, with the next version computed from labels.

3. **Publish the release** — a maintainer reviews the draft on the [Releases page](../../releases) and publishes it. This triggers the `Publish Production Helm Chart` workflow, which:
   - Extracts the chart version from the release tag (e.g. `copia-0.58.0` → `0.58.0`)
   - Sets the version in `Chart.yaml`
   - Generates `Changelog.md` from git history
   - Packages and pushes the chart to the **production** registry (`ghcr.io/copia-automation/helm-charts`)
   - Uploads the packaged chart as a workflow artifact

## Registries

| Registry                                   | Purpose                                  | Populated by                                       |
| ------------------------------------------ | ---------------------------------------- | -------------------------------------------------- |
| `ghcr.io/copia-automation/helm-charts`     | Production — consumed by customers       | `Publish Production Helm Chart` on release publish |
| `ghcr.io/copia-automation/helm-charts-dev` | Development — PR beta builds for testing | `Publish Beta Helm Chart` on pull request          |

## Manual Operations

### Publish a chart manually

Useful when the automated release flow fails partway through (e.g. CI outage after the GitHub release was published but before the chart was pushed), or when you need to republish a chart with a corrected changelog or metadata without creating a new release.

```
gh workflow run publish-helm-chart.yaml -f version=0.58.0 -f production=false
```

Set `production=true` to push to the production registry.

You can also trigger this from the GitHub UI:

1. Go to [Actions -> Publish Helm Chart](https://github.com/copia-automation/helm-charts/actions/workflows/publish-helm-chart.yaml).
2. Click **Run workflow**.
3. Select the branch, fill in `version` and `production`, and click **Run workflow**.

### Remove a production chart published in error

If a chart was published with incorrect content (wrong appVersion, broken templates, etc.), remove it from the registry to prevent customers from installing it. Bumping a new version is not sufficient; customers can still pull the old version.

1. Go to the the [GitHub Packages UI for the production copia chart](https://github.com/copia-automation/helm-charts/pkgs/container/helm-charts%2Fcopia/versions) and find the release that was published in error.
2. Click "Delete."

## Workflows Reference

| File                                 | Trigger                               | Purpose                                              |
| ------------------------------------ | ------------------------------------- | ---------------------------------------------------- |
| `publish-beta-helm-chart.yaml`       | `pull_request`                        | Publish beta chart to dev registry                   |
| `publish-production-helm-chart.yaml` | `release: published`                  | Publish production chart from release tag            |
| `publish-helm-chart.yaml`            | `workflow_call` / `workflow_dispatch` | Shared chart package/push logic                      |
| `release-drafter.yaml`               | `push: main`                          | Update draft release with changelog and next version |
| `require-pr-label.yaml`              | `pull_request`                        | Block PRs without a release-drafter label            |
