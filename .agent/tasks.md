# Tasks

## Current Priority

### Story Foundation
- [x] Add canonical story document folder under `docs/story/`
- [x] Add Nightseed lore definition
- [x] Add staged dialogue guide
- [x] Add story UI copy guide
- [x] Add glossary data in `godot/data/story_terms.json`
- [x] Update stage descriptions with story copy
- [x] Add runtime story event UI (StoryBanner + stage intro / boss warning / boss intro / clear lines)
- [x] Add codex/glossary UI for story terms
- [x] Wire boss warning + fragment-recovered subtitle into result flow

### Infrastructure & Deployment
- [x] Refactor GitHub Pages structure (Branding page at root, game at `/live/`)
- [x] Add branding page source in `branding/`
- [x] Update CI/CD workflow for organized deployment

### Milestone 1: Playable Prototype

- [x] Create Godot 4 project under `godot/`
- [x] Add main gameplay scene
- [x] Add placeholder player
- [x] Add WASD and arrow-key movement
- [x] Add camera follow
- [x] Add placeholder enemy
- [x] Add enemy spawner
- [x] Make enemies move toward the player
- [x] Add player HP
- [x] Add contact damage
- [x] Add HUD with HP and survival time
- [x] Add game over state
- [x] Update `.agent/progress.md`
- [x] Update `HISTORY.md`
- [x] Update `CHANGELOG.md` if user-visible behavior changes

---

## Next Priority

### Milestone 2: Combat Loop

- [ ] Add WeaponManager
- [ ] Add WeaponBase
- [ ] Add Moon Dagger
- [ ] Add projectile collision
- [ ] Add enemy HP
- [ ] Add enemy death
- [ ] Add kill counter
- [ ] Add simple object pool for projectiles

---

## Backlog

- [ ] Add experience gems
- [ ] Add level-up UI
- [ ] Add passive upgrades
- [ ] Add wave director
- [ ] Add boss
- [ ] Add save manager
- [ ] Add permanent upgrades
- [ ] Add virtual joystick
- [ ] Add Android export
