# ROADMAP

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
- [ ] Add 10-minute clear condition
- [ ] Add clear screen

Completion criteria:

- [ ] 각 무기가 독립적으로 작동
- [ ] 패시브 효과가 능력치에 반영됨
- [ ] 최대 레벨 제한이 적용됨
- [ ] 시간에 따라 적 종류와 수가 달라짐
- [ ] 9분 30초에 보스 등장
- [ ] 10분 생존 시 클리어 화면 표시

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
