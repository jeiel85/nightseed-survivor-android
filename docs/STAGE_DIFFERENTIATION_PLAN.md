# 스테이지 차별화 계획서

> 작성: 2026-05-17 (v0.27.0 직후)
> 트리거: 사용자가 두번째 스테이지(Frozen Wastes)를 플레이했을 때 "배경이 똑같던데?" 피드백.
> 목표: 5개 스테이지(Forest / Frozen Wastes / Twilight Sanctum / Inferno Chasm / Cursed Tomb)가 각자 다른 세계처럼 느껴지도록 시각 차별화.

이 문서는 다음 세션에서 컨텍스트 0인 상태로 실행할 수 있도록 작성됨. 진단 결과 + 단기/중기 작업 단위 + 의사결정 포인트를 모두 포함.

---

## 1. 진단 결과 (이번 세션에서 확인)

### 1.1 배경 시스템 — **작동 중이지만 색차가 너무 미묘**

- [godot/data/stages.json](../godot/data/stages.json) 의 각 스테이지에 `bg` 팔레트(`void/tile/pebble_a/pebble_b/firefly/decor/torch_glow`) 7개 색 정의되어 있음
- [GameRoot._apply_stage_background()](../godot/scripts/core/GameRoot.gd) 가 `_ready()`에서 호출 → `Stages.get_stage()` 로 팔레트 읽어 `background_rect.color` 와 `ground_tiler.apply_tone(tone)` 적용 — **정상**
- [BackgroundTiler.apply_tone()](../godot/scripts/fx/BackgroundTiler.gd) 가 6개 modulate 필드(`tile_modulate / pebble_color_a / pebble_color_b / firefly_color / decor_modulate / torch_glow_color`) 갱신 + `queue_redraw()` — **정상**

**문제**: 색차가 너무 작음. 예를 들어 Forest 보이드 `[0.05, 0.08, 0.06]` vs Frozen 보이드 `[0.06, 0.08, 0.12]` — B채널만 6% 증가, R/G 동일. 폰 화면에서 "둘 다 그냥 어두운 색"으로 보임.

### 1.2 적 외형 — **스테이지 무관 hardcoded**

- [EnemyBase.gd:12](../godot/scripts/enemies/EnemyBase.gd) `@export var body_color: Color`
- 각 enemy 씬(EnemySlime/Bat/Knight/Hound/Dasher/Caster/Splitter/MiniBoss/Boss)에서 `body_color` 를 고정 색으로 설정
  - Slime: 형광 초록 / Bat: 주황 / Knight: 청회색 …
- 어떤 스테이지에서 spawn 되어도 같은 색. Frozen Wastes에서도 형광 초록 슬라임이 등장.

### 1.3 스테이지별 적 풀(pool) — **이미 다름** (참고용)

[godot/data/stages.json](../godot/data/stages.json) 의 `waves[].types`:

| 스테이지 | 등장 타입 |
|---|---|
| Forest | slime / bat / knight / hound / dasher / caster / splitter |
| Frozen Wastes | bat / hound / knight (제한적) |
| Twilight Sanctum | slime / bat / knight / dasher / hound / caster / splitter |
| Inferno Chasm | knight / slime / bat / hound / dasher / caster / splitter |
| Cursed Tomb | slime / knight / bat / hound / dasher / caster / splitter (가장 다양) |

→ pool 차이는 있지만 "어차피 색이 같아서" 체감이 안 됨.

### 1.4 BGM — **별도 트랙은 있음** ([AudioManager.gd](../godot/scripts/core/AudioManager.gd))

- `play_bgm("game")` 으로 한 트랙만 재생. 스테이지별 분기 없음. 차후 BGM 차별화도 단기 작업 후보.

---

## 2. 작업 단계 — 단기 (Stage A) / 중기 (Stage B)

사용자와 합의된 순서: **A 먼저 → 체감 확인 → 부족하면 B**. 한 번에 다 가지 말 것.

---

## Stage A — 코드만 (예상 작업: 1세션 안에 끝)

목표: 자산 추가 없이, 색조와 modulate만으로 5개 스테이지가 시각적으로 확실히 구분되게 만든다. 폰 화면에서 "다른 세계"로 즉시 인식 가능한 수준.

### A1. bg 팔레트 색차 확대 ([godot/data/stages.json](../godot/data/stages.json))

각 스테이지의 핵심 색 채널을 더 강하게 분리. 보이드/타일/펩블 모두 한 hue로 통일성을 유지하면서 채도/명도 차이를 크게.

**추천 팔레트** (RGBA 0~1, 검토 후 조정):

| 스테이지 | void | tile | pebble_a | pebble_b | firefly | decor | torch_glow |
|---|---|---|---|---|---|---|---|
| Forest (녹/이끼) | `[0.04, 0.10, 0.05, 1]` | `[0.28, 0.46, 0.32, 1]` | `[0.55, 0.78, 0.50, 0.55]` | `[0.16, 0.32, 0.20, 0.55]` | `[0.78, 1.00, 0.75, 0.95]` | `[0.40, 0.58, 0.42, 1]` | `[0.55, 1.00, 0.55, 0.50]` |
| Frozen Wastes (얼음/푸른) | `[0.04, 0.06, 0.14, 1]` | `[0.32, 0.48, 0.72, 1]` | `[0.70, 0.85, 1.00, 0.60]` | `[0.18, 0.28, 0.50, 0.60]` | `[0.85, 0.95, 1.00, 0.95]` | `[0.50, 0.65, 0.85, 1]` | `[0.55, 0.80, 1.00, 0.55]` |
| Twilight Sanctum (보라/마법) | `[0.07, 0.05, 0.13, 1]` | `[0.48, 0.30, 0.68, 1]` | `[0.78, 0.55, 0.95, 0.60]` | `[0.28, 0.16, 0.42, 0.60]` | `[0.90, 0.78, 1.00, 0.95]` | `[0.60, 0.42, 0.78, 1]` | `[1.00, 0.55, 0.30, 0.55]` |
| Inferno Chasm (불/주홍) | `[0.10, 0.04, 0.03, 1]` | `[0.62, 0.26, 0.18, 1]` | `[1.00, 0.55, 0.30, 0.60]` | `[0.42, 0.14, 0.10, 0.60]` | `[1.00, 0.55, 0.25, 0.95]` | `[0.72, 0.40, 0.28, 1]` | `[1.00, 0.40, 0.10, 0.65]` |
| Cursed Tomb (자/분홍·죽음) | `[0.08, 0.03, 0.08, 1]` | `[0.52, 0.22, 0.42, 1]` | `[0.90, 0.45, 0.72, 0.60]` | `[0.32, 0.12, 0.26, 0.60]` | `[1.00, 0.55, 0.80, 0.95]` | `[0.62, 0.32, 0.50, 1]` | `[0.95, 0.30, 0.55, 0.60]` |

**검증**: 폰에서 각 스테이지 시작 화면 캡처 5장 비교. 옆에 두고 "다른 스테이지구나" 즉시 인식 가능해야 함. 안 그러면 채도를 더 올림.

### A2. `enemy_tint` 필드 추가 (stages.json)

각 스테이지 entry에 `enemy_tint: [r, g, b, a]` 한 줄 추가. 적의 `modulate` 에 곱해질 색.

**추천 tint** (적의 본래 색을 살리되 스테이지 hue를 입히는 강도):

| 스테이지 | enemy_tint | 효과 |
|---|---|---|
| Forest | `[1.00, 1.00, 1.00, 1.0]` | 변화 없음 (base 스테이지) |
| Frozen Wastes | `[0.70, 0.85, 1.10, 1.0]` | 청록빛 — 얼어붙은 느낌 |
| Twilight Sanctum | `[0.85, 0.70, 1.10, 1.0]` | 보랏빛 — 마법 들린 느낌 |
| Inferno Chasm | `[1.20, 0.75, 0.65, 1.0]` | 주홍빛 — 그을린 느낌 |
| Cursed Tomb | `[1.05, 0.70, 0.85, 1.0]` | 자홍빛 — 부패한 느낌 |

> RGB 각 채널 0.7~1.2 범위. modulate는 곱셈이라 1.0 초과해도 OK (오버라이트). Forest는 `[1,1,1,1]` 로 두는 게 자연스러움(첫 스테이지는 기본).

### A3. EnemySpawner에서 tint 적용

[godot/scripts/enemies/EnemySpawner.gd](../godot/scripts/enemies/EnemySpawner.gd) 의 `_do_spawn(scene)` 에 tint 적용 한 줄 추가:

```gdscript
# 현재 _do_spawn 끝부분 근처 (register_enemy 호출 직전)
var stage := Stages.get_stage(GameData.selected_stage)
var tint_arr = stage.get("enemy_tint", null)
if tint_arr is Array and tint_arr.size() >= 3:
    var a: float = float(tint_arr[3]) if tint_arr.size() >= 4 else 1.0
    enemy.modulate = Color(float(tint_arr[0]), float(tint_arr[1]), float(tint_arr[2]), a)
```

**주의**:
- `enemy.modulate` 는 자식 노드들의 렌더링에 곱셈으로 전파됨 (CanvasItem 기본 동작)
- [EnemyBase._update_flash()](../godot/scripts/enemies/EnemyBase.gd) 의 피격 white-flash 는 `visual_sprite.modulate = Color(3.0, 3.0, 3.0)` 또는 `visual_body.color = Color.WHITE` 로 처리. 부모(enemy)의 modulate 와 자식 modulate 가 곱해지므로, 피격 시 더 밝게 보일 수 있음. **이게 문제가 되면** flash 처리도 stage tint 고려해 조정. 처음에는 그대로 두고 폰에서 확인.
- DeathBurst (`burst.burst_color = body_color`) 는 enemy.modulate 영향 받지 않을 수도 있음 (별도 노드로 spawn). 죽을 때 본래 색으로 burst 나면 stage 톤과 어색할 수 있음 → 추가 fix 필요할지 확인.

캐싱 최적화: `_do_spawn` 마다 `Stages.get_stage()` 호출이 비싸면, `setup()` 에서 한 번만 fetch 해서 `_enemy_tint: Color` 필드로 보관. 단 GameData.selected_stage 가 런타임에 바뀌지 않는다는 전제 — 확인 필요.

### A4. (선택) 스테이지별 BGM 분기

현재 [AudioManager.play_bgm("game")](../godot/scripts/core/AudioManager.gd) 한 트랙. 절차 합성이라 자산 0으로 차별화 가능:

- `play_bgm("game")` 호출 부 ([GameRoot.gd _ready()](../godot/scripts/core/GameRoot.gd)) 에서 `play_bgm("game_" + GameData.selected_stage)` 로 변경
- AudioManager 에 5개 변형 합성 함수 추가 (BPM/key/instrument를 stage hue에 맞춰 변형):
  - Forest: 자연스러운 minor 6th 진행
  - Frozen Wastes: 느린 BPM + 종소리
  - Twilight Sanctum: 5도 음정 reverb 강
  - Inferno Chasm: 빠른 BPM + 드럼 강
  - Cursed Tomb: 단음 + 메아리

A4는 A1~A3 끝나고 여유 있으면. 우선순위 낮음.

### A5. 검증

1. **개발 검증**: 폰 또는 데스크탑 빌드에서 각 스테이지 시작 (5분 다 안 돌아도 OK, 처음 10초만 보면 됨)
2. **나란히 캡처**: 5개 스테이지 시작 화면 + LevelUp 직후 적 무리 화면 캡처. 옆에 두고 한눈에 구분 가능한지 확인
3. **smoke**: `godot --headless --path godot res://scenes/main/GameRoot.tscn --quit-after 5` 로 런타임 에러 없는지

---

## Stage B — 자산 필요 (예상 작업: 자산 제작 1~2일 + 통합 1세션)

A로도 부족할 때 진입. 진짜 "다른 세계" 느낌을 줘야 할 때.

### B1. 스테이지 고유 파티클 (우선순위 높음)

각 스테이지에 매칭되는 항상 떠다니는 파티클을 추가. 게임 진행 중에 화면 전체에 살짝 보이는 양 (BackgroundTiler 의 firefly 처럼).

| 스테이지 | 파티클 | 자산 |
|---|---|---|
| Forest | 반딧불이 (현재 있음) | (기존) |
| Frozen Wastes | 눈송이 떨어짐 | snowflake_*.png 4종 (8×8 픽셀) |
| Twilight Sanctum | 영혼 입자 (위로 올라가는 푸른 점) | spirit_*.png 4종 |
| Inferno Chasm | 잿가루/불티 (오렌지 점이 위로) | ember_*.png 4종 |
| Cursed Tomb | 어두운 안개 (천천히 흐르는) | mist_*.png 4종 (반투명) |

**구현**: BackgroundTiler 에 stage-specific particle layer 추가 또는 별도 `StageAtmosphere.gd` 노드 신설. GPUParticles2D 사용 권장 (CPUParticles2D 보다 부드러움).

**자산 제작 가이드**:
- AI 생성 (ChatGPT/DALL-E) 또는 직접 픽셀 작업
- 8~16px 원본, nearest filter, 투명 배경
- 4종 variant로 자연스러운 무작위감
- 색은 stages.json `firefly` 색에 맞춰 통일

### B2. 스테이지별 enemy sprite variant (우선순위 중)

A2의 modulate tint로 부족할 때. enemy 종류별로 5개 hue variant 생성:

- 슬라임: green / ice-blue / purple / fire-red / pink-tomb
- 박쥐: 동일 5종
- 기사: 동일 5종
- … 나머지도

**작업량 큼** (적 8종 × 스테이지 5 = 40 sprite). AI 생성으로 단축 가능. 또는 base sprite 1종 + `Sprite2D.material` 로 shader 색 변환 (자산 1종으로 5색 만듦).

**Shader 접근 추천**: `canvas_item` shader 한 개로 hue-shift 파라미터만 stage 별로 다르게. 자산 추가 0, 코드 ~30줄.

### B3. 스테이지별 decor texture variant (우선순위 낮음)

[BackgroundTiler.gd:24-25](../godot/scripts/fx/BackgroundTiler.gd) 의 `decor_rock_texture`, `decor_torch_texture` 가 현재 전 스테이지 공통. 스테이지별로 다른 텍스처 (Forest 이끼 바위 / Frozen 얼음 바위 / …) 사용 시 분위기 강화.

**구현**: stages.json 에 `decor_rock_path / decor_torch_path` 추가, BackgroundTiler 가 stage 적용 시 `load(path)` 로 swap. 자산 5×2=10장 필요.

### B4. 스테이지별 ground tile texture

`tile_textures: Array[Texture2D]` 가 현재 전 스테이지 공통. tile_modulate 만 다름. 진짜 다른 지형(눈 덮인 타일, 갈라진 바위, 마법진 새겨진 타일)이면 차이 강력. 작업량 가장 큼.

---

## 3. 의사결정 포인트 (다음 세션 시작 시 사용자에게 물을 것)

1. **A1 팔레트 검토**: 위에 제안한 RGB 값 그대로 갈지, 일부 조정할지. 특히 Twilight torch_glow를 의도적으로 orange로 (보라 배경에 따뜻한 횃불 콘트라스트)했는데 OK 인지.
2. **A4 BGM 차별화 포함 여부**: A1~A3 끝나고 추가할지, 별도 작업으로 미룰지.
3. **B 진입 시 어떤 sub-step부터?**: B1(파티클)이 가성비 가장 높음. B2 sprite variant는 shader 방식 (자산 0) vs sprite 5종 방식 중 선택.
4. **스테이지별 적 풀 재조정 여부**: 현재 Frozen Wastes는 적 타입이 적음 (bat/hound/knight만). 스테이지 정체성에 맞게 다시 짜면 (예: Frozen 에는 dasher 대신 ice-themed slime 더 많이) 더 차별화됨. 별도 balance 작업.

---

## 4. 산출물 / 커밋 단위

작업 진행 순서대로:

1. **C1 — A1+A2**: `git commit -m "tune(stages): bg 팔레트 색차 확대 + enemy_tint 필드"`
2. **C2 — A3**: `git commit -m "feat(enemies): EnemySpawner에 stage enemy_tint modulate 적용"`
3. **C3 — A5 검증** 후 사용자 피드백: "더 가야 함" / "이 정도 OK"
4. (필요 시) **C4 — A4**: `git commit -m "feat(audio): 스테이지별 BGM 분기"`
5. (필요 시) **C5~ — B 단계**: 자산 별도 커밋, 통합 커밋 따로

각 단계마다 폰 검증 → 다음 단계 결정. A 끝나고 v0.27.1 패치로 묶거나 v0.28.0 minor로 묶을지 사용자와 합의.

---

## 5. 빠진 가정 / 확인 필요

- `GameData.selected_stage` 가 런타임에 바뀌지 않는다는 전제 — A3 캐싱 시 영향. 게임 시작 후 스테이지 변경 가능한지 확인.
- 보스 (EnemyBoss / EnemyMiniBoss) 에도 tint 적용할지. 보스는 본래 색이 정체성인 경우가 많아 별도 처리 고려.
- 웹 빌드에서 modulate 가 모바일 GPU에서 정상 동작하는지 — Godot Web export quirk 가능성. headless로는 검증 불가, 실제 빌드 후 확인.
- A4 BGM 분기 시 5개 BGM 시작 cue 가 게임 시작 타이밍과 어긋나지 않는지.

---

## 6. 참고 파일 (다음 세션 빠른 접근용)

| 파일 | 역할 |
|---|---|
| [godot/data/stages.json](../godot/data/stages.json) | 스테이지 데이터 원본 (bg 팔레트, waves, enemy_tint 추가 예정) |
| [godot/scripts/core/Stages.gd](../godot/scripts/core/Stages.gd) | stages.json 로더 (`get_stage(id)` 캐시) |
| [godot/scripts/core/GameRoot.gd](../godot/scripts/core/GameRoot.gd) | `_apply_stage_background()` 진입점 |
| [godot/scripts/fx/BackgroundTiler.gd](../godot/scripts/fx/BackgroundTiler.gd) | tile/pebble/firefly/decor 렌더링 + `apply_tone()` |
| [godot/scripts/enemies/EnemySpawner.gd](../godot/scripts/enemies/EnemySpawner.gd) | `_do_spawn(scene)` — A3 수정 지점 |
| [godot/scripts/enemies/EnemyBase.gd](../godot/scripts/enemies/EnemyBase.gd) | `body_color`, `_update_flash()` — tint와의 상호작용 확인 |
| [godot/scripts/core/AudioManager.gd](../godot/scripts/core/AudioManager.gd) | A4 BGM 분기 시 수정 지점 |

---

## 7. 다음 세션 시작 시 첫 명령 예시

> "스테이지 정비 계획서 [docs/STAGE_DIFFERENTIATION_PLAN.md](STAGE_DIFFERENTIATION_PLAN.md) 보고, Stage A 의 A1 부터 시작해줘. 팔레트는 제안 그대로 가고, 작업 끝나면 폰에서 확인할 수 있게 main에 푸시."

또는

> "Stage A의 A1~A3까지 한 번에 한 커밋으로 묶어줘. 검증은 headless smoke만 하고 폰 검증은 다음 빌드 떨어진 후 직접 함."
