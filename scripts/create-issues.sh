#!/usr/bin/env bash
# Creates the first 10 issues. Run once, after scripts/bootstrap.sh.
# Usage: scripts/create-issues.sh <owner/repo>
# Each issue is a block: line 1 = title, line 2 = labels, the rest = body.
set -euo pipefail
REPO="${1:?usage: scripts/create-issues.sh <owner/repo>}"

existing=$(gh issue list --repo "$REPO" --state all --json number --jq length)
if [ "$existing" -gt 0 ]; then
  echo "This repo already has $existing issue(s). Not creating duplicates." >&2
  exit 1
fi

issue() {
  local title labels
  IFS= read -r title
  IFS= read -r labels
  case "$labels" in
    type:*) ;;
    *) echo "Bad labels line: '$labels' (title: '$title')" >&2; exit 1 ;;
  esac
  gh issue create --repo "$REPO" --title "$title" --label "$labels" --body-file -
}

issue <<'EOF'
chore: bootstrap repo, project board and workflow rules
type:chore,phase:0
Create the repo, board, labels and templates, and protect main. Estimate: 1.5 h.

## Acceptance criteria
- [ ] Repo is public (branch protection on private repos needs a paid plan)
- [ ] Main requires a PR and blocks direct pushes (the CI check becomes required in #4)
- [ ] Issue and PR templates exist; the PR template has "Closes #n" and an evidence checklist
- [ ] All 10 issues are on the board
- [ ] Peer reviewer is named, with the first review exchange dated before Dec 1

## Evidence to save
Board screenshot with 10 issues; screenshot of a rejected direct push to main.
EOF

issue <<'EOF'
feat(api): URL shortener endpoints, validation and tests
type:feat,area:api,phase:1
FastAPI endpoints with in-memory store and API-key check. Estimate: 2 h.

## Acceptance criteria
- [ ] Non-http(s) or oversized URLs return 422, unknown code returns 404, missing key returns 401
- [ ] `wc -l app/*.py` is under 150
- [ ] At least 8 pytest tests pass, covering validation and auth
- [ ] `/docs` works and the README has curl examples

## Evidence to save
pytest output; `wc -l` output.
EOF

issue <<'EOF'
build(docker): multi-stage Dockerfile and compose for the app
type:feat,area:docker,phase:1
Estimate: 1.5 h.

## Acceptance criteria
- [ ] Pinned `python:3.12-slim` base, non-root user, `HEALTHCHECK` and `.dockerignore`
- [ ] `docker compose up` then `curl localhost:8000/healthz` returns 200
- [ ] Image size recorded for the report
- [ ] README has a Docker usage section (build, run, compose)
EOF

issue <<'EOF'
ci: GitHub Actions workflow with lint and test on every PR
type:ci,area:ci-cd,phase:1
Estimate: 2 h.

## Acceptance criteria
- [ ] Triggers on `pull_request` and push to main; runs ruff and pytest with pip cache; actions pinned
- [ ] The check is marked required on main
- [ ] A deliberately red PR is blocked (screenshot saved)
- [ ] Status badge in the README
EOF

issue <<'EOF'
feat(observability): Prometheus metrics, JSON logs, Prometheus + Grafana in compose
type:feat,area:observability,phase:1
Estimate: 2 h.

## Acceptance criteria
- [ ] `/metrics` exposes `http_requests_total{method,route,status}`, a duration histogram and `links_created_total`
- [ ] Every request logs one JSON line with `request_id`, `method`, `route`, `status`, `duration_ms`; errors log at `error` level
- [ ] Prometheus target is UP
- [ ] Grafana datasource is provisioned and one request-rate panel works
- [ ] Route label uses the template (`/{code}`), never the raw code
EOF

issue <<'EOF'
feat(observability): OpenTelemetry tracing to Jaeger
type:feat,area:observability,phase:1
Estimate: 1.5 h.

## Acceptance criteria
- [ ] FastAPI auto-instrumentation plus one manual span around the store lookup, exported via `OTEL_EXPORTER_OTLP_ENDPOINT`
- [ ] `trace_id` appears in log lines
- [ ] Jaeger UI shows the POST then GET traces
- [ ] Tracing is a no-op when the endpoint is unset, so tests do not need Jaeger
EOF

issue <<'EOF'
ci(security): SAST with Bandit + Semgrep and secret scan with gitleaks
type:ci,area:security,phase:1
Estimate: 1.5 h.

## Acceptance criteria
- [ ] All three run on PR and upload reports as artifacts
- [ ] Pipeline fails on high severity
- [ ] A deliberate-vulnerability PR (hardcoded secret or `eval`) is blocked (screenshot saved)
- [ ] Findings triaged in `docs/security.md`
EOF

issue <<'EOF'
ci(cd): build, Trivy scan and push to Docker Hub on main
type:ci,area:ci-cd,phase:1
Estimate: 1.5 h.

## Acceptance criteria
- [ ] Docker Hub access token (not the password) stored in GitHub Secrets
- [ ] Image tagged `sha-<short>` plus `latest`; pushes happen only on main after tests pass
- [ ] Trivy fails on fixable CRITICAL/HIGH vulnerabilities; exceptions documented in `.trivyignore`
- [ ] `docker pull <user>/shortlink:<sha>` works
EOF

issue <<'EOF'
feat(k8s): kind cluster and core manifests
type:feat,area:k8s,phase:1
Estimate: 3.5 h.

## Acceptance criteria
- [ ] Deployment with liveness/readiness probes and requests/limits; Service; ConfigMap (`LOG_LEVEL`, OTel endpoint); Secret for `API_KEY` (example committed, real one gitignored)
- [ ] `make kind-up deploy` then `curl localhost:8080/healthz` returns 200, using the Docker Hub image
- [ ] Evidence: deleting the pod causes automatic recreation
EOF

issue <<'EOF'
ci(security): DAST with OWASP ZAP API scan on the running container
type:ci,area:security,phase:1
Use `zap-api-scan` with the OpenAPI spec (the baseline scan only spiders HTML). Estimate: 1.5 h.

## Acceptance criteria
- [ ] Pipeline starts the container and scans it using the OpenAPI spec
- [ ] HTML and JSON reports uploaded as artifacts
- [ ] Warnings triaged in `zap-rules.tsv` with justifications
- [ ] At least one real finding fixed (for example security headers), with before and after reports saved
EOF

echo "10 issues created on $REPO. Add them to your project board from the Projects tab."