#!/usr/bin/env bash
# One-time repo setup: labels and protection for main.
# Run it AFTER the first push to main. Needs the gh CLI logged in (gh auth login).
# Usage: scripts/bootstrap.sh <owner/repo>
set -euo pipefail
REPO="${1:?usage: scripts/bootstrap.sh <owner/repo>}"
labels=(
"type:feat|1d76db|New functionality"
"type:chore|c5def5|Repo, tooling or housekeeping"
"type:ci|0e8a16|Pipeline work"
"area:api|5319e7|FastAPI service"
"area:docker|0052cc|Containers and Compose"
"area:ci-cd|0e8a16|Build, test and deploy automation"
"area:observability|fbca04|Metrics, logs and traces"
"area:security|d93f0b|SAST, DAST, secrets and image scanning"
"area:k8s|006b75|Kubernetes manifests and cluster"
"phase:0|ededed|Foundations"
"phase:1|ededed|Walking skeleton"
"phase:2|ededed|Harden the core"
"stretch|bfd4f2|Only after the core works"
)
for entry in "${labels[@]}"; do
IFS='|' read -r name color desc <<<"$entry"
gh label create "$name" --color "$color" --description "$desc" --force --repo "$REPO"
done
# Protect main: PRs only, no force-push, no deletion, linear history (squash merges),
# and the rule applies to admins too, so even the owner cannot push directly.
# The required CI check is added in issue #4, once that check exists.
gh api -X PUT "repos/$REPO/branches/main/protection" --input - <<'JSON'
{
"required_status_checks": null,
"enforce_admins": true,
"required_pull_request_reviews": {"required_approving_review_count": 0},
"restrictions": null,
"required_linear_history": true,
"allow_force_pushes": false,
"allow_deletion": false
}
JSON
echo "Labels created and main protected on $REPO."