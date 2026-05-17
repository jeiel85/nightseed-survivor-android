# 잔불의 밤 (Nightseed Survivor)

Godot 4.2.2로 제작 중인 2D 오프라인 서바이버라이크. 이동만 조작하고, 자동 발사 무기와 레벨업 선택으로 5분 동안 몰려드는 적을 버팁니다.

[![Build](https://github.com/jeiel85/nightseed-survivor/actions/workflows/android-build.yml/badge.svg)](https://github.com/jeiel85/nightseed-survivor/actions/workflows/android-build.yml)

![Nightseed Survivor key visual](docs/images/readme.png)

> 밤의 씨앗이 깨어난 세계. 다섯 영웅 중 하나를 골라 자동 무기 빌드를 완성하고, 마지막 30초에 깨어나는 보스를 쓰러뜨리세요. 실패해도 골드와 영구 강화가 남아 다음 도전이 더 강해집니다.

## 바로 플레이 / 다운로드

| 플랫폼 | 링크 |
|---|---|
| Web | https://jeiel85.github.io/nightseed-survivor/ |
| Google Play | https://play.google.com/store/apps/details?id=com.nightseed.survivor |
| Android APK | https://github.com/jeiel85/nightseed-survivor/releases/latest |
| Windows / Linux | https://github.com/jeiel85/nightseed-survivor/releases/latest |

GitHub Pages는 브랜딩 페이지와 웹 빌드를 함께 배포합니다. 실제 게임은 웹 페이지의 플레이 버튼 또는 `/live/` 경로에서 실행됩니다.

## 현재 상태

초기 MVP 범위를 넘어 상용화 후보 폴리시 단계입니다.

- 캐릭터 5종, 스테이지 5종, 난이도 3단계
- 자동 공격 무기 5종, 진화 무기 2종
- 적 10종, 미니보스, 최종 보스
- 경험치 보석, 골드, 영구 강화, 로컬 저장
- 레벨업 선택 UI, 결과 화면, 업적, 스토리 배너/스토리 메뉴
- 한국어 / English 다국어 UI
- 모바일 세로 화면, 터치 조이스틱, PC WASD/방향키 지원
- Android, Windows, Linux, Web 빌드용 GitHub Actions 파이프라인

최근 작업은 메인 메뉴 픽셀아트 리워크, 한국어 게임명 정리, LevelUp 카드 픽셀아트 패널, Galmuri 11 픽셀 폰트, 다국어 레이아웃 안전화입니다. 자세한 이력은 [CHANGELOG.md](CHANGELOG.md)와 [HISTORY.md](HISTORY.md)를 참고하세요.

## 게임 구성

### 캐릭터

| 캐릭터 | 해금 | 시작 무기 | 특징 |
|---|---:|---|---|
| Vagrant | 기본 | Moon Dagger | 균형형 |
| Spirit Sister | 200g | Spirit Orb | 자석 강화, 낮은 HP |
| Hunter | 500g | Star Needle | 빠른 이동 |
| Berserker | 1000g | Thorn Ring | 높은 HP와 피해량, 느린 이동 |
| Pyromancer | 1500g | Fire Wisp | 위습 기반 광역 화력 |

### 무기

| 무기 | 역할 | 진화 |
|---|---|---|
| Moon Dagger | 가까운 적 추적 투사체 | Crescent Storm |
| Spirit Orb | 플레이어 주변 공전 방어선 | Eternal Halo |
| Fire Wisp | 적 밀집 지역 폭발 | 예정 |
| Thorn Ring | 포위 돌파용 방사형 가시 | 예정 |
| Star Needle | 넓은 부채꼴 탄막 | 예정 |

### 스테이지 / 난이도

- 스테이지: Forest of Echoes, Frozen Wastes, Twilight Sanctum, Inferno Chasm, Cursed Tomb
- 기본 스테이지는 5분, Cursed Tomb은 5분 30초
- 난이도: Normal, Hard, Nightmare
- 미니보스는 60초 간격으로 등장하고, 최종 보스는 마지막 30초에 등장합니다.

스테이지 데이터는 [godot/data/stages.json](godot/data/stages.json)에 정의되어 있습니다.

## 알려진 이슈

- Godot 4.2 헤드리스 export 환경에서 Play Games Services / AdMob native `.aar`가 누락되는 문제가 있습니다. GUI 에디터 export 또는 Godot 업그레이드로 해결할 예정입니다.
- Pyromancer의 Fire Wisp 공격 미동작 의심 보고가 있어 v0.26.1 이후 logcat 기반 진단 대상입니다.
- 현재 AdMob은 테스트 ID 단계입니다. 실제 광고 ID 전환은 Play Console / AdMob 설정이 준비된 뒤 별도 진행합니다.

## 로컬 실행

```powershell
godot --path godot
```

빠른 스크립트 검증:

```powershell
godot --headless --path godot --quit
```

Windows에서 로컬 Godot 실행 파일을 직접 지정하는 경우:

```powershell
.\Godot_v4.2.2-stable_win64.exe --path godot
```

## 로컬 빌드

```powershell
# Windows
godot --headless --path godot `
  --export-release "Windows Desktop" "build\nightseed-survivor.exe"

# Linux
godot --headless --path godot `
  --export-release "Linux/X11" "build\nightseed-survivor.x86_64"

# Web
godot --headless --path godot `
  --export-release "Web" "build\web\index.html"

# Android APK
godot --headless --path godot `
  --export-release "Android" "build\nightseed-survivor-release.apk"
```

Android 릴리즈 빌드는 keystore 환경 변수가 필요합니다.

```powershell
$env:GODOT_ANDROID_KEYSTORE_RELEASE_PATH = "$PWD\secrets\release.keystore"
$env:GODOT_ANDROID_KEYSTORE_RELEASE_USER = "nightseed"
$env:GODOT_ANDROID_KEYSTORE_RELEASE_PASSWORD = "<password>"
```

## CI / 릴리즈

[.github/workflows/android-build.yml](.github/workflows/android-build.yml)이 멀티플랫폼 빌드와 Pages 배포를 처리합니다.

| 트리거 | 동작 |
|---|---|
| `main` push | Android / Windows / Linux / Web 빌드, GitHub Pages 배포 |
| `v*` tag push | 빌드 후 GitHub Release 생성 및 산출물 첨부 |

릴리즈 생성:

```powershell
git tag -a v0.X.Y -m "릴리즈 메모"
git push origin v0.X.Y
```

## 프로젝트 구조

```text
godot/
  addons/                  # PGS, AdMob 등 Godot 플러그인
  android/                 # Android build template
  assets/                  # 폰트, 아이콘, 스프라이트, UI 자산
  data/                    # 스테이지/스토리 JSON
  scenes/                  # Godot 씬
  scripts/                 # GDScript 코드
  web_extras/              # Web 빌드 보조 파일
branding/                  # GitHub Pages 소개 페이지
docs/                      # 설계, 로드맵, 출시/플랫폼 문서
play_store/                # 스토어 등록정보와 릴리즈 노트
.agent/                    # 에이전트 작업/진행/판단 기록
.github/workflows/         # CI
```

## 주요 문서

- [게임 명세](docs/GAME_SPEC.md)
- [아키텍처](docs/ARCHITECTURE.md)
- [로드맵](docs/ROADMAP.md)
- [밸런스](docs/BALANCE.md)
- [상용화 개선 분석](docs/COMMERCIALIZATION_ANALYSIS.md)
- [UI 아트 디렉션 로드맵](docs/UI_ART_DIRECTION_ROADMAP.md)
- [릴리즈 체크리스트](docs/RELEASE_CHECKLIST.md)

## 라이선스 / 자산

- 엔진: [Godot Engine 4.2.2](https://godotengine.org/) (MIT)
- 스프라이트: [Kenney Tiny Dungeon](https://kenney.nl/assets/tiny-dungeon) (CC0 1.0)
- 폰트: [Galmuri](https://github.com/quiple/galmuri) (OFL), [Pretendard](https://github.com/orioncactus/pretendard) (OFL)
- Play Games Services 플러그인: [godot-sdk-integrations/godot-play-game-services](https://github.com/godot-sdk-integrations/godot-play-game-services) (MIT)
- AdMob 플러그인: [poing-studios/godot-admob-plugin](https://github.com/poing-studios/godot-admob-plugin)
- Web COI 서비스 워커: [gzuidhof/coi-serviceworker](https://github.com/gzuidhof/coi-serviceworker) (MIT)
- 오디오는 외부 음원 없이 GDScript 절차 생성 사운드를 사용합니다.
