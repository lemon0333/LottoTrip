#!/bin/bash
# 로컬 백엔드(:8080)에 앱을 붙여 실행. TEST 유저(userId) JWT를 발급해 주입한다.
# 사용: scripts/run-app-local.sh [userId] [SCREEN]
set -e
cd "$(dirname "$0")/.."
source scripts/dev-secrets.env
USERID="${1:-1}"; SCREEN="${2:-login}"
TOK=$(python3 - "$JWT_SECRET" "$USERID" <<'PY'
import hmac,hashlib,base64,json,time,sys
secret,uid=sys.argv[1],sys.argv[2]
b=lambda x: base64.urlsafe_b64encode(x).rstrip(b'=').decode()
h=b('{"alg":"HS256","typ":"JWT"}'.encode()); now=int(time.time())
p=b(json.dumps({"sub":uid,"type":"access","iat":now,"exp":now+3600},separators=(',',':')).encode())
s=b(hmac.new(secret.encode(),f"{h}.{p}".encode(),hashlib.sha256).digest())
print(f"{h}.{p}.{s}")
PY
)
UDID=$(xcrun simctl list devices booted | grep -oE "[0-9A-F-]{36}" | head -1)
BID=com.lottotrip.app
xcrun simctl terminate "$UDID" "$BID" >/dev/null 2>&1 || true
SIMCTL_CHILD_API_BASE_URL="http://localhost:8080/api/v1" \
SIMCTL_CHILD_TEST_JWT="$TOK" \
SIMCTL_CHILD_SCREEN="$SCREEN" SIMCTL_CHILD_FIXED_COORD="37.7519,128.8761" \
  xcrun simctl launch "$UDID" "$BID"
echo "앱 실행: userId=$USERID, screen=$SCREEN, 로컬백엔드 연결"
