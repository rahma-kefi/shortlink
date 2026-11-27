# Shortlink: plan v0
Project: a URL shortener (FastAPI, backend under 150 lines) taken through a 
production-style DevOps platform. Deadline: presentation on Dec 15, 2026. 
Budget: about 40 hours from Nov 21.
## Assumptions
| Item | Assumption |
| --- | --- |
| Time | ~12 h/week |
| Machine | Windows + WSL2, 16 GB RAM |
| Language | Python + FastAPI |
| 150-line scope | app/*.py including observability setup, excluding tests 
(confirm with the instructor) |
## Endpoints
| Endpoint | Purpose |
| --- | --- |
| `POST /links` | Create a short code (`X-API-Key`, http/https only, max 2048 chars) |
| `GET /{code}` | 307 redirect, increments hits |
| `GET /links/{code}` | Stats: url, hits, created_at |
| `DELETE /links/{code}` | Delete (`X-API-Key`) |
| `GET /healthz`, `GET /readyz` | Liveness and readiness probes |
| `GET /metrics` | Prometheus metrics |
Decisions to defend in Q&A:- API key from a Kubernetes Secret: gives the Secret a real job and fixes an unauthenticated-DELETE weakness.- In-memory store with `replicas: 1`: more replicas would not share state. 
Redis only if HPA is attempted (stretch).- Metric labels use the route template (`/{code}`), never the raw code, to 
avoid unbounded label cardinality.- ZAP: use `zap-api-scan` with the OpenAPI spec; the baseline scan only spiders HTML and finds almost nothing on a JSON API.- CI cannot reach a local kind cluster, so "deploy" in CI means an ephemeral kind cluster inside the runner plus a smoke test. Argo CD (stretch) is the persistent-cluster answer.
## Roadmap (40 h)
| Phase | Dates | Hours | Ends with this demo |
| --- | --- | --- | --- |
| 0 Foundations | Nov 21-22 | 3 | Board with 10 issues, first PR merged via 
template |
| 1 Walking skeleton | Nov 23-Dec 1 | 17 | PR, green checks, image on Docker 
Hub, kind deploy, Grafana panel, Jaeger trace, ZAP report |
| 2 Harden core | Dec 2-7 | 9 | Bad PR blocked, fixed PR reaches the cluster, killed pod self-heals |
| 3 Stretch | Dec 7-10 | 4 | Depends on the item |
| 4 Freeze and deliver | Dec 10-14 | 7 | Report, rehearsals, fallback video; 
presentation Dec 15 |
Checkpoints: issues 1-6 merged by Nov 27, skeleton complete by Dec 1, feature 
freeze Dec 10. If behind, stretch dies first, never a core rubric item.
Stretch order: Dependabot + branch protection, Prometheus alerts + 
Alertmanager, k6 load test, Helm chart, SBOM + cosign, Argo CD. HPA, Loki, 
Kyverno, Terraform and cloud come after that.
## First 10 issues
| # | Title | Est. |
| --- | --- | --- |
| 1 | chore: bootstrap repo, project board and workflow rules | 1.5 h |
| 2 | feat(api): URL shortener endpoints, validation and tests | 2 h |
| 3 | build(docker): multi-stage Dockerfile and compose for the app | 1.5 h |
| 4 | ci: GitHub Actions workflow with lint and test on every PR | 2 h |
| 5 | feat(observability): Prometheus metrics, JSON logs, Prometheus + Grafana in compose | 2h |
| 6 | feat(observability): OpenTelemetry tracing to Jaeger | 1.5 h |
| 7 | ci(security): SAST with Bandit + Semgrep and secret scan with gitleaks | 1.5 h |
| 8 | ci(cd): build, Trivy scan and push to Docker Hub on main | 1.5 h |
| 9 | feat(k8s): kind cluster and core manifests | 3.5 h |
| 10 | ci(security): DAST with OWASP ZAP API scan on the running container | 1.5 h |
The acceptance criteria for each live in the GitHub issues.
## Top 3 risks
1. Time versus the learning curve (Kubernetes and Actions from zero). 
Mitigation: thin loop first, time-box each issue (at 2x the estimate, cut 
scope and log it), hold the checkpoints, keep the Dec 10 freeze.
2. The 20% for report, presentation and Q&A gets squeezed. Mitigation: save 
evidence in docs/evidence/ after every merged PR, write a short ADR per 
decision, rehearse twice with a timer, lock in the peer reviewer early.
3. Live-demo fragility (Wi-Fi, Docker Hub pull limits, kind plus Compose on 
WSL2). Mitigation: pre-pull images, pre-create the cluster, put every demo 
command behind a make target, record a fallback video.
## Architecture
Green solid is core, amber dashed is stretch. Trade-off: Prometheus, Grafana 
and Jaeger run in Compose and kind runs only the app, because a full in
cluster monitoring stack is heavy on 16 GB and doubles the Kubernetes 
learning load. In Phase 2, Compose's Prometheus is pointed at the port kind 
exposes so one dashboard shows the cluster workload