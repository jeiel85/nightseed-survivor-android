# NIGHTSEED_INTEGRATED_DESIGN

This is a single-file summary of the Nightseed Survivor design pack.

## Final Identity

```text
Repository: nightseed-survivor
Project Name: Nightseed Survivor
Codename: NIGHTSEED
App ID: com.jeiel85.nightseedsurvivor
Engine: Godot 4.x
Language: GDScript
Primary Spec: docs/GAME_SPEC.md
```

## Core Direction

Nightseed Survivor is a small offline 2D survivor-like action game.

The player only moves. Weapons attack automatically. Enemies swarm from all sides. Level-ups provide upgrade choices. The player survives for 10 minutes.

## Development Direction

- Build with placeholder visuals first.
- Validate movement, combat, level-up, and survival tension before final art.
- Keep logic and visual nodes separated.
- Use Godot scenes in a way that allows easy asset replacement.
- Keep MVP offline-only.
- Do not add ads, analytics, login, IAP, or network features during MVP.
- Use Automation First agent workflow.
- Use GitHub Actions for final build verification when available.

## MVP

- 1 character
- 1 stage
- 5 weapons
- 5 passives
- 4 normal enemies
- 1 boss
- 10-minute survival
- XP gems
- Level-up cards
- Gold
- Permanent upgrades
- Local save
- Game over and clear screens

## Placeholder Policy

Final art assets are not required for MVP implementation.

Initial visuals:

| Target | Placeholder |
|---|---|
| Player | Blue circle |
| Enemy | Red/orange/gray circles |
| Boss | Large purple circle |
| Projectile | Small bright circle |
| XP Gem | Green diamond |
| Gold | Yellow circle |
| Background | Dark plain/tile |

## Improvement Strategy

This project should address common survivor-like friction points early:

- First level-up within 30 seconds
- Clear weapon role differences
- Level 4~5 pattern changes
- Reduced visual clutter
- Meaningful enemy role separation
- One-hand mobile-friendly control
- Gold and permanent upgrades for replay motivation
- Balance values separated from core logic where possible

## First Development Target

Milestone 1 is successful when:

```text
Player moves.
Camera follows the player.
Enemies spawn.
Enemies chase the player.
Enemy contact reduces HP.
HP reaches 0 and game over appears.
HUD shows HP and survival time.
All visuals are placeholders.
```

## Included Files

```text
README.md
AGENTS.md
CHANGELOG.md
HISTORY.md
docs/GAME_SPEC.md
docs/IMPROVEMENT_STRATEGY.md
docs/ASSET_GUIDE.md
docs/ARCHITECTURE.md
docs/ROADMAP.md
docs/BALANCE.md
docs/RELEASE_CHECKLIST.md
.agent/tasks.md
.agent/progress.md
.agent/decisions.md
prompts/FIRST_AGENT_PROMPT.md
```
