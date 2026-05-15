# BALANCE

## 1. Player

| Stat | Value |
|---|---:|
| HP | 100 |
| Move Speed | 160 |
| XP Radius | 80 |
| Invincible Time | 0.5 |
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
| Normal | 0.85 | 0.9 | 1.0 |
| Hard | 1.5 | 1.3 | 1.3 |
| Nightmare | 2.5 | 1.7 | 1.7 |

Normal은 첫 스테이지 기준으로 접촉 피해 부담을 낮춰, 첫 플레이어가 빌드 선택과 보스 흐름을 확인할 여유를 갖도록 한다.

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
