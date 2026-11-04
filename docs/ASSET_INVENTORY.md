# ASSET_INVENTORY — 게임 내 그래픽 애셋 현황 (2026-11-04 기준)

> **교체 전 기록이다.** 같은 날 §1의 32장 + 투사체 신규 5장 + §2.2 UI 아이콘 5장(조이스틱·타이머·처치·보상 동전)을 Codex로 다시 그려 넣었다 — [SPRITE_REGEN_32PX.md](SPRITE_REGEN_32PX.md). 아래 "현재 그림 / 문제" 열은 Kenney 시절 상태이고, 경로·사용처·표시 크기·9-slice 마진은 여전히 유효하다.

그래픽 재생성(Codex 이미지 생성)을 위해 **지금 게임에 실제로 들어가 있는 그래픽**을 코드 참조 기준으로 다시 정리한 문서.
`ASSET_GUIDE.md`(정책·크기 규율)와 `ASSETS_TO_GENERATE.md`(2026-05 UI 키트 생성 프롬프트)는 그대로 두고, 이 문서는 "무엇이 어디에 몇 px로 보이는가"와 "무엇이 문제인가"만 다룬다.

- 표시 크기는 논리 해상도 720×1280(`stretch=canvas_items`) 기준, 화면에 실제로 그려지는 px.
- 텍스처 필터는 프로젝트 전역 Nearest(`default_texture_filter=0`) — 픽셀아트 전제.
- 모든 UI 텍스처 로드는 `ResourceLoader.exists()` 가드 + 절차적 fallback이 있다. 파일 경로·이름만 유지하면 코드 수정 없이 교체된다.

---

## 0. 요약

`godot/assets/` 아래 PNG 85개 (애드온 제외).

| 계통 | 개수 | 출처 | 상태 |
|---|---|---|---|
| A. 전투 스프라이트 (캐릭터·적·무기·픽업·타일·상점 아이콘) | 32 | Kenney Tiny Dungeon 16×16 (CC0), 2026-05-09 통합 | **가장 조악함** — 확대율·의미 불일치 |
| B. UI 키트 (패널·아이콘·배경·스토리) | 46 | AI 생성 (2026-05~06) | 대체로 양호, 일부 가짜 투명 배경 |
| C. 로고·앱 아이콘 | 7 | AI 생성 + 캐릭터 스프라이트 확대 | 앱 아이콘이 16px 스프라이트 확대본 |

### 조악해 보이는 원인 (확인된 사실)

1. **16px 원본을 6~7배 확대해서 보여준다.** 레벨업 카드 아이콘 108px(6.75배), 캐릭터 선택 96px(6배), 보스 91px(5.7배), 바닥 타일 64px(4배). 같은 화면의 UI 키트는 48~256px 원본이라 해상도 밀도가 뒤섞인다.
2. **Kenney 타일을 의미와 상관없이 재사용했다.** 금화 픽업 = 나무통, 경험치 = 녹색 물약, 정령의 구 = 파란 물약, 가시 고리 = 망치, 상점/패시브 4종 = 색만 다른 물약, 적 투사체 = 녹색 물약. 코드 주석에도 "base sprites are all small potions, differentiated only by hue"라고 적혀 있고, 그래서 `LevelUpUI.gd`가 무기 색으로 강제 틴트를 건다.
3. **캐릭터 설정과 그림이 다르다.** 정령의 수녀 = 수염 난 마법사, 광전사 = 보라 옷 소녀, 사냥꾼에 활이 없음, 화염술사에 불 요소 없음.
4. **투사체 방향이 안 맞는다.** `Projectile.gd`는 노드를 진행 방향(+X)으로 회전시키는데 달의 단검·별의 침 아이콘은 세로(위쪽)로 그려져 있어 옆으로 날아간다. 아이콘과 투사체가 같은 파일을 쓰기 때문.
5. **UI 아이콘 7개는 배경이 실제로 투명하지 않다** (테두리가 불투명 흰색·체크무늬, 6개는 전면적·1개는 부분적). 이 중 조이스틱 2종은 전투 내내 화면에 보인다. → §2.2
6. **5개 스테이지가 같은 바닥 타일 3장을 색조만 바꿔 쓴다** (`stages.json`의 `bg` 톤 → `BackgroundTiler.apply_tone`). 타일 자체도 무늬 없는 주황 모래색.

---

## 1. A계통 — 전투 스프라이트 (Kenney 16×16)

경로: `godot/assets/sprites/*.png`. 교체 시 `KENNEY_LICENSE.txt`·README·CLAUDE.md의 라이선스 표기도 함께 정리해야 한다.

### 1.1 플레이어 캐릭터 (5)

| 파일 | 캐릭터 (설정) | 표시 크기 | 현재 그림 | 문제 |
|---|---|---|---|---|
| `char_vagrant.png` | 방랑자 — 달빛 검을 든 균형형 외톨이 | 전투 32 / 선택 96 / 메인 쇼케이스 ~96 | 투구 쓴 기사 | 검·달빛 요소 약함 (가장 무난) |
| `char_spirit_sister.png` | 정령의 수녀 — 공전하는 영혼을 다룸 | 〃 | 보라 모자 + 흰 수염 마법사 | **성별·직업 불일치** |
| `char_hunter.png` | 사냥꾼 — 빠른 활잡이 | 〃 | 녹색 머리띠 수염 남자 | 활 없음 |
| `char_berserker.png` | 광전사 — 고HP·고피해·느림 | 〃 | 보라 옷 갈색 머리 소녀 | **체급·인상 불일치** |
| `char_pyromancer.png` | 화염술사 — 불을 다루는 시전자 | 〃 | 대머리 수염 남자 | 불 요소 없음 |

- 사용처: `Characters.gd`(sprite 경로) → `Player.gd`(Sprite2D scale 2), `CharacterSelect.gd`(96×96, 잠금 시 실루엣 `modulate(0.10,0.10,0.15)`), `CharacterShowcase.gd`(메인 메뉴 대형 표시), 앱 아이콘(§3).
- 좌우 반전 없음(`flip_h` 미사용) — 정면 또는 3/4 정면 1장이면 된다. 애니메이션 프레임 없음(정지 1장).
- 잠금 상태는 검은 실루엣으로 보이므로 **실루엣만으로 구분되는 형태**가 좋다.

### 1.2 적 (9 파일 / 10 씬)

표시 크기 = 16 × `body_size` / 7 (`EnemyBase._update_visual`). 스테이지별 `enemy_tint`(최대 1.2배)와 피격 플래시 `modulate(3,3,3)`가 곱해진다.

| 파일 | 역할 | body_size | 표시 크기 | 현재 그림 | 비고 |
|---|---|---|---|---|---|
| `enemy_slime.png` | 기본 잡몹 (+ `EnemySplitterling` 재사용) | 12 (분열체 8) | 27 (분열체 18) | 녹색 슬라임 | 의미 일치 |
| `enemy_bat.png` | 빠르고 약한 잡몹 | 10 | 23 | 박쥐 | 의미 일치 |
| `enemy_hound.png` | 가장 빠른 추적형 (속도 140) | 15 | 34 | 거미 | 이름(사냥개)과 불일치 |
| `enemy_caster.png` | 원거리 시전 (조준 시 틴트) | 12 | 27 | 후드 쓴 인물 | 의미 일치 |
| `enemy_dasher.png` | 돌진 (예고선 + 틴트) | 13 | 30 | 빨간 게 | 애매 |
| `enemy_splitter.png` | 죽으면 분열 | 16 | 37 | 주황 외눈 거인 | 분열 느낌 없음 |
| `enemy_knight.png` | 탱커 | 20 | 46 | 뿔 투구 짐승 | 기사로 안 읽힘 |
| `enemy_miniboss.png` | 중간 보스 (오라·충격파 링은 코드) | 24 | 55 | 유령 | 확대 티 큼 |
| `enemy_boss.png` | 최종 보스 "봉인의 파수꾼" (오라·가시 4개는 코드) | 40 | **91** | 뿔 투구 | **가장 크게 깨짐** |

- 스테이지 선택 화면(`StageSelect.gd`)에도 스테이지당 대표 적 2마리가 72px·60px로 표시된다.
- 피격 판정 원(CollisionShape2D)은 body_size 근처 반지름으로 고정 — 그림의 실루엣 중심·크기를 그 원에 맞추면 된다.

### 1.3 무기 아이콘 · 투사체 (6)

| 파일 | 무기 | 아이콘 표시 | 투사체로도 쓰임 | 현재 그림 | 문제 |
|---|---|---|---|---|---|
| `icon_moon_dagger.png` | 달의 단검 — 가까운 적에게 투척 | 레벨업 108 / 캐릭터 카드 34 | 29px (scale 1.8) | 세로 단검 | 투사체가 옆으로 날아감 |
| `icon_spirit_orb.png` | 정령의 구 — 공전 구슬 | 108 | — (투사체는 `proj_orb`) | 파란 물약 | 의미 불일치 |
| `icon_fire_wisp.png` | 화염 위습 — 적 밀집 지점 폭발 | 108 | — (폭발은 12각형 폴리곤) | 작은 물약 | 의미 불일치 |
| `icon_thorn_ring.png` | 가시 고리 — 주변 방사 | 108 | 21px (scale 1.3) | 망치 | 의미 불일치 |
| `icon_star_needle.png` | 별의 침 — 원거리 다발 | 108 | 24px (scale 1.5) | 세로 단검/침 | 투사체 방향 |
| `proj_orb.png` | 정령의 구 궤도체(시안 틴트) + 적 투사체 | — | 26px / 22px | 녹색 물약 | 의미 불일치, 두 용도 겸용 |

- 레벨업 카드에서 16px 아이콘에는 무기 색 `self_modulate`가 걸린다. 16px보다 큰 아이콘은 틴트 없이 원래 색으로 표시된다(2026-11-04~).
- 투사체 전용 파일 `proj_moon_dagger` / `proj_star_needle` / `proj_thorn` / `proj_spirit_orb` / `proj_enemy`가 있으면 무기 스크립트가 그것을 쓰고, 없으면 위 표의 기존 텍스처로 돌아간다(2026-11-04~). 투사체 그림은 **오른쪽(+X)을 향하게** 그려야 한다.
- 진화 무기(Crescent Storm ← 달의 단검, Eternal Halo ← 정령의 구)는 전용 아이콘이 없다 — 원본 무기 아이콘 + 보라 글로우 프레임으로 표시(`LevelUpUI.gd`의 `base_icon`). 진화 아이콘을 따로 만들면 이 부분만 경로 분기하면 된다.

### 1.4 픽업 (2)

| 파일 | 용도 | 표시 크기 | 현재 그림 | 비고 |
|---|---|---|---|---|
| `pickup_xp.png` | 경험치 젬 (+ HUD 레벨 아이콘 40px) | 26 (scale 1.6) | 녹색 물약 | 아래 원형 글로우는 코드 |
| `pickup_gold.png` | 금화 (+ HUD 골드 아이콘 40px) | 26, 좌우로 뒤집히며 회전 | **나무통** | 회전 연출이 동전 전제라 동전이어야 함 |

### 1.5 패시브 / 상점 아이콘 (5)

레벨업 카드(패시브) 108px, 상점(`ShopUI.gd`) 54px. 같은 파일을 두 화면이 공유한다.

| 파일 | 패시브 | 현재 그림 |
|---|---|---|
| `shop_swift.png` | 신속의 부츠 (이동속도) | 녹색 물약 |
| `shop_magnet.png` | 자석 부적 (흡수 범위) | 파란 물약 |
| `shop_heart.png` | 철의 심장 (최대 HP) — 체력 회복 카드에도 재사용 | 빨간 물약 |
| `shop_focus.png` | 전투 집중 (쿨다운) | 회색 물약 |
| `shop_power.png` | 파워 코어 (피해량) | 양날 도끼 |

### 1.6 바닥 · 장식 (5)

| 파일 | 용도 | 표시 크기 | 비고 |
|---|---|---|---|
| `ground_tile.png` / `_b` / `_c` | 무한 바닥 타일 (해시로 3장 섞고 좌우 반전) | 64×64 per tile (4배) | 무늬 없는 주황 모래. 스테이지 톤으로 곱연산 — **이음매 없이 이어지는 타일**이어야 함 |
| `decor_rock.png` | 바위 장식 | 38~54 (scale 2.4~3.4 랜덤) | 실제로는 석벽 블록 그림 |
| `decor_torch.png` | 횃불 장식 (아래 따뜻한 글로우는 코드) | 〃 | 실제로는 빨간 깃발 그림 |

- 5개 스테이지(메아리의 숲 / 얼어붙은 황무지 / 황혼의 성소 / 화염의 협곡 / 저주받은 무덤)가 전부 이 5장을 공유한다. 스테이지별 타일을 넣으려면 `stages.json`에 타일 경로 키를 추가하고 `GameRoot._apply_stage_background()`에서 `ground_tiler.tile_textures`를 교체하는 코드 작업이 필요하다.

---

## 2. B계통 — UI 키트 (AI 생성)

경로: `godot/assets/sprites/ui/`. 생성 스크립트 `scripts/generate_missing_ui_assets.py`, 프롬프트 원문은 `ASSETS_TO_GENERATE.md`.

### 2.1 패널 · 9-slice (8)

9-slice 마진은 텍스처 px 기준. 재생성 시 **원본 크기와 마진을 그대로** 맞추거나, 바꾸면 해당 상수도 같이 고쳐야 한다.

| 파일 | 크기 | 9-slice 마진 | 사용처 |
|---|---|---|---|
| `panel/panel_stone_blue.9.png` | 96×96 | 16 | 기본 버튼 (`ButtonStyles.gd`) |
| `panel/panel_cta_amber.9.png` | 192×64 | 좌우 24 / 상하 12 | 주 행동 버튼 |
| `panel/panel_card_dark.9.png` | 96×160 | 8 | 레벨업 카드 바탕, 서브 화면 카드 (`UIKit.gd`), 결과 패널 |
| `panel/frame_card_glow_blue.9.png` | 144×176 | 8 | 레벨업 "신규 무기" |
| `panel/frame_card_glow_gold.9.png` | 144×176 | 8 | "강화", 서브 화면 선택 강조 |
| `panel/frame_card_glow_purple.9.png` | 144×176 | 8 | "진화" |
| `panel/frame_card_glow_green.9.png` | 144×176 | 8 | "신규 패시브" |
| `panel/banner_stage_clear.png` | 480×120 | — | 승리 결과 타이틀 배너 (`GameRoot.gd`) |

### 2.2 아이콘 (20)

⚠ = 배경이 실제 투명이 아님 (가장자리 2px 안쪽의 불투명 흰색/체크무늬 비율 측정값). **연결된 것부터 재생성 1순위.**

| 파일 | 크기 | 사용처 | 상태 |
|---|---|---|---|
| `icon_hud/icon_hud_joystick_base.png` | 32 | 가상 조이스틱 바탕 (반경 130 → 260px로 확대, 알파 0.72) | ⚠ 테두리 49% 흰색 |
| `icon_hud/icon_hud_joystick_thumb.png` | 32 | 조이스틱 손잡이 (알파 0.88) | ⚠ 76% |
| `icon_hud/icon_hud_timer.png` | 32 | HUD 생존 시간 (44px) | ⚠ 76% |
| `icon_hud/icon_hud_kills.png` | 32 | HUD 처치 수 (40px) | ⚠ 일부 체크무늬 (24%) |
| `icon_hud/icon_hud_skill_button.png` | 32 | **미연결** (액티브 스킬 미구현) | ⚠ 82% |
| `icon_reward/icon_reward_coins.png` | 48 | 결과 화면 골드 행 | ⚠ 35% |
| `icon_top/icon_close_x.png` | 24 | **미연결** (닫기 버튼 예정) | ⚠ 36% |
| `icon_top/icon_gold_coin.png` | 24 | 메인 메뉴 상단 골드 | 정상 |
| `icon_top/icon_settings_gear.png` | 24 | 메인 메뉴 설정 | 정상 |
| `icon_nav/icon_nav_heroes.png` | 48 | 메인 메뉴 "영웅" | 정상 |
| `icon_nav/icon_nav_stages.png` | 48 | "스테이지" | 정상 |
| `icon_nav/icon_nav_difficulty.png` | 48 | "난이도" | 정상 |
| `icon_nav/icon_nav_shop.png` | 48 | "상점" | 정상 |
| `icon_nav/icon_nav_story.png` | 48 | "스토리" | 정상 |
| `icon_nav/icon_nav_leaderboard.png` | 48 | "리더보드" | 정상 |
| `icon_reward/icon_reward_chest_closed.png` | 48 | **미연결** | 정상 |
| `icon_reward/icon_reward_chest_open.png` | 48 | **미연결** | 정상 |
| `icon_reward/icon_reward_magic_tome.png` | 48 | **미연결** | 정상 |
| `icon_reward/icon_reward_potion.png` | 48 | **미연결** | 정상 |
| `icon_reward/icon_reward_sword.png` | 48 | **미연결** | 정상 |

### 2.3 배경 (4)

| 파일 | 크기 | 사용처 |
|---|---|---|
| `bg/bg_menu_hero_lineup.png` | 720×1280 | 메인 메뉴 배경 (1순위, 있으면 캐릭터 쇼케이스 숨김) |
| `bg/bg_menu_night_sky.png` | 941×1672 | 메인 메뉴 대체 배경 + 모든 서브 화면 공용 배경 (`UIKit.gd`) |
| `bg/bg_logo_glow_ornament.png` | 512×256 | 메인 메뉴 타이틀 뒤 장식 |
| `bg/bg_battle_floor.png` | 256×256 | **미연결** (전투 바닥 후보) |

- 둘 다 없으면 `MenuBackdrop.gd`가 하늘·달·나무 실루엣을 코드로 그린다.

### 2.4 스토리 화면 (14) — `StoryUI.gd`

| 파일 | 크기 | 용도 |
|---|---|---|
| `story/bg_story_chamber.png` | 941×1672 | 스토리 화면 배경 (`StoryUI.tscn`) |
| `story/panel_story_parchment.9.png` | 192×224 | 해금된 챕터 카드 (마진 24) |
| `story/panel_story_locked.9.png` | 192×224 | 잠긴 챕터 카드 (마진 24) |
| `story/btn_story_wood.png` | 543×181 | 나무 버튼 (마진 좌우 32 / 상하 27) |
| `story/chain_story_locked.png` | 1024×256 | 잠긴 카드 위 사슬 |
| `story/divider_story_diamond.png` | 512×32 | 구분선 |
| `story/icon_story_book.png` | 256 | 책 아이콘 |
| `story/icon_story_lock.png` | 96 | 자물쇠 |
| `story/seal_forest.png` 외 4종 | 256 | 스테이지별 인장 (숲·설원·성소·협곡·무덤) |
| `story/frame_story_gold.png` | 581×678 | **미연결** (세로 비율이라 가로 카드에 늘리면 깨짐 — 주석 참고) |

---

## 3. C계통 — 로고 · 앱 아이콘

| 파일 | 크기 | 사용처 | 비고 |
|---|---|---|---|
| `logo/title_ko.png` | 640×288 | 메인 메뉴 타이틀 (한국어 "잔불의 밤") | |
| `logo/title_en.png` | 640×288 | 메인 메뉴 타이틀 (영어) | |
| `logo/logo_nightseed_survivor.png` | 600×240 | **어디서도 참조 안 함** | 불투명 흰 배경 98% |
| `icons/icon.png` | 128 | 프로젝트·PC 아이콘 | 16px 방랑자 스프라이트 확대본 |
| `icons/icon_192.png` | 192 | Android 아이콘 | 〃 |
| `icons/icon_adaptive_fg.png` / `_bg.png` | 432 | Android 적응형 아이콘 | 〃 — 캐릭터 재생성 시 같이 갱신 필요 |

게임 밖(스토어용, 이번 범위 아님): `play_store/icon_512.png`, `feature_graphic_1024x500.png`, `screenshot_1~5_*.png`, `branding/assets/pages.png`. 스크린샷은 그래픽 교체 후 다시 찍어야 한다(`docs/screenshots/`도 2026-05-15 캡처라 현재 화면과 다름).

---

## 4. 이미지 없이 코드로 그리는 그래픽

재생성 대상은 아니지만, "그래픽이 조악하다"는 인상에 같이 기여한다. 스프라이트로 바꾸려면 코드 작업이 필요하다.

| 요소 | 위치 | 현재 표현 |
|---|---|---|
| 플레이어 오라 · 조준 삼각형 | `Player.tscn` | 반투명 팔각형 + 흰 삼각형 |
| 보스 오라 · 가시 4개 | `EnemyBoss.tscn` | 보라 팔각형 + 삼각형 4개 |
| 미니보스 오라 · 충격파 링 | `EnemyMiniBoss.gd` | 폴리곤 + Line2D |
| 돌진·시전 예고선 | `EnemyDasher.gd`, `EnemyCaster.gd` | Line2D |
| 화염 위습 폭발 | `FireWisp.gd` | 주황 12각형이 0.4초 페이드 |
| 정령의 구 헤일로 | `SpiritOrb.gd` | 시안 폴리곤 |
| 투사체 꼬리 | `Projectile.tscn` | Line2D |
| 적 사망 파편 | `DeathBurst.gd` | 폴리곤 조각 |
| 픽업 글로우 | `XPGem.gd`, `GoldCoin.gd` | `draw_circle` 2겹 |
| 바닥 반딧불·점 | `BackgroundTiler.gd` | `draw_circle` |
| 별 배경 | `Starfield.gd` | 폴리곤 별 |
| HP/XP 바 | `HUD.gd` | StyleBoxFlat |
| 메인 메뉴 대체 배경 · 캐릭터 헤일로 | `MenuBackdrop.gd`, `CharacterShowcase.gd` | 원·폴리곤 |

---

## 5. 재생성 전에 정할 것 — 전투 스프라이트 해상도

A계통(32장)을 어떤 격자로 다시 그릴지가 유일하게 되돌리기 어려운 결정이다. UI 키트(B)는 이미 48~256px 고밀도라 이번 문제의 중심이 아니다.

> **결정 (2026-11-04): (b) 32px 픽셀아트.** 전장은 1 텍셀 = 1 논리 px, 캔버스 = 화면 크기. 애셋별 캔버스·프롬프트·후처리는 [SPRITE_REGEN_32PX.md](SPRITE_REGEN_32PX.md).

| 안 | 원본 크기 | 장점 | 필요한 코드 변경 |
|---|---|---|---|
| (a) 16px 유지, 그림만 의미에 맞게 | 16×16 | 코드 변경 0 | 없음 — 단, 6배 확대 문제는 그대로 |
| **(b) 32px 픽셀아트로 상향 (권장)** | 32×32 (보스·미니보스·기사 48~64) | 카드 96px = 정확히 3배, 전투 32px = 1배. UI 키트 밀도와 가까워짐 | 스케일 상수 5곳 (아래) |
| (c) 비픽셀 일러스트 | 128~256 | 가장 디테일 | 위 + Nearest 필터 해제 검토, Galmuri 픽셀 폰트·UI 키트와 톤 충돌 |

16px 전제였던 배율(플레이어 ×2, 적 ×body_size/7, 픽업·투사체 ×1.3~1.8, 데코 ×2.4~3.4)과 레벨업 아이콘 틴트는 2026-11-04에 `scripts/core/SpriteArt.gd`로 정리했다. 텍스처 크기를 보고 자동으로 맞추므로 16px·32px 파일이 섞여 있어도 된다 — 규칙은 [SPRITE_REGEN_32PX.md](SPRITE_REGEN_32PX.md) §1.

---

## 6. 재생성 우선순위 (제안)

| 순위 | 대상 | 이유 |
|---|---|---|
| P0 | 배경이 안 투명한 UI 아이콘 중 연결된 5종 (조이스틱 2·타이머·처치 수·보상 동전) | 코드 변경 없이 바로 교체 가능, 전투 내내 보이는 흰 박스. 미연결 2종(스킬 버튼·닫기)은 기능 붙일 때 |
| P0 | 무기 아이콘 5 + 패시브 아이콘 5 | 레벨업 카드에서 108px로 가장 크게 보이고, 그림이 전부 엉뚱함 |
| P0 | 캐릭터 5 (+ 앱 아이콘 3) | 선택 화면 96px, 설정과 불일치 |
| P1 | 보스·미니보스·기사 | 91·55·46px로 확대 티가 가장 큼 |
| P1 | 픽업 2 + 투사체(단검·침·가시·구슬·적 탄) | 금화=통 같은 의미 불일치, 투사체 방향 |
| P2 | 나머지 적 6, 바닥 타일 3, 데코 2 | 작게 보여서 체감은 덜함. 스테이지별 타일은 코드 작업 동반 |
| P3 | §4 코드 그래픽의 스프라이트화 (폭발·오라·파편) | 별도 기능 작업 |

### 공통 생성 규칙 (Codex 프롬프트에 매번 포함)

- **진짜 투명 PNG** (알파 채널). 체크무늬를 그려 넣은 이미지는 쓰지 않는다 — §2.2의 ⚠ 7개가 이렇게 망가졌다.
- 피사체 1개, 글자·숫자 없음, 가장자리 여백 1~2px.
- 투사체는 **오른쪽을 향하게**. 캐릭터·적은 정면/3/4 정면(반전 안 함).
- 스테이지 틴트(최대 1.2배)·피격 흰색 플래시가 곱해지므로 원색은 중간 명도로, 실루엣 외곽선은 어둡게.
- 커밋 전 크기 규율(`ASSET_GUIDE.md` §2): 표시 크기의 3배를 넘는 원본은 리사이즈.
- AI 생성분은 프롬프트·사용 이유를 `HISTORY.md`에 기록 (`ASSET_GUIDE.md` §7).

---

## 7. 부수 발견 (그래픽 외)

- 폰트: 게임 전역 폰트는 `Galmuri11.ttf`(v0.26.0부터)인데 `ASSET_GUIDE.md`·`CLAUDE.md`는 아직 Pretendard로 적혀 있다. `Pretendard-Regular.otf`(1.5MB)는 코드 어디서도 참조하지 않는다.
- 미연결 애셋 10개(§2.2 7개, §2.3·§2.4 각 1개, §3 로고 1개). 로고를 뺀 9개는 `ASSET_GUIDE.md` §3에 "향후 기능용, 지우지 말 것"으로 기록돼 있다. 재생성 범위에서는 빼도 된다.
