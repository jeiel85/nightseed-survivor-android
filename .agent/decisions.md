# Decisions

## 2026-05-06

### Decision: Use `nightseed-survivor` as repository name

Reason:

- The name clearly communicates the survivor-like genre.
- `Nightseed` provides a distinctive project identity.
- The repository name is short, readable, and suitable for GitHub.

### Decision: Use `Nightseed Survivor` as project/game name

Reason:

- The name fits the dark fantasy direction.
- It is suitable for a small 2D survival action game.
- It can remain as the store-facing title unless a naming conflict is later found.

### Decision: Use `NIGHTSEED` as project codename

Reason:

- Short and easy to reference in documentation.
- Distinct from the user-facing game name.

### Decision: Use Godot 4 and GDScript

Reason:

- Godot is suitable for 2D games.
- GDScript is fast for iteration.
- Scene-based workflows are friendly to agentic coding.

### Decision: Start with placeholder graphics

Reason:

- Final art assets are not available.
- Core gameplay can be validated without final art.
- Logic and visual nodes will be separated to make later asset replacement easier.

### Decision: Do not add online, ads, login, analytics, or IAP in MVP

Reason:

- MVP should validate the core game loop first.
- These features add policy, privacy, build, and maintenance complexity.
