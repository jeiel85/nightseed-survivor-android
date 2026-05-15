# ROADMAP

## Current Status - 2026-05-15

현재 `Nightseed Survivor`는 초기 MVP 마일스톤을 넘어 상용화 후보 폴리시 단계에 있다.

- 기본 플레이 시간은 5분이며, 최종 스테이지 `Cursed Tomb`은 5분 30초다.
- 캐릭터 5종, 스테이지 5종, 난이도 3단계, 무기 5종, 진화 2종, 적 10종+보스, 영구 강화, 업적, 스토리 배너/스토리 메뉴, PGS 리더보드, 멀티플랫폼 CI 빌드가 구현되어 있다.
- 다음 우선순위는 신규 기능 대량 추가가 아니라 데이터화, 저장 마이그레이션 준비, 성능 안정화, 출시 패키징 QA다.
- UI 완성도 개선은 `docs/UI_ART_DIRECTION_ROADMAP.md`를 기준으로 진행한다.

---

## Milestone 0: Repository Setup

- [ ] Create GitHub repository `nightseed-survivor`
- [ ] Add design document pack
- [ ] Confirm `AGENTS.md` project values
- [ ] Create initial commit
- [ ] Push to `main`
- [ ] Confirm repository opens correctly

---

## Milestone 1: Playable Prototype

Goal:

- 플레이어가 움직인다.
- 적이 플레이어를 따라온다.
- 적이 계속 생성된다.
- 플레이어가 적에게 닿으면 체력이 감소한다.
- 체력이 0이면 게임오버된다.

Tasks:

- [ ] Create Godot 4 project under `godot/`
- [ ] Add main gameplay scene
- [ ] Add player movement
- [ ] Add camera follow
- [ ] Add basic enemy scene
- [ ] Add enemy spawner
- [ ] Add enemy tracking movement
- [ ] Add player HP
- [ ] Add contact damage
- [ ] Add HUD with HP and survival time
- [ ] Add game over screen
- [ ] Use placeholder visuals only

Completion criteria:

- [ ] PC에서 WASD/방향키로 이동 가능
- [ ] 적이 화면 밖에서 생성됨
- [ ] 적이 플레이어를 추적함
- [ ] 체력 UI 표시
- [ ] 게임오버 화면 표시

---

## Milestone 2: Combat Loop

Goal:

- 기본 무기 Moon Dagger 구현
- 가장 가까운 적을 향해 자동 발사
- 적에게 피해 적용
- 적 사망 처리

Tasks:

- [ ] Add WeaponManager
- [ ] Add WeaponBase
- [ ] Add Moon Dagger
- [ ] Add projectile collision
- [ ] Add enemy HP
- [ ] Add enemy death
- [ ] Add kill counter
- [ ] Add simple object pool for projectiles

Completion criteria:

- [ ] 무기가 자동 발동됨
- [ ] 투사체가 적에게 충돌함
- [ ] 적 체력이 감소함
- [ ] 적이 죽으면 사라짐

---

## Milestone 3: Growth Loop

Goal:

- 경험치 보석과 레벨업 구현

Tasks:

- [ ] Add experience gems
- [ ] Add XP pickup radius
- [ ] Add XP bar
- [ ] Add level system
- [ ] Add level-up pause state
- [ ] Add LevelUpScreen
- [ ] Add 3 upgrade cards
- [ ] Add first passive upgrade
- [ ] Tune first level-up to happen within 30 seconds

Completion criteria:

- [ ] 경험치 보석 획득 가능
- [ ] 레벨업 시 게임이 멈춤
- [ ] 3개의 선택지가 표시됨
- [ ] 선택 후 능력치가 적용됨

---

## Milestone 4: Content MVP

Goal:

- 무기, 패시브, 적, 웨이브 확장

Tasks:

- [ ] Add 5 weapons
- [ ] Add 5 passives
- [ ] Add 4 enemy types
- [ ] Add WaveDirector
- [ ] Add boss
- [x] Add 5-minute clear condition
- [x] Add clear screen

Completion criteria:

- [ ] 각 무기가 독립적으로 작동
- [ ] 패시브 효과가 능력치에 반영됨
- [ ] 최대 레벨 제한이 적용됨
- [ ] 시간에 따라 적 종류와 수가 달라짐
- [x] 마지막 30초에 보스 등장
- [x] 5분 생존 시 클리어 화면 표시

---

## Milestone 5: Persistence

Goal:

- 골드와 영구 강화 구현

Tasks:

- [ ] Add gold drops
- [ ] Add SaveManager
- [ ] Add permanent upgrade data
- [ ] Add permanent upgrade screen
- [ ] Add upgrade purchase
- [ ] Apply permanent upgrade effects
- [ ] Save best survival time
- [ ] Save total kills
- [ ] Save total runs

Completion criteria:

- [ ] 골드가 저장됨
- [ ] 강화 레벨이 저장됨
- [ ] 게임 재실행 후에도 데이터 유지
- [ ] 강화 효과가 플레이어에게 적용됨

---

## Milestone 6: Asset Replacement Readiness

Goal:

- placeholder에서 실제 애셋으로 교체하기 쉬운 구조 확인

Tasks:

- [ ] Confirm Visual node separation
- [ ] Confirm asset path structure
- [ ] Add first real or test sprite replacement
- [ ] Validate collision shapes after replacement
- [ ] Update ASSET_GUIDE if rules change

Completion criteria:

- [ ] Sprite 교체가 로직 수정 없이 가능
- [ ] 플레이어/적/투사체/픽업의 시각 노드가 분리되어 있음

---

## Milestone 7: Android Readiness

Goal:

- Android export 준비

Tasks:

- [ ] Add virtual joystick
- [ ] Adjust UI scaling
- [ ] Add Android export preset
- [ ] Test Android build through CI
- [ ] Verify APK asset is generated
- [ ] Check release checklist

Completion criteria:

- [ ] Android에서 실행 가능
- [ ] 터치 조이스틱으로 이동 가능
- [ ] UI가 작은 화면에서도 깨지지 않음
- [ ] GitHub Actions에서 APK가 생성됨

---

## Milestone 8: Story Foundation

Goal:

- Nightseed 세계관을 정식 문서와 데이터로 고정한다.
- 컷신 없이도 스테이지 설명과 짧은 UI 문구에서 스토리 방향이 드러나게 한다.

Tasks:

- [x] Add `docs/story/` story document set
- [x] Add Nightseed lore definition
- [x] Add staged dialogue reveal guide
- [x] Add UI copy guide
- [x] Add `godot/data/story_terms.json`
- [x] Update stage descriptions with story copy
- [x] Add runtime story event/codex UI
- [x] Add boss warning and clear subtitle UI copy

Completion criteria:

- [x] Nightseed의 의미와 금지 표현이 문서화됨
- [x] 스테이지 설명이 세계관 문구와 연결됨
- [x] 플레이 중 스토리 이벤트가 짧은 UI로 표시됨

---

## Milestone 9: Commercialization Foundation

Goal:

- 현재 구현된 기능을 출시 후보 수준으로 안정화한다.
- 밸런스와 콘텐츠 수정을 코드 수정 없이 반복하기 쉬운 구조로 옮긴다.

Tasks:

- [ ] 무기/패시브/캐릭터/적 수치 데이터화
- [ ] 저장 데이터 `schema_version` 도입 및 마이그레이션 계획 작성
- [ ] 투사체/XP 보석/골드 object pool 1차 적용
- [ ] 적 탐색 캐시 도입
- [ ] QA용 로컬 run summary 저장
- [ ] Android 실기기 성능 체크리스트 작성
- [ ] PGS 로그인 실패·오프라인 모드 QA
- [ ] GitHub Actions 산출물 검증 자동화 강화

---

## Milestone 10: UI Art Direction

Goal:

- 네모난 버튼 중심의 기능 UI를 Nightseed 세계관이 드러나는 모바일 게임 UI로 개선한다.
- 메인 메뉴, 레벨업 카드, 결과 화면, 하위 선택 화면이 같은 아트 방향을 공유하도록 만든다.

Reference:

- `docs/UI_ART_DIRECTION_ROADMAP.md`

Tasks:

- [ ] 공통 UI 키트 정리 (`ButtonStyles.gd` Moon/Stone 계열)
- [ ] 메인 메뉴 배경/캐릭터 쇼케이스 1차 리워크
- [ ] 선택 캐릭터 portrait/fallback 표시
- [ ] 레벨업 카드 보상 카드 스타일 리워크
- [ ] 결과 화면 보상/승패 연출 리워크
- [ ] 캐릭터/스테이지/상점 화면 톤 맞추기
