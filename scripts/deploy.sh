#!/usr/bin/env bash
set -euo pipefail

revision="${1:?Expected the tested Git commit SHA}"
[[ "$revision" =~ ^[0-9a-f]{40}$ ]] || { echo "Invalid commit SHA"; exit 1; }
exec 9>/var/lock/flask-web-app-deploy.lock
flock -w 120 9
cd /root/flask-web-app
git fetch --prune origin main
git merge-base --is-ancestor "$revision" origin/main
git checkout --detach "$revision"
.venv/bin/python -m pip install -r requirements.txt
.venv/bin/python -m unittest discover -s tests -v
supervisorctl restart flask-web-app

for attempt in {1..20}; do
    if .venv/bin/python - <<'PY'
import urllib.request
from src.app import app
with urllib.request.urlopen("http://127.0.0.1:5000/", timeout=3) as response:
    actual = response.read().decode()
expected = app.test_client().get("/").get_data(as_text=True)
assert actual == expected, (actual, expected)
print("HTTP health check passed:", actual)
PY
    then
        supervisorctl status flask-web-app
        echo "Deployed commit: $(git rev-parse HEAD)"
        exit 0
    fi
    sleep 1
done
supervisorctl tail flask-web-app
exit 1
