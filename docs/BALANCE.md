# BALANCE

## 1. Player

| Stat | Value |
|---|---:|
| HP | 100 |
| Move Speed | 160 |
| XP Radius | 80 |
| Invincible Time | 0.35 (2026-06 리워크, 종전 0.5) |
| Starting Weapon | Moon Dagger |

---

## 2. Stage

| Stat | Value |
|---|---:|
| Duration | 300 seconds (Cursed Tomb: 330) |
| Boss Spawn | 270 seconds (Cursed Tomb: 300) |
| Clear Time | 300 seconds (Cursed Tomb: 330) |
| First Level-Up Target | 25 seconds |
| MiniBoss Spawns | 60 / 120 / 180 / 240 s |

---

## 3. Difficulty

| Difficulty | HP Mult | Damage Mult | Reward Mult |
|---|---:|---:|---:|
| Normal | 1.0 | 1.0 | 1.0 |
| Hard | 1.7 | 1.45 | 1.3 |
| Nightmare | 2.9 | 2.0 | 1.7 |

2026-06 리워크: Normal이 적을 기준선보다 약화(0.85/0.9)시키던 보정을 제거했다.
"거의 자동사냥" 피드백의 한 축이었음. 초보 구제는 난이도 하향이 아니라
영구강화(메타 진행)가 담당한다.

---

## 4. XP Formula

```text
required_xp = 5 + current_level * 4
```

Examples:

| Level | Required XP |
|---|---:|
| 1 -> 2 | 9 |
| 2 -> 3 | 13 |
| 3 -> 4 | 17 |
| 4 -> 5 | 21 |
| 5 -> 6 | 25 |

---

## 5. Enemy Limits

| Stat | Value |
|---|---:|
| Initial Max Enemies | 150 |
| PC Target Max Enemies | 250 |
| Android Target Max Enemies | 150 |
| Max Projectiles | 200 |
| Max Pickups | 300 |

---

## 6. Spawn

| Stat | Value |
|---|---:|
| Initial Spawn Interval | 1.0 |
| Minimum Spawn Interval | 0.15 |
| Initial Spawn Count | 2 |
| Maximum Spawn Count | 12 |

---

## 7. Enemy Values

| Enemy | HP | Damage | Speed | XP |
|---|---:|---:|---:|---:|
| Shadow Slime | 12 | 8 | 70 | 1 |
| Bone Bat | 8 | 6 | 120 | 1 |
| Hollow Knight | 40 | 14 | 55 | 3 |
| Rot Hound | 24 | 12 | 140 | 2 |
| Ancient Shade | 1200 | 24 | 65 | 50 |

---

## 8. Gold Drop

| Source | Value |
|---|---:|
| Normal Enemy | 5% |
| Elite Enemy | 15% |
| Boss | 100 gold |

---

## 9. Permanent Upgrade Base Costs

| Upgrade | Base Cost |
|---|---:|
| Max HP | 50 |
| Damage | 80 |
| Move Speed | 100 |
| Magnet | 70 |
| Gold Bonus | 120 |

Formula:

```text
cost = base_cost * current_level * current_level
```

---

## 10. Initial Weapon Values

### Moon Dagger

| Level | Damage | Cooldown | Projectile Count | Pierce |
|---|---:|---:|---:|---:|
| 1 | 10 | 1.2 | 1 | 0 |
| 2 | 14 | 1.2 | 1 | 0 |
| 3 | 14 | 0.9 | 1 | 0 |
| 4 | 14 | 0.9 | 2 | 0 |
| 5 | 24 | 0.8 | 2 | 1 |

---

## 11. Balance Notes

- 첫 레벨업이 30초보다 늦으면 초반 적 XP 또는 스폰 수를 올린다.
- 2분 전에 사망이 잦으면 초기 적 피해량 또는 스폰 간격을 완화한다.
- 3분 이후 위기감이 약하면 spawn_count 또는 Rot Hound 비중을 올린다.
- 5분 클리어율이 너무 낮으면 보스 체력보다 일반 적 밀도를 먼저 조정한다.
- 모바일 프레임 저하가 있으면 적 수, 픽업 수, 투사체 수 순으로 제한한다.

---

## 12. 2026-06 난이도 리워크 (v0.36 예정)

"거의 자동사냥 가능" 피드백에 대한 일괄 조정. 측정 하니스:
`godot --headless --path godot -s tests/sim_afk_run.gd -- <난이도> <배속> <afk|kite>`

### 변경 내역

| 항목 | 종전 | 변경 | 파일 |
|---|---|---|---|
| Normal 배수 | 0.85 / 0.9 | 1.0 / 1.0 | `Difficulty.gd` |
| Hard 배수 | 1.5 / 1.3 | 1.7 / 1.45 | `Difficulty.gd` |
| Nightmare 배수 | 2.5 / 1.7 | 2.9 / 2.0 | `Difficulty.gd` |
| 시간 스케일 (분당) | HP +28% / DMG +14% / SPD +5.5% | HP +34% / DMG +20% / SPD +8% | `EnemyBase.gd` |
| 피격 무적 | 0.5s | 0.35s | `Player.gd` |
| 무기 레벨업 곡선 | DMG ×1.25 / CD ×0.88 | DMG ×1.22 / CD ×0.90 | `WeaponBase.gd` |
| **적 재배치 (신규)** | 없음 — 도주 시 상한(280) 도달 후 스폰 정지 → circle-kiting 무한 생존 | 플레이어에서 1050px 초과 적을 진행 방향 앞 스폰 링으로 재배치 (보스/미니보스 `recycle_exempt`) | `EnemySpawner.gd` |

### 봇 측정 결과 (Forest, 첫 캐릭터, 강화 0)

| 시나리오 | 리워크 전 | 리워크 후 |
|---|---|---|
| 무입력 (afk) Normal | 37s 사망 | 34s 사망 |
| 단순 도주 (kite) Normal | 125s 사망, 단 도주 유지 시 상한 악용으로 사실상 무한 생존 | **73s 사망** (재배치로 도주 루트 차단) |
| 단순 도주 (kite) Hard | — | 57s 사망 |

봇은 "카드 아무거나 + XP 안 줍는" 최악 플레이 기준이므로, 숙련 플레이어
기준 체감 난이도는 실기 플레이로 재검증한다. 너무 어려우면 시간 스케일
계수(EnemyBase)부터 되돌린다 — 난이도 배수보다 후반 체감에 직접적이다.
