#!/usr/bin/env bash
# src/ 로 배포 파일 두 개를 만든다.
#   dist/teams-chrome-install.sh       파일 하나짜리 사용자 설치 스크립트 (sudo 불필요)
#   dist/teams-chrome-app_<버전>_all.deb  시스템 설치 패키지 (sudo apt install ./…deb)
set -euo pipefail

VERSION=1.0.0
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC="$ROOT/src"
DIST="$ROOT/dist"
rm -rf "$DIST"; mkdir -p "$DIST"

# ---- 1) 사용자 설치 스크립트: 실행 파일·아이콘·메뉴 항목을 base64 로 넣는다 ----
python3 - "$SRC" "$DIST/teams-chrome-install.sh" "$VERSION" <<'PY'
import base64, sys
from pathlib import Path
src, out, version = Path(sys.argv[1]), Path(sys.argv[2]), sys.argv[3]
b64 = lambda name: base64.encodebytes((src / name).read_bytes()).decode().strip()
text = (src / "install.sh.in").read_text(encoding="utf-8")
for key, value in {"@VERSION@": version, "@LAUNCHER_B64@": b64("teams-chrome"),
                   "@ICON_B64@": b64("teams-chrome.png"), "@DESKTOP_B64@": b64("teams-chrome.desktop")}.items():
    assert key in text, key
    text = text.replace(key, value)
out.write_text(text, encoding="utf-8")
out.chmod(0o755)
PY

# ---- 2) .deb: /usr/bin/teams-chrome, /usr/share/applications, /usr/share/icons ----
PKG="$DIST/pkg"
install -Dm755 "$SRC/teams-chrome"         "$PKG/usr/bin/teams-chrome"
install -Dm644 "$SRC/teams-chrome.desktop" "$PKG/usr/share/applications/teams-chrome.desktop"
install -Dm644 "$SRC/teams-chrome.png"     "$PKG/usr/share/icons/hicolor/256x256/apps/teams-chrome.png"
mkdir -p "$PKG/DEBIAN"
cat > "$PKG/DEBIAN/control" <<EOF
Package: teams-chrome-app
Version: $VERSION
Architecture: all
Maintainer: teams-chrome-app <noreply@localhost>
Depends: bash, python3
Recommends: google-chrome-stable | chromium | chromium-browser
Section: net
Priority: optional
Description: Microsoft Teams as a Chrome app with its own dock icon
 Opens https://teams.microsoft.com/ in a Chrome/Chromium app window that uses
 a dedicated profile (~/.config/chrome-teams), so GNOME shows it as a separate
 "Microsoft Teams" icon instead of grouping it under Chrome.
 Run "teams-chrome --pin" to add it to the GNOME dock favorites.
EOF
dpkg-deb --root-owner-group --build "$PKG" "$DIST/teams-chrome-app_${VERSION}_all.deb" >/dev/null
rm -rf "$PKG"

ls -la "$DIST"
