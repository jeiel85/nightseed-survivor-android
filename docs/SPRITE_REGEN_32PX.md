# SPRITE_REGEN_32PX — 전투 스프라이트 32px 재생성 키트

2026-11-04 결정: 전투 스프라이트를 Kenney 16×16에서 **32px급 픽셀아트**로 다시 그린다 (`ASSET_INVENTORY.md` §5의 (b)안).
이 문서는 Codex(또는 다른 이미지 생성 도구)에 그대로 넣을 수 있는 애셋별 프롬프트와, 생성본을 게임용 PNG로 바꾸는 절차를 담는다.

> **2026-11-04 반영 완료:** §4의 41장을 Codex CLI 이미지 생성(`image_generation`)으로 그려 게임에 넣었다. 실제로 쓴 프롬프트는 `scripts/codex_generate_sprites.py`의 `TEMPLATES`·`ASSETS`가 원본이다(§3 블록도 그것과 같음). 마음에 안 드는 것만 다시 그리려면:
>
> ```powershell
> python scripts\codex_generate_sprites.py enemy_caster --regen   # 다시 그려서 게임 경로에 바로 반영
> ```
>
> 생성 원본은 `art/raw/`(git 제외)에 남아 있어 후처리만 다시 돌리는 것도 된다(`--regen` 없이 실행).

---

## 1. 규칙 — 전장에서는 1 텍셀 = 1 논리 px

- 지금은 16px 원본을 2~5.7배로 늘려서 그려서 스프라이트마다 픽셀 크기가 다르다. 새 스프라이트는 **캔버스 크기 = 화면에 보이는 크기**로 만들고 배율 1로 그린다. 그러면 전장의 모든 스프라이트가 같은 밀도의 픽셀을 가진다.
- 캔버스 크기는 지금 화면 크기(`ASSET_INVENTORY.md` §1)를 4px 단위로 반올림했다. 크기가 최대 5% 커지는 것은 의도한 것이다.
- UI(캐릭터 선택 96px, 레벨업 카드 108px)에서는 정수배로 확대된다: 캐릭터 32→96은 3배, 아이콘 54→108은 2배, 상점 54→54는 1배.

### 코드 쪽 준비 (2026-11-04 반영)

`godot/scripts/core/SpriteArt.gd`가 크기를 정한다. 호출하는 쪽은 "화면에 몇 px로 보일지"만 넘긴다.

- 16px 이하 텍스처(Kenney)는 예전 배율 그대로 (×2, ×body_size/7, ×1.3~1.8 …).
- 그보다 큰 텍스처는 `표시 크기 / 텍스처 폭`. 결과가 1.0에서 ±15% 안이면 **정확히 1.0으로 스냅**해서 픽셀이 재샘플되지 않는다. 그래서 §4의 캔버스 크기를 지켜야 한다.
- 투사체는 §4.4 신규 파일(`proj_*.png`)이 있으면 그것을, 없으면 예전처럼 무기 아이콘·`proj_orb`를 쓴다. **무기 아이콘을 54px로 바꿀 때 투사체 파일도 같이 넣는다** — 안 그러면 54px 아이콘이 0.53배로 줄어든 채 옆으로 날아간다.
- 레벨업 카드의 무기 색 틴트는 16px 아이콘에만 걸린다. 새 아이콘은 원래 색으로 보인다.
- 데코의 횃불 빛·바위 그림자 반경은 그려진 폭을 따른다.

그러므로 **그룹 순서와 상관없이 원래 경로에 바로 덮어써도 된다** (파일 하나씩 바꿔도 크기가 섞이지 않음). 배율 규칙은 `godot/tests/verify_sprite_art.gd`가 검사한다 — 캔버스 크기를 바꾸면 이 테스트의 표도 같이 고친다.

---

## 2. 작업 흐름

```text
프롬프트(§3 + §4) → 이미지 생성 → art/raw/<파일명>.png 저장
→ python scripts/pixelize_sprite.py ... → 미리보기 확인 → 실패면 재생성
```

`scripts/codex_generate_sprites.py`가 이 흐름 전체를 돌린다 (Codex 동시 5개 생성 → `art/raw/` → `pixelize_sprite.py` → 게임 경로 + `art/preview/`). 손으로 할 때는 아래 명령을 쓴다.

`art/raw/`(생성 원본), `art/preview/`(8배 미리보기)는 `.gitignore`의 `/art/`로 제외돼 있다. 원본은 1~2MB라 저장소에 넣지 않는다. `godot/` 밖이라 APK에도 들어가지 않는다.

```powershell
# 스프라이트: 배경 제거 → 피사체 크롭 → 팔레트 24색 → 캔버스 크기로 최빈색 축소 → 알파 이진화
python scripts\pixelize_sprite.py art\raw\char_vagrant.png godot\assets\sprites\char_vagrant.png --size 32 --preview art\preview\char_vagrant.png --force

# 바닥 타일: 이음매 점수 출력, 채도를 빼서 스테이지 틴트가 먹게
python scripts\pixelize_sprite.py art\raw\ground_tile.png godot\assets\sprites\ground_tile.png --size 64 --mode tile --desaturate 1 --force

# 기존 파일 덮어쓰기는 --force가 있어야만 한다
```

스크립트가 하는 일과 막아 주는 것:

- 배경이 진짜 투명이면 알파를 그대로 쓰고, 아니면 테두리 단색(보통 `#FF00FF`)을 테두리에서부터 flood fill로 지운다. 피사체 안의 비슷한 색은 남는다. 닫힌 구멍(고리 안쪽, 새장 창살 사이)은 배경색과 거의 같은 픽셀만 지운다.
- **테두리가 단색이 아니면 에러로 멈춘다** — 체크무늬를 그려 넣은 "가짜 투명"이 다시 들어오지 않는다 (2026-11-04 이전 UI 아이콘 7개가 이렇게 망가졌었다).
- 흰색·회색 배경은 경고한다(밝은 피사체 가장자리가 같이 지워질 수 있음).
- 축소 기본값은 **최빈색(`--resample mode`)**: 목표 픽셀이 덮는 영역에서 가장 많은 팔레트 색을 고른다. Codex는 "32×32"라고 해도 64px급 격자로 그리기 때문에, 면적 평균(`--resample box`)으로 줄이면 색이 섞여 뭉개진다. 기존 `generate_missing_ui_assets.py`의 NEAREST 축소는 32픽셀 중 1픽셀만 집어 와서 지저분했다.
- 결과 알파는 0/255 두 값뿐이다(반투명 가장자리 없음).

옵션: `--height`(직사각 캔버스), `--anchor bottom`, `--colors N`, `--outline 1A1424`(외곽선을 스크립트로 추가, `--pad 1` 필요), `--key RRGGBB`, `--tolerance`.

**미리보기에서 볼 것**: 형태가 뭉개졌는가 / 이 크기에서 무엇인지 바로 읽히는가 / 가장자리에 분홍 잔여 픽셀이 없는가 / 캐릭터는 검은 실루엣으로 칠해도 구분되는가.

---

## 3. 공통 스타일 블록

한 장씩 독립 세션(`codex exec`)으로 만들어도 톤이 맞도록, 매 요청에 아래 블록 전체를 넣는다. 첫 줄의 종류 문장은 그룹마다 다르다 (`codex_generate_sprites.py`의 `TEMPLATES`: char / enemy / icon / proj / tile / ui).

```text
Use your image generation tool to create exactly one image. Do not write code or run shell commands.

A 16-bit era RPG character sprite that is exactly {N}x{N} pixels, displayed enlarged with nearest-neighbor
scaling (every original pixel becomes a large crisp square). Style like a classic overworld sprite: cute chibi
proportions with a large head, readable at its tiny native size, very limited detail. Front-facing, full body,
centered.
- Max 16 colors, flat shading with one highlight and one shadow tone per material, 1-pixel dark outline
  (#1A1424) around the silhouette, light from the top-left.
- Keep colors mid-to-light so it stands out on a dark battlefield; no large near-black areas.
- Dark-fantasy night world palette accents: pale moonlight #DDEBFF, ember gold #F2C66A.
- Subject: {§4 표의 프롬프트}
- Background: one flat solid pure magenta #FF00FF everywhere outside the subject. No checkerboard, no
  transparency pattern, no shadow, no scenery, no frame, no text, no letters.
- Square image.
```

**시행착오 기록 (2026-11-04)**: 처음 쓴 "Strict 32x32 pixel grid, draw as if 32x32 scaled up" 문구는 Codex가 무시하고 사실적 비율의 128px급 그림을 그렸다. 32px로 줄이면 어두운 덩어리가 돼 못 쓴다. "16-bit era RPG sprite + chibi proportions + mid-to-light colors"로 바꾸자 64px급 격자의 굵은 형태로 나와 32px에서도 읽혔다. 어두운 회색 적(사냥개 1차)은 배경과 섞여 "light blue-gray fur, strong contrast, few large shapes"로 다시 그렸다.

`{N}x{N}`은 §4 표의 캔버스 크기로 바꾼다(직사각 캔버스는 `28x12`처럼). 투사체·타일·UI 아이콘처럼 규칙이 다른 그룹은 해당 절에 추가 지시가 있다.

피사체에 분홍·자홍색이 많으면(예: `shop_power`) 배경을 **순수 초록 `#00FF00`**으로 바꿔 요청한다. 스크립트는 테두리 색을 자동으로 배경으로 잡으므로 옵션을 바꿀 필요가 없다.

---

## 4. 애셋별 프롬프트

각 행의 프롬프트 앞에 스타일 블록(또는 "같은 스타일 블록, N=…")을 붙인다. "명령" 열은 `pixelize_sprite.py`에 넘길 크기 인자다.

### 4.1 플레이어 캐릭터 — 캔버스 32×32, 정면/3/4 정면, 정지 1장

전투 32px(1배), 캐릭터 선택·메인 메뉴 96px(3배). 잠금 상태는 검은 실루엣으로 보이므로 **실루엣만으로 서로 구분**돼야 한다. 좌우 반전 없음. 캐릭터 색은 `Characters.gd`의 `color` 값, 상징물은 시작 무기에 맞췄다.

| 파일 | 명령 | 프롬프트 |
|---|---|---|
| `char_vagrant.png` | `--size 32` | Full-body hero, a lone wandering swordsman in a dark hooded travel cloak, one silver shoulder guard, holding a pale-blue moonlit longsword down at the side, calm stance. Accent color moonlight blue #7CB8FF. Silhouette: long cloak + long sword. |
| `char_spirit_sister.png` | `--size 32` | Full-body hero, a young nun in a dark navy habit with a white wimple and veil, hands clasped around a small rosary, two tiny cyan spirit orbs floating at shoulder height. Accent color cyan #66F2F2. Silhouette: veil + floating orbs. |
| `char_hunter.png` | `--size 32` | Full-body hero, a nimble hooded archer in brown leather and a short green-brown hood, a short bow in one hand, a quiver of arrows on the back, light boots. Accent color star gold #F2D966 on the arrow fletching. Silhouette: bow + quiver. |
| `char_berserker.png` | `--size 32` | Full-body hero, a huge broad-shouldered barbarian warrior, bare muscular arms, iron helmet with two horns, wild beard, holding a great axe wrapped in thorny green vines. Accent color thorn green #80F266. Silhouette: wide bulky body + horns + big axe. |
| `char_pyromancer.png` | `--size 32` | Full-body hero, a fire mage in a dark red robe with a tall pointed hood, glowing ember hands, a small living flame wisp floating beside them. Accent color ember orange #FF8C33. Silhouette: pointed hood + flame. |

앱 아이콘(`icons/icon*.png`, 적응형 432px)은 새 `char_vagrant`가 확정된 뒤 별도로 만든다 — 32px 스프라이트를 13.5배로 늘리지 말고 아이콘용 일러스트를 따로 생성한다.

### 4.2 적 — 정면/3/4 정면, 배율 1

스테이지별 `enemy_tint`(최대 1.2배)와 피격 흰색 플래시가 곱해진다 → 원색은 중간 명도로, 외곽선은 어둡게. 피격 판정 원은 캔버스 중앙 기준이라 **피사체를 가운데에** 둔다.

| 파일 | 캔버스 | 명령 | 프롬프트 |
|---|---|---|---|
| `enemy_slime.png` | 28 | `--size 28` | A small round gelatinous slime blob, moss green, glossy top-left highlight, two dot eyes, slightly squashed. (분열체도 이 그림을 0.67배로 재사용) |
| `enemy_bat.png` | 24 | `--size 24` | A small night bat facing the viewer with wings spread wide, purple-gray fur, tiny fangs, two glowing pale eyes. |
| `enemy_caster.png` | 28 | `--size 28` | A hooded cultist caster in tattered dark violet robes, face hidden in shadow except two glowing eyes, holding a short crooked staff topped with a violet orb. |
| `enemy_dasher.png` | 32 | `--size 32` | A wild horned shadow boar lowering its head to charge, three-quarter front view, dark brown bristly hide, two curved tusks, red glowing eyes. |
| `enemy_hound.png` | 36 | `--size 36` | A shadow hound charging toward the viewer, chunky simple body with big paws, light blue-gray fur with a pale belly and dark outline, big glowing ember-orange eyes, bared white teeth. Strong contrast, few large shapes. (가장 빠른 적) |
| `enemy_splitter.png` | 36 | `--size 36` | A large bloated slime, same moss green as the small slime, with two smaller slime blobs visibly budding off its sides, cracked surface, two eyes. (죽으면 작은 슬라임으로 분열) |
| `enemy_knight.png` | 48 | `--size 48` | A hollow cursed knight in dented dark iron plate armor, tall tower shield in front, broken sword, empty helmet visor with a faint violet glow inside. Heavy and slow. |
| `enemy_miniboss.png` | 56 | `--size 56` | A large wraith specter in a ragged dark shroud, long clawed arms reaching forward, cold pale-cyan light glowing from inside the hood, wispy lower body with no legs. |
| `enemy_boss.png` | 96 | `--size 96` | The Warden of the Seal, final boss: a towering armored guardian with a horned stone crown, cracked stone-and-iron body covered in glowing violet seal runes, holding a giant key-shaped mace, a dark seed-like crystal glowing in its chest. Accent violet #A04BE6. (주변 오라·가시 4개는 코드가 그리므로 그리지 않는다) |

### 4.3 무기 아이콘 — 캔버스 54×54, 레벨업 108px(2배)·캐릭터 카드 34px

아이콘은 UI 전용이 된다(투사체는 §4.4로 분리). 대각선 구도 OK, 작은 반짝임 OK.

| 파일 | 명령 | 프롬프트 |
|---|---|---|
| `icon_moon_dagger.png` | `--size 54` | Weapon icon: a curved silver throwing dagger whose blade is shaped like a crescent moon, pale blue glow edge, placed diagonally from bottom-left to top-right. |
| `icon_spirit_orb.png` | `--size 54` | Weapon icon: a glowing cyan spirit orb with a tiny swirling soul inside, two small sparks orbiting around it. |
| `icon_fire_wisp.png` | `--size 54` | Weapon icon: a small living flame wisp with two eyes, orange core and yellow tips, a few embers. |
| `icon_thorn_ring.png` | `--size 54` | Weapon icon: a ring-shaped wreath of dark green thorny vines with sharp spikes pointing outward all around. |
| `icon_star_needle.png` | `--size 54` | Weapon icon: a slender golden needle with a small four-pointed star at its head, a couple of tiny sparkles, placed diagonally from bottom-left to top-right. |

### 4.4 투사체 (신규 파일) — 배율 1, **오른쪽(+X)을 향하게**

`Projectile.gd`가 노드를 진행 방향으로 회전시킨다 → 날아가는 쪽이 이미지의 **오른쪽**이어야 한다. 꼬리(트레일)는 코드가 Line2D로 그리므로 그리지 않는다. 스타일 블록에 "Horizontal, tip pointing to the right edge, no motion trail"을 추가한다.

| 신규 파일 | 캔버스 | 명령 | 프롬프트 | 대체하는 현재 텍스처 |
|---|---|---|---|---|
| `proj_moon_dagger.png` | 28×12 | `--size 28 --height 12` | Crescent-bladed silver dagger lying horizontally, tip pointing right, pale blue edge. | `icon_moon_dagger` (MoonDagger.gd) |
| `proj_star_needle.png` | 24×8 | `--size 24 --height 8` | Thin golden needle lying horizontally, tiny star at the back end, point to the right. | `icon_star_needle` (StarNeedle.gd) |
| `proj_thorn.png` | 20×10 | `--size 20 --height 10` | A single sharp dark-green thorn spike, horizontal, point to the right. | `icon_thorn_ring` (ThornRing.gd) |
| `proj_spirit_orb.png` | 24 | `--size 24` | Round glowing cyan spirit orb with a bright white core, round so direction does not matter. | `proj_orb` (SpiritOrb.gd, 시안 틴트 곱해짐) |
| `proj_enemy.png` | 20 | `--size 20` | Round cursed energy bolt, **white and light gray only** (tinted in engine), dark outline, small inner swirl. | `proj_orb` (EnemyProjectile.gd, 적마다 색 틴트) |

### 4.5 패시브 / 상점 아이콘 — 캔버스 54×54, 레벨업 108px(2배)·상점 54px(1배)

| 파일 | 명령 | 프롬프트 |
|---|---|---|
| `shop_swift.png` | `--size 54` | Passive icon: a pair of leather boots with small white wings at the ankles, green accents #80D980. (신속의 부츠 — 이동속도) |
| `shop_magnet.png` | `--size 54` | Passive icon: a horseshoe magnet charm hanging on a cord, violet enamel #BF80F2 with silver tips, two tiny attraction sparks. (자석 부적 — 흡수 범위) |
| `shop_heart.png` | `--size 54` | Passive icon: a red heart encased in riveted dark iron plates, a crack of red light between the plates. (철의 심장 — 최대 HP, 체력 회복 카드에도 쓰임) |
| `shop_focus.png` | `--size 54` | Passive icon: a golden hourglass with glowing sand, a small focused eye emblem on the frame. Gold #E6B333. (전투 집중 — 쿨다운 감소) |
| `shop_power.png` | `--size 54` | Passive icon: a glowing hot-pink power crystal locked inside a small iron cage, energy cracks. Pink #FF4DA6. Background flat pure green #00FF00 instead of magenta. (파워 코어 — 피해량) |

### 4.6 바닥 타일 — 캔버스 64×64, 지금 바로 교체 가능

5개 스테이지가 같은 3장을 쓰고, 스테이지 톤(0.28~0.62배)을 **곱해서** 색을 낸다 → 타일은 **밝은 무채색**(평균 #B0B0B0 정도)이어야 한다. 3장이 해시로 섞이고 좌우 반전되므로 서로 붙어도 티가 안 나야 한다: 같은 세션에서 같은 바탕 재질로, 대비를 낮게.
스타일 블록 대신 아래 블록을 쓴다.

```text
Seamless tileable top-down ground texture for a pixel art game, {N}x{N} pixel grid look, crisp square pixels,
no anti-aliasing. Neutral light gray only (no hue, will be color-tinted in engine), average value around #B0B0B0,
low contrast. Tiles perfectly on all four sides. Fills the whole frame edge to edge. No objects, no characters,
no text, no border.
```

| 파일 | 명령 | 프롬프트 (블록 뒤에) |
|---|---|---|
| `ground_tile.png` | `--size 64 --mode tile --desaturate 1` | Packed ancient earth with small pebbles and faint cracks. |
| `ground_tile_b.png` | `--size 64 --mode tile --desaturate 1` | Same packed earth as before, with two worn flat flagstones partly sunk in it. |
| `ground_tile_c.png` | `--size 64 --mode tile --desaturate 1` | Same packed earth as before, with sparse short grass tufts and thin roots. |

스크립트가 이음매 점수(seam ratio)를 출력한다. 1.5를 넘으면 경고 → 재생성.

### 4.7 장식 — 캔버스 48×48 (화면 38~54px 랜덤, 대부분 1배로 스냅)

데코도 스테이지 톤이 곱해진다 → 바위는 무채색, 횃불은 불꽃만 색.

| 파일 | 명령 | 프롬프트 |
|---|---|---|
| `decor_rock.png` | `--size 48 --desaturate 1` | A cluster of two weathered boulders with a little moss, three-quarter top-down view, neutral gray stone. |
| `decor_torch.png` | `--size 48` | A standing iron brazier on a short post with a small bright yellow-orange flame, three-quarter top-down view, dark iron. (아래 따뜻한 빛은 코드가 그린다) |

### 4.8 UI 아이콘 — 가짜 투명 교체분, 지금 바로 교체 가능

UI 키트 톤(기존 `icon_nav_*`·`icon_gold_coin`과 같은 픽셀아트)에 맞춘다. 스타일 블록의 `{N}`은 캔버스 크기로 바꾸고 외곽선은 아이콘 테두리용으로 그대로 둔다. 캔버스는 실제 표시 크기에 맞춰 키웠다 — 코드는 TextureRect/`draw_texture_rect` 크기로 그리므로 원본 크기와 무관하다.

| 파일 | 캔버스 (기존) | 표시 | 명령 | 프롬프트 |
|---|---|---|---|---|
| `ui/icon_hud/icon_hud_joystick_base.png` | 128 (32) | 260px, 알파 0.72 | `--size 128` | Virtual joystick base: a flat circular dark-navy disc, thin pale-silver rim, four tiny arrow notches at up/down/left/right, subtle inner ring. Perfect circle, top-down. |
| `ui/icon_hud/icon_hud_joystick_thumb.png` | 52 (32) | 104px, 알파 0.88 | `--size 52` | Joystick thumb knob: a round pale moonlight-silver button seen from above, soft bevel, small ember-gold dot in the center. Perfect circle. |
| `ui/icon_hud/icon_hud_timer.png` | 44 (32) | 44px | `--size 44` | A small round pocket watch, dark navy frame, pale moonlight face, two silver hands, no numbers. |
| `ui/icon_hud/icon_hud_kills.png` | 40 (32) | 40px | `--size 40` | A small pale bone skull with crossed bones behind it, dark outline. |
| `ui/icon_reward/icon_reward_coins.png` | 48 (48) | 48px | `--size 48` | A small stack of three gold coins with a fourth coin leaning in front, crescent-moon emboss, bright rim highlight. |

미연결 `icon_hud_skill_button`·`icon_close_x`는 해당 기능을 붙일 때 같은 방식으로 만든다.

---

## 5. 완료 후 정리

- AI 생성분이라 프롬프트·사용 이유를 `HISTORY.md`에 남긴다 (`ASSET_GUIDE.md` §7).
- Kenney 스프라이트가 모두 빠지면 `godot/assets/sprites/KENNEY_LICENSE.txt`, README·CLAUDE.md의 라이선스 문구를 정리한다.
- `ASSET_INVENTORY.md` 표의 "현재 그림"·"문제" 열과 Play 스토어 스크린샷(`play_store/screenshot_*`)을 갱신한다.
