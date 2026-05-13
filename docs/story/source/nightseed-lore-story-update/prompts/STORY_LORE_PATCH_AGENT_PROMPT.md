# STORY_LORE_PATCH_AGENT_PROMPT

```text
You are an autonomous coding agent working on Nightseed Survivor.

Goal:
Apply the Nightseed lore definition update to the existing story design documents.

Context:
Nightseed means "밤의 씨앗".
In the game world, it is not darkness itself and not a demonic or worship-related object.
It is the sealed core of forgotten oaths and memories, a dangerous seed that grows night across the world.

Tasks:

1. Add `docs/STORY_NIGHTSEED_LORE.md`.
2. Update `docs/STORY_FINAL_SPEC.md` with the Nightseed definition.
3. Update story dialogue documentation with the staged reveal:
   - Forest: the name "Nightseed" appears.
   - Frozen Wastes: it connects to forgotten oaths.
   - Twilight Sanctum: it connects to the seal.
   - Inferno Chasm: it cannot simply be burned or destroyed.
   - Cursed Tomb: it is tied to Vagrant's lost name.
4. Add optional `godot/data/story_terms.json` if glossary-style UI or future codex support is desired.
5. Do not add demon worship, sacrificial rituals, blasphemy, or religious mockery.
6. Keep all copy short and mobile-friendly.
7. Update HISTORY.md and .agent/progress.md.

Recommended commit message:
docs: Nightseed 세계관 용어 정의 보강
```
