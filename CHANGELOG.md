# CHANGELOG.md

## Unreleased - 2026-05-13 (런타임 스토리 연결)

### Added
- `godot/data/story_dialogues.json` — 스피커·스테이지별 인트로/보스 인트로/클리어/반복 힌트 대사 묶음
- `Story` autoload (`scripts/core/Story.gd`) — 대사/용어를 현재 언어로 제공하는 단일 진입점
- `StoryBanner` UI (`scripts/ui/StoryBanner.gd`, `scenes/ui/StoryBanner.tscn`) — 비차단 자막 큐, 페이드 인/홀드/페이드 아웃
- 게임 시작 시 스테이지 인트로, 보스 등장 시 "봉인의 파수꾼이 깨어납니다" + 보스 대사, 승리 시 클리어 대사 자동 재생
- 승리 화면 부제 — "기억의 조각을 되찾았습니다."
- `CodexUI` 용어집 화면 (`scripts/ui/CodexUI.gd`, `scenes/ui/CodexUI.tscn`) — 메인 메뉴에서 진입, KO/EN 동기화
- Localization 키 — `boss_warning`, `result_fragment_recovered`, `btn_codex`, `codex_title`, `codex_hint`, `codex_safe_label`
- `WaveManager.boss_spawned` 시그널 — UI/오디오가 보스 등장 시점을 구독할 수 있도록 노출

### Changed
- 메인 메뉴 버튼 배치에 CODEX 항목 추가
- Result 패널 레이아웃에 부제 라벨 추가 (승리 시만 표시)

### Documentation
- `.agent/tasks.md`, `.agent/progress.md`, `.agent/decisions.md`, `HISTORY.md` 갱신

### Verification
- `story_dialogues.json`, `story_terms.json` JSON 문법 검사 통과
- 로컬 Godot headless 검증은 `godot` 실행 파일이 PATH에 없어 미실행 (정적 리뷰로 대체)

## Unreleased - 2026-05-13 (스토리 기준 문서)

### Added
- `docs/story/` 스토리 기준 문서 세트 추가
- Nightseed 용어 정의, 단계별 대사 공개 기준, UI 카피 기준 추가
- 향후 용어집/도감 UI를 위한 `godot/data/story_terms.json` 추가

### Changed
- 스테이지 설명 문구를 Nightseed 세계관 기준으로 갱신
- 원본 스토리 설계서 패키지를 `docs/story/source/nightseed-lore-story-update/`로 정리

### Documentation
- `docs/GAME_SPEC.md`, `docs/ARCHITECTURE.md`, `docs/ROADMAP.md`에 스토리 기반 작업 기준 반영
- `.agent/tasks.md`, `.agent/progress.md`, `.agent/decisions.md`, `HISTORY.md` 갱신

### Verification
- `stages.json`, `story_terms.json` JSON 문법 검사 통과
- 로컬 Godot headless 검증은 `godot` 실행 파일이 PATH에 없어 미실행

## v0.2.0 - 2026-05-07

### Added
- Godot 4 프로젝트 골격(`godot/`) 및 실행 가능한 `project.godot` 추가
- Milestone 1 플레이어블 프로토타입 씬/스크립트 추가
- 플레이어 이동(WASD/방향키), 체력, 피격 무적, 게임오버/재시작 루프 추가
- 적 기본 씬, 플레이어 추적 이동, 플레이어 주변 스폰 로직 추가
- HUD(HP, 생존 시간) 추가

### Changed
- 작업 우선순위를 Milestone 2(Combat Loop) 중심으로 갱신

### Documentation
- `.agent/tasks.md`, `.agent/progress.md`, `.agent/decisions.md` 갱신
- `HISTORY.md` 작업 이력 갱신

### Verification
- 로컬 Godot headless 검증 시도 (환경 의존)
- CI 검증은 푸시 후 GitHub Actions에서 확인

## v0.1.0 - 2026-05-06

### Added
- Nightseed Survivor 초기 설계 문서 추가
- Godot 4 기반 2D survivor-like MVP 설계 추가
- 기존 에이전트 작업 지침을 게임 프로젝트용 `AGENTS.md`로 통합
- Placeholder 그래픽 우선 개발 정책 추가
- 기존 장르의 아쉬운 점을 선반영하는 개선 전략 문서 추가
- 릴리즈 산출물 검증 체크리스트 추가

### Documentation
- `docs/GAME_SPEC.md` 추가
- `docs/IMPROVEMENT_STRATEGY.md` 추가
- `docs/ASSET_GUIDE.md` 추가
- `docs/ARCHITECTURE.md` 추가
- `docs/ROADMAP.md` 추가
- `docs/BALANCE.md` 추가
- `docs/RELEASE_CHECKLIST.md` 추가
- `.agent/tasks.md`, `.agent/progress.md`, `.agent/decisions.md` 추가
- `prompts/FIRST_AGENT_PROMPT.md` 추가

### Verification
- 문서 파일 생성 확인
- 실제 Godot 프로젝트 생성 및 빌드는 아직 수행하지 않음
