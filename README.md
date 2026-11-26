# Shortlink
A small URL-shortener REST API (FastAPI) used as the vehicle for an end-to
end DevOps pipeline: CI/CD, containers, observability, security scanning and 
Kubernetes.
Status: walking skeleton in progress. Plan and roadmap: docs/plan.md
## Run locally
python3 -m venv .venv && source .venv/bin/activate
pip install -r requirements-dev.txt
export API_KEY=dev-secret          
unset
uvicorn app.main:app --reload      
http://localhost:8000/docs
## API
# writes are refused while this is 
# interactive docs at 
| Endpoint | Auth | Purpose |
| --- | --- | --- |
| `POST /links` | `X-API-Key` | Create a short code for an http(s) URL (max 
2048 chars) |
| `GET /{code}` | none | 307 redirect to the stored URL, counts a hit |
| `GET /links/{code}` | none | Stats: `url`, `hits`, `created_at` |
| `DELETE /links/{code}` | `X-API-Key` | Delete a link |
| `GET /healthz` | none | Liveness probe |
| `GET /readyz` | none | Readiness probe (503 until `API_KEY` is configured) 
|
### Examples
Create a link:
    curl -s -X POST localhost:8000/links \
      -H "X-API-Key: dev-secret" -H "Content-Type: application/json" \
      -d '{"url":"https://example.com/docs"}'
    # {"code":"Ab3xQ_w","url":"https://example.com/docs"}
Follow it (shows the 307 status and the Location header):
    curl -i localhost:8000/Ab3xQ_w
Read its stats:
    curl -s localhost:8000/links/Ab3xQ_w
    # {"url":"https://example.com/docs","hits":1,"created_at":"2026-11
21T10:00:00+00:00"}
Delete it:
    curl -i -X DELETE localhost:8000/links/Ab3xQ_w -H "X-API-Key: dev-secret"   
# 204
Rejected inputs:
    curl -s -X POST localhost:8000/links -H "X-API-Key: dev-secret" \
      -H "Content-Type: application/json" -d '{"url":"javascript:alert(1)"}'    
# 422
    curl -s -X POST localhost:8000/links -H "Content-Type: application/json" 
\
      -d '{"url":"https://example.com"}'                                        
# 401
## Development
make test     # pytest
make lint    # ruff check + format check
Workflow: one task = one issue = one PR, with conventional commit titles. 
Decisions are recorded in docs/adr/.