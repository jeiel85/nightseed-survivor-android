# Progress

## 2026-05-13

### Status

Nightseed 스토리 기반 문서화 및 스테이지 문구 반영 완료.

### Completed

- `docs/story/` 정식 스토리 문서 폴더 추가
- Nightseed 용어 정의, 단계별 대사 공개 기준, UI 카피 기준 정리
- 원본 스토리 설계서 패키지를 `docs/story/source/nightseed-lore-story-update/`로 이동
- 향후 용어집/도감 UI 기반 데이터 `godot/data/story_terms.json` 추가
- 스테이지 선택 설명 문구를 Nightseed 세계관 기준으로 갱신

### Not Yet Done

- 플레이 중 대사/스토리 이벤트 UI 구현
- 용어집 또는 도감 UI 구현
- 보스 경고/클리어 보조 문구의 런타임 연결

## 2026-05-13

### Status

GitHub Pages 배포 구조 개편 완료.

### Completed

- 브랜딩 페이지용 HTML/CSS 작성 (`branding/index.html`)
- GitHub Actions 워크플로우(`android-build.yml`) 수정
- 루트(`/`) 배포 디렉토리에 브랜딩 페이지 및 자산 배치 로직 추가
- 게임 실행 경로를 `/live/` 폴더로 이동하여 웹 플레이 환경 분리
- `play_store` 자산을 브랜딩 페이지에서 사용하도록 복사 자동화

## 2026-05-07

### Status

Milestone 1 Playable Prototype 구현 완료.

### Completed

- Godot 4 프로젝트 구조(`godot/`) 초기화
- `project.godot` 생성 및 입력 액션(WASD/화살표) 설정
- 메인 게임 씬(`GameRoot.tscn`) 생성
- 플레이어 이동/체력/피격 무적 처리 구현
- 플레이어 추적 적(`EnemyBase`) 및 접촉 데미지 구현
- 플레이어 주변 스폰 방식의 `EnemySpawner` 구현
- 카메라 추적 구성
- HUD(HP/생존 시간) 구현
- HP 0 시 게임오버 및 재시작 버튼 구현

### Not Yet Done

- 무기 자동 공격 루프(Milestone 2)
- 적 HP/사망 및 처치 카운트
- 경험치/레벨업 시스템
- 영구 강화/저장 시스템
- Android export 검증
- GitHub Actions 워크플로우 구축 및 검증
