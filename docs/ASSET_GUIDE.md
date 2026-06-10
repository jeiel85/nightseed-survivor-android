# ASSET_GUIDE

## 1. Current Asset Status (2026-06 현행화)

MVP 시절의 "도형 placeholder" 단계는 끝났다. 현재 자산 구성:

| 범주 | 상태 | 출처/파이프라인 |
|---|---|---|
| 게임플레이 스프라이트 (캐릭터/적/투사체/픽업/타일) | 16×16 픽셀아트, 전 슬롯 채움 | Kenney Tiny Dungeon (CC0) 기반 — `assets/sprites/KENNEY_LICENSE.txt` |
| UI 키트 (패널/버튼/아이콘/배경) | AI 생성 픽셀아트, 대부분 연결 완료 | `scripts/generate_missing_ui_assets.py` (OpenAI Images API) |
| 스토리 화면 자산 (인장/체인/책/챔버 배경) | 연결 완료, 표시 크기 기준으로 다운스케일 완료 | AI 생성 (v0.32.0), 2026-06 최적화 |
| 로고 | `assets/logo/title_ko.png` / `title_en.png` 언어별 분기 | — |
| 폰트 | Pretendard (SIL OFL) | — |
| 사운드/음악 | 절차 합성 (외부 자산 0) | `AudioManager.gd` |

구버전 가이드의 "최종 그래픽 애셋이 없다"는 더 이상 사실이 아니다.

---

## 2. 크기 규율 (2026-06 박제 — 어기지 말 것)

**원본이 표시 크기의 3배를 넘는 PNG를 커밋하지 않는다.**

- Godot은 프로젝트 폴더의 모든 임포트 자산을 export에 포함한다. 오버스펙
  텍스처는 APK 용량과 런타임 메모리(RGBA 비압축 기준 1254² ≈ 6MB/장)를
  그대로 잡아먹는다.
- 2026-06에 스토리 인장 5종(1254×1254→256×256), 책 아이콘, 체인 등을
  표시 크기 기준으로 다운스케일해서 13.4MB→2.3MB로 줄였다. 재발 금지.
- 기준: 표시 logical 크기 × 2~3 (고DPI 헤드룸). 풀스크린 배경만 예외로
  뷰포트(720×1280)급 허용.
- AI 생성 원본(1024²+)을 받으면 **커밋 전에** Pillow로 리사이즈+팔레트
  양자화한다. `generate_missing_ui_assets.py`는 네이티브 크기로 리사이즈해서
  저장하므로 이 스크립트를 거치면 안전.

---

## 3. UI 자산 연결 현황

연결 완료 (로드 실패 시 절차적 fallback이 모두 구현돼 있음):

| 자산 | 연결 위치 |
|---|---|
| `ui/panel/panel_stone_blue.9` / `panel_cta_amber.9` | `ButtonStyles.gd` 텍스처 버튼 |
| `ui/panel/panel_card_dark.9` + `frame_card_glow_*.9` | `LevelUpUI.gd` 카드 |
| `ui/panel/banner_stage_clear` | `GameRoot.gd` 승리 타이틀 배너 |
| `ui/icon_reward/icon_reward_coins` | `GameRoot.gd` 결과 골드 행 |
| `ui/icon_hud/icon_hud_timer` / `icon_hud_kills` | `HUD.tscn` |
| `ui/icon_hud/icon_hud_joystick_base` / `_thumb` | `VirtualJoystick.gd` |
| `ui/icon_top/icon_gold_coin` / `icon_settings_gear` | `MainMenu.gd` |
| `ui/bg/bg_menu_hero_lineup` / `bg_menu_night_sky` | `MainMenu.gd` 배경 (lineup 우선) |
| `ui/bg/bg_logo_glow_ornament` | `MainMenu.gd` 타이틀 장식 |
| `ui/icon_nav/icon_nav_*` (6종) | `MainMenu.gd` 메뉴 버튼 |
| `ui/story/*` | `StoryUI.gd` |

생성돼 있으나 **아직 미연결** (향후 기능용 — 지우지 말 것):

| 자산 | 예정 용도 |
|---|---|
| `ui/icon_hud/icon_hud_skill_button` | 액티브 스킬 버튼 (기능 미구현) |
| `ui/icon_reward/icon_reward_chest_*` / `_magic_tome` / `_potion` / `_sword` | 보상 연출/상자 기능 |
| `ui/icon_top/icon_close_x` | 다이얼로그 닫기 버튼 |
| `ui/bg/bg_battle_floor` | 전투 바닥 텍스처 후보 (가독성 검증 후 교체 판단) |
| `ui/story/frame_story_gold` | 챕터 인트로 오버레이 (StoryUI.gd 주석 참고) |

---

## 4. 권장 씬 구조 (유지)

로직과 시각 표현 분리 원칙은 그대로 유효하다.

```text
Player/Enemy/Projectile/Pickup
  CollisionShape2D
  Visual
    Sprite2D
```

핵심은 `Visual` 노드를 교체해도 로직이 깨지지 않게 하는 것. UI는
`ResourceLoader.exists()` 가드 + 절차적 fallback 패턴을 따른다
(`ButtonStyles.gd`, `MainMenu.gd`, `GameRoot.gd._apply_result_panel_art()` 참고).

---

## 5. 스프라이트 크기 기준

| Asset | Size |
|---|---|
| 게임플레이 스프라이트 (캐릭터/적/타일) | 16×16 원본, 씬에서 2× 스케일 |
| 무기/패시브 아이콘 | 16×16 |
| HUD 아이콘 | 32×32 |
| 상단/코너 아이콘 | 24×24 |
| 보상 아이콘 | 48×48 |
| 9-slice 패널 | 96~224px급 (마진 스펙은 각 스크립트 상수 참고) |
| 스토리 인장/책 | 256×256 |
| 풀스크린 배경 | 720×1280 ~ 941×1672 |

---

## 6. 검증 도구

- `godot --headless --path godot -s tests/verify_ui_wiring.gd`
  — 리워크된 씬 로드 + @onready 노드 경로 + 텍스처 로드 일괄 검증
- `godot --path godot --resolution 540x960 -s tests/screenshot_result_panel.gd`
  — 결과 화면(승리/패배)을 강제 표시하고 `%TEMP%`에 스크린샷 저장 (메타 진행 미커밋)

---

## 7. 애셋 교체 기준

실제 그래픽을 추가/교체할 때 확인:

- 기존 자산과 크기가 크게 다르지 않은가 (§2 크기 규율)
- CollisionShape2D를 다시 맞춰야 하는가
- Sprite2D pivot이 중앙 기준인가
- 모바일 화면에서 식별 가능한가 / 배경과 색 대비가 충분한가
- 무기 이펙트가 적과 플레이어를 가리지 않는가
- 라이선스가 상업적 배포에 문제가 없는가 (AI 생성분은 프롬프트·사용 이유를 HISTORY.md에 기록)

---

## 8. 금지 사항

- 기존 상용 게임의 스프라이트, 아이콘, UI를 복사하지 않는다.
- 저작권이 불분명한 이미지를 저장소에 포함하지 않는다.
- 표시 크기 3배 초과 원본 PNG를 커밋하지 않는다 (§2).
- placeholder 교체를 위해 로직 코드를 대규모로 수정하지 않는다.
- fallback 없는 텍스처 하드 의존을 만들지 않는다 (fresh checkout에서 import 전에도 씬이 떠야 함).
