# FIRST_AGENT_PROMPT

Use this prompt as the first instruction for the coding agent.

```text
You are an autonomous coding agent working on Nightseed Survivor.

Repository:

https://github.com/jeiel85/nightseed-survivor.git

Project goal:

Create a Godot 4 project for a small offline 2D vampire-survivor-like action game.

Before coding, read these files in order:

1. AGENTS.md
2. README.md
3. docs/GAME_SPEC.md
4. docs/IMPROVEMENT_STRATEGY.md
5. docs/ASSET_GUIDE.md
6. docs/ARCHITECTURE.md
7. docs/ROADMAP.md
8. docs/BALANCE.md
9. .agent/tasks.md
10. .agent/progress.md
11. .agent/decisions.md
12. HISTORY.md
13. CHANGELOG.md

Your first task:

Build Milestone 1: Playable Prototype.

Required result:

- Create or verify the Godot project structure under `godot/`.
- Add a main gameplay scene.
- Add a controllable player.
- Add simple WASD and arrow-key movement.
- Add a camera that follows the player.
- Add a basic enemy scene.
- Add an enemy spawner that spawns enemies around the player.
- Make enemies move toward the player.
- Add player HP.
- Apply contact damage from enemies to the player.
- Add a simple HUD showing HP and survival time.
- Trigger game over when HP reaches 0.

Asset rules:

- Final graphics assets do not exist yet.
- Use placeholder primitives only.
- Player should be a blue circle or simple placeholder sprite.
- Enemy should be a red circle or simple placeholder sprite.
- Keep gameplay logic independent from final sprite assets.
- Separate logic nodes from visual nodes.
- Do not block implementation because art assets are missing.

Constraints:

- Keep the implementation small and reviewable.
- Do not add online features.
- Do not add login.
- Do not add ads.
- Do not add analytics.
- Do not add in-app purchase.
- Do not add copyrighted assets.
- Use placeholder shapes or simple sprites for now.
- Prefer simple GDScript.
- Do not perform destructive git commands.
- Update `.agent/progress.md` after completing work.
- Update `.agent/tasks.md` with the next recommended tasks.
- If you make a design decision, record it in `.agent/decisions.md`.
- Update `HISTORY.md`.
- Update `CHANGELOG.md` only if there is user-visible behavior or project structure change.

After implementation:

- Run the project if possible.
- Report what changed.
- Report how to test it.
- Commit the changes with a clear Korean commit message.
- Push the branch if remote access is available.
- If CI exists, check GitHub Actions status.
```
