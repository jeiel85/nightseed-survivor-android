# ASSET_GUIDE

## 1. Current Asset Status

이 프로젝트는 현재 최종 그래픽 애셋이 없다.

그래픽 애셋이 없어도 개발을 중단하지 않는다.

MVP 단계에서는 placeholder visuals를 사용해서 핵심 게임 루프, 조작감, 성장감, 성능을 먼저 검증한다.

---

## 2. Placeholder Asset Policy

### 원칙

- 모든 캐릭터, 적, 투사체, 픽업은 단순 도형으로 표현한다.
- 최종 그래픽을 전제로 코드를 작성하지 않는다.
- 로직과 시각 표현을 분리한다.
- 실제 애셋 교체 시 씬 구조를 크게 바꾸지 않도록 한다.
- 애셋 파일 경로는 하드코딩하지 않고 가능한 한 상수 또는 데이터 파일에서 관리한다.
- placeholder 상태에서도 플레이 대상, 적, 투사체, 경험치, 골드가 명확히 구분되어야 한다.

---

## 3. Placeholder 표현 규칙

| 대상 | 임시 표현 |
|---|---|
| Player | 파란 원 |
| Shadow Slime | 빨간 작은 원 |
| Bone Bat | 주황 작은 원 |
| Hollow Knight | 어두운 회색 큰 원 |
| Rot Hound | 붉은 빠른 원 |
| Ancient Shade | 보라색 큰 원 |
| Moon Dagger | 밝은 작은 투사체 |
| Spirit Orb | 플레이어 주변 회전 원 |
| Fire Wisp | 짧은 원형 폭발 |
| Thorn Ring | 반투명 원형 파동 |
| Star Needle | 작은 바늘형 투사체 |
| XP Gem | 초록 다이아몬드 |
| Gold Coin | 노란 원 |
| Background | 어두운 단색 또는 단순 타일 |

---

## 4. 권장 씬 구조

플레이어:

```text
Player.tscn
  Player
    CollisionShape2D
    Visual
      Sprite2D
```

적:

```text
EnemyBase.tscn
  EnemyBase
    CollisionShape2D
    Visual
      Sprite2D
```

투사체:

```text
Projectile.tscn
  Projectile
    CollisionShape2D
    Visual
      Sprite2D
```

픽업:

```text
ExperienceGem.tscn
  ExperienceGem
    CollisionShape2D
    Visual
      Sprite2D
```

핵심은 `Visual` 노드를 교체해도 로직이 깨지지 않게 하는 것이다.

---

## 5. 초기 스프라이트 크기 목표

| Asset | Size |
|---|---|
| Player | 32x32 |
| Small Enemy | 24x24 |
| Normal Enemy | 32x32 |
| Large Enemy | 48x48 |
| Boss | 96x96 |
| Projectile | 16x16 |
| XP Gem | 12x12 |
| Gold Coin | 12x12 |
| Tile | 32x32 |
| Weapon Icon | 64x64 |
| Passive Icon | 64x64 |

---

## 6. 실제 애셋 경로

실제 애셋을 추가할 때는 다음 경로를 사용한다.

```text
godot/assets/
  sprites/
    player/
    enemies/
    weapons/
    pickups/
    ui/
    environment/
  audio/
    sfx/
    bgm/
  fonts/
  shaders/
```

---

## 7. 최종 아트 방향

- 어두운 판타지
- 단순한 2D 탑다운
- 픽셀 아트 또는 심플 벡터 스타일
- 낮은 리소스 비용
- 명확한 실루엣
- 모바일에서도 구분 가능한 색 대비
- 과도한 노이즈 금지

---

## 8. 애셋 제작 우선순위

| 우선순위 | 애셋 | 이유 |
|---|---|---|
| 1 | 플레이어 | 사용자가 계속 보는 대상 |
| 2 | 기본 적 2종 | 전투 가독성에 중요 |
| 3 | 경험치 보석 | 성장 루프의 핵심 |
| 4 | 투사체 | 타격감에 중요 |
| 5 | 배경 타일 | 분위기 형성 |
| 6 | 보스 | 클리어 목표감 |
| 7 | UI 아이콘 | 레벨업 선택지 가독성 |
| 8 | 이펙트 | 나중에 추가 가능 |
| 9 | 사운드 | 게임감 개선용 |

---

## 9. 애셋 교체 기준

실제 그래픽을 추가할 때 아래 조건을 확인한다.

- 기존 placeholder와 크기가 크게 다르지 않은가
- CollisionShape2D를 다시 맞춰야 하는가
- Sprite2D pivot이 중앙 기준인가
- 모바일 화면에서 식별 가능한가
- 배경과 색 대비가 충분한가
- 무기 이펙트가 적과 플레이어를 가리지 않는가
- 라이선스가 상업적 배포에 문제가 없는가

---

## 10. 금지 사항

- 기존 상용 게임의 스프라이트, 아이콘, UI를 복사하지 않는다.
- 저작권이 불분명한 이미지를 저장소에 포함하지 않는다.
- 임시 애셋을 최종 애셋처럼 릴리즈하지 않는다.
- placeholder 교체를 위해 로직 코드를 대규모로 수정하지 않는다.
