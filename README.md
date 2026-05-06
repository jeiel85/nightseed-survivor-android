# Nightseed Survivor

Nightseed Survivor is a small offline 2D survivor-like action game built for fast iteration with agentic coding.

The player moves, weapons attack automatically, enemies swarm from all sides, and each level-up gives a choice of upgrades.

## Project Identity

```text
Repository: nightseed-survivor
Project Name: Nightseed Survivor
Codename: NIGHTSEED
App ID: com.jeiel85.nightseedsurvivor
Main Branch: main
Primary Spec: docs/GAME_SPEC.md
```

## Tech Stack

- Godot 4.x
- GDScript
- PC-first development
- Android target after MVP stabilization

## MVP Goal

Build a 10-minute survival stage with:

- 1 character
- 1 map
- 5 weapons
- 5 passive upgrades
- 4 normal enemy types
- 1 boss
- Local save
- Permanent upgrades
- Placeholder graphics first
- Asset replacement-ready scene structure

## Development Style

This project is designed for autonomous coding agents.

Core rules:

- Keep every change small and reviewable.
- Prioritize the playable loop before visual polish.
- Use placeholder assets until the core loop is fun.
- Keep gameplay logic independent from final art.
- Update documentation after meaningful changes.
- Prefer GitHub Actions for final build verification.
