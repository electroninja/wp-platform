#!/bin/bash
set -e
STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8080)
if [ "$STATUS" -ne 200 ]; then
echo "Smoke test failed: got HTTP $STATUS"
exit 1
fi
echo "Smoke test passed: HTTP 200"
