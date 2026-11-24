# Teams 크롬 앱 (Linux)

Microsoft Teams 를 Chrome/Chromium 앱 창으로 띄우는 런처. 전용 프로필(`~/.config/chrome-teams`)을 써서 크롬과 별개 프로세스로 뜨므로, GNOME Dock 에 크롬 아이콘에 묶이지 않고 **Teams 아이콘으로 따로** 표시된다.

필요한 것: Google Chrome 또는 Chromium. 배포 파일은 `dist/` 에 있다.

## 설치

### A. 설치 스크립트 (권장, sudo 불필요)

`dist/teams-chrome-install.sh` 파일 하나만 옮기면 된다 (아이콘 포함).

```sh
bash teams-chrome-install.sh                # 설치 + Dock 즐겨찾기에 추가
bash teams-chrome-install.sh --no-pin       # 설치만
bash teams-chrome-install.sh --uninstall    # 제거 (로그인 프로필은 남김)
bash teams-chrome-install.sh --purge        # 제거 + 프로필 삭제
```

설치 위치는 그 사용자 계정 안(`~/.local/bin`, `~/.local/share`)이다.

### B. .deb 패키지 (PC 의 모든 사용자에게)

```sh
sudo apt install ./teams-chrome-app_1.0.0_all.deb
teams-chrome --pin                          # 각 사용자가 Dock 즐겨찾기에 추가 (선택)
sudo apt remove teams-chrome-app            # 제거
```

## 사용

- 앱 목록에서 **Microsoft Teams** 를 실행한다.
- 처음 한 번 MS 계정으로 로그인한다. 크롬 기본 프로필과 로그인 정보를 공유하지 않는다.
- `teams-chrome --pin` / `--unpin`: GNOME Dock 즐겨찾기에 넣거나 뺀다.
- 환경 변수 `TEAMS_URL`: 다른 주소로 열 때. `TEAMS_BROWSER`: 브라우저 실행 파일을 직접 지정할 때.
- snap 크로미움이면 프로필은 `~/snap/chromium/common/chrome-teams` 에 둔다 (snap 은 숨김 폴더에 못 쓴다).

## 다시 만들기

`src/` 를 고친 뒤 `./build.sh` 를 실행하면 `dist/` 의 두 파일이 새로 만들어진다. 버전은 `build.sh` 의 `VERSION`.

| 파일 | 역할 |
|---|---|
| `src/teams-chrome` | 실행 스크립트: 브라우저를 찾아 전용 프로필·`--class=Teams` 로 연다, `--pin`/`--unpin` |
| `src/teams-chrome.desktop` | 메뉴 항목 (`StartupWMClass=Teams` 가 `--class` 와 같아야 Dock 아이콘이 맞는다) |
| `src/teams-chrome.png` | 아이콘 256px |
| `src/install.sh.in` | 설치 스크립트 틀. `build.sh` 가 위 세 파일을 base64 로 넣는다 |

시험 환경: Ubuntu 24.04 GNOME (X11), Google Chrome 158. Wayland 세션·Chromium 에서는 시험하지 않았다.
