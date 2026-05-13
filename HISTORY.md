# HISTORY.md

## 2026-05-13

- 날짜: 2026-05-13
- 작업: Nightseed 런타임 스토리 연결 (StoryBanner + CodexUI)
- 변경 파일:
  - godot/data/story_dialogues.json (신규)
  - godot/scripts/core/Story.gd (신규 autoload)
  - godot/scripts/ui/StoryBanner.gd (신규)
  - godot/scenes/ui/StoryBanner.tscn (신규)
  - godot/scripts/ui/CodexUI.gd (신규)
  - godot/scenes/ui/CodexUI.tscn (신규)
  - godot/project.godot (Story autoload 등록)
  - godot/scripts/core/WaveManager.gd (`boss_spawned` 시그널 추가)
  - godot/scripts/core/GameRoot.gd (스테이지 인트로/보스 등장/승리 자막 연결)
  - godot/scenes/main/GameRoot.tscn (StoryBanner 노드, Result 부제 라벨 추가)
  - godot/scripts/ui/MainMenu.gd (CODEX 버튼 연결)
  - godot/scenes/ui/MainMenu.tscn (CODEX 버튼 추가)
  - godot/scripts/core/Localization.gd (codex_*, boss_warning, result_fragment_recovered 등 키 추가)
  - .agent/tasks.md, .agent/progress.md, .agent/decisions.md, CHANGELOG.md (수정)
- 검증:
  - `godot/data/story_dialogues.json` JSON 문법 검사 통과
  - 정적 코드 리뷰로 노드 경로/시그널/Localization 키 일치 확인
  - 로컬 환경에서 `godot` 실행 파일이 PATH에 없어 Godot headless 검증은 미실행 — Godot 설치 환경에서 한 판 플레이 검증 필요
- 결과:
  - 게임 시작 시 스테이지 인트로, 보스 등장 시 경고 + 보스 대사, 승리 시 클리어 대사가 비차단 자막으로 흐름
  - 메인 메뉴 → CODEX 진입 가능, KO/EN 토글 동기화
- 후속 작업:
  - 반복 플레이 시 인트로를 반복 힌트로 대체하는 분기
  - 용어 잠금/해금 (스테이지 클리어 시 추가 용어 노출)

## 2026-05-13

- 날짜: 2026-05-13
- 작업: Nightseed 스토리 기반 문서화 및 스테이지 문구 반영
- 변경 파일:
  - docs/story/README.md (신규)
  - docs/story/STORY_FINAL_SPEC.md (신규)
  - docs/story/STORY_NIGHTSEED_LORE.md (신규)
  - docs/story/STORY_STAGE_DIALOGUE.md (신규)
  - docs/story/STORY_UI_COPY.md (신규)
  - docs/story/source/nightseed-lore-story-update/ (원본 설계서 이동)
  - godot/data/story_terms.json (신규)
  - godot/data/stages.json (수정)
  - godot/scripts/core/Localization.gd (수정)
  - docs/GAME_SPEC.md (수정)
  - docs/ARCHITECTURE.md (수정)
  - docs/ROADMAP.md (수정)
  - .agent/tasks.md (수정)
  - .agent/progress.md (수정)
  - .agent/decisions.md (수정)
  - CHANGELOG.md (수정)
- 검증:
  - `godot/data/stages.json`, `godot/data/story_terms.json` JSON 문법 검사 통과
  - `godot --headless --path godot --quit` 실행 시도
  - 로컬 환경에서 `godot` 실행 파일을 찾을 수 없어 Godot headless 검증은 미실행
- 결과:
  - 스토리 기준 문서와 기반 데이터 추가 완료. 런타임 실행 검증은 CI 또는 Godot 설치 환경에서 확인 필요.
- 후속 작업:
  - 런타임 스토리 이벤트 UI 구현

## 2026-05-13

- 날짜: 2026-05-13
- 작업: GitHub Pages 배포 구조 개편 및 브랜딩 페이지 적용
- 변경 파일:
  - branding/index.html (신규)
  - .github/workflows/android-build.yml (수정)
- 검증:
  - 브랜딩 페이지 HTML 생성 확인
  - GitHub Actions 워크플로우 로직 수정 확인 (루트: 브랜딩, /live: 게임)
- 결과:
  - 성공. 이제 `main` 브랜치 푸시 시 새로운 구조로 자동 배포됨.
- 후속 작업:
  - 브랜딩 페이지 디자인 고도화 (필요시)

## 2026-05-07

- 날짜: 2026-05-07
- 작업: Milestone 1 Playable Prototype 구현 (Godot 프로젝트 초기화 및 기본 생존 루프)
- 변경 파일:
  - godot/project.godot
  - godot/scenes/main/GameRoot.tscn
  - godot/scenes/main/HUD.tscn
  - godot/scenes/player/Player.tscn
  - godot/scenes/enemies/EnemyBase.tscn
  - godot/scripts/core/GameRoot.gd
  - godot/scripts/player/Player.gd
  - godot/scripts/enemies/EnemyBase.gd
  - godot/scripts/enemies/EnemySpawner.gd
  - godot/scripts/ui/HUD.gd
  - .agent/tasks.md
  - .agent/progress.md
  - .agent/decisions.md
  - CHANGELOG.md
  - HISTORY.md
- 검증:
  - `godot --headless --path godot --quit` 실행 시도
  - CI는 로컬 푸시 후 GitHub Actions 확인 예정
- 결과:
  - 플레이어 이동, 적 스폰/추적, 접촉 데미지, HP/HUD, 게임오버 루프 구현 완료
- 후속 작업:
  - Milestone 2(자동 무기/전투 루프) 구현

## 2026-05-06

- 작업: Nightseed Survivor 최종 설계 묶음 작성
- 변경 파일:
  - README.md
  - AGENTS.md
  - CHANGELOG.md
  - HISTORY.md
  - docs/GAME_SPEC.md
  - docs/IMPROVEMENT_STRATEGY.md
  - docs/ASSET_GUIDE.md
  - docs/ARCHITECTURE.md
  - docs/ROADMAP.md
  - docs/BALANCE.md
  - docs/RELEASE_CHECKLIST.md
  - .agent/tasks.md
  - .agent/progress.md
  - .agent/decisions.md
  - prompts/FIRST_AGENT_PROMPT.md
- 검증:
  - 문서 구조 생성 확인
  - 실제 Godot 프로젝트 생성 및 실행 검증은 아직 수행하지 않음
- 결과:
  - 성공
- 후속 작업:
  - GitHub 저장소 생성
  - 문서 묶음 업로드
  - Godot 프로젝트 초기화
  - Milestone 1: Playable Prototype 구현 시작
