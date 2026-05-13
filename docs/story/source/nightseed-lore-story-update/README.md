# Nightseed Lore Story Update

이 묶음은 기존 Nightseed Survivor 스토리 설계서에 `Nightseed`의 의미를 명확히 보강하기 위한 업데이트 패키지입니다.

## 핵심 정의

```text
Nightseed = 밤의 씨앗
```

세계관 안에서의 의미:

```text
세계에 밤을 자라나게 만드는 봉인된 기억의 씨앗.
어둠 그 자체가 아니라, 잊힌 맹세와 기억이 뭉쳐 생긴 위험한 봉인의 핵.
```

## 포함 파일

```text
docs/STORY_NIGHTSEED_LORE.md
docs/STORY_FINAL_SPEC_NIGHTSEED_PATCH.md
docs/STORY_STAGE_DIALOGUE_NIGHTSEED_PATCH.md
docs/STORY_UI_COPY_NIGHTSEED_PATCH.md
godot/data/story_terms.json
prompts/STORY_LORE_PATCH_AGENT_PROMPT.md
```

## 적용 방식

1. `docs/STORY_NIGHTSEED_LORE.md`를 새 문서로 추가합니다.
2. 기존 `docs/STORY_FINAL_SPEC.md`에 `STORY_FINAL_SPEC_NIGHTSEED_PATCH.md` 내용을 반영합니다.
3. 기존 `docs/STORY_STAGE_INTEGRATION_GUIDE.md` 또는 `docs/STORY_DIALOGUE_EVENTS.md`에 `STORY_STAGE_DIALOGUE_NIGHTSEED_PATCH.md` 내용을 반영합니다.
4. UI 문구는 `STORY_UI_COPY_NIGHTSEED_PATCH.md` 기준으로 정리합니다.
5. 용어 데이터가 필요하면 `godot/data/story_terms.json`을 추가합니다.

## 추천 커밋 메시지

```text
docs: Nightseed 세계관 용어 정의 보강
```
