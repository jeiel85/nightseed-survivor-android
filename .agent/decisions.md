# Decisions

## 2026-05-13 — 런타임 스토리 연결

### Decision: 런타임 대사는 `StoryBanner` 비차단 자막 1종으로 통일

Reason:

- MVP의 "복잡한 컷신 제외" 원칙을 깨지 않으면서도 보스 등장과 클리어 같은 결정적 순간에 세계관을 노출할 수 있음.
- 모달 다이얼로그·풀스크린 컷신은 한 판 시간(약 7분) 흐름을 끊고 한 손 플레이 경험을 해침.
- 동일한 큐(StoryBanner)에 모든 대사를 흘려보내므로, 사운드/이펙트와 충돌하는 새 UI 레이어를 더 만들 필요가 없음.

### Decision: 스토리 데이터는 `data/story_dialogues.json` + `Story` autoload로 분리

Reason:

- 대사 문구를 GDScript 안에 하드코딩하면 번역·QA 사이클이 무겁다. JSON에 두면 비개발자도 안전하게 수정 가능.
- `Localization` autoload는 UI 골격용 키만 다루고, 스토리 대사는 별도 채널(Story)로 두어 책임을 나눔.
- 향후 스테이지/캐릭터별 추가 대사, 반복 힌트, 도감 잠금/해금을 같은 파일에서 확장하기 좋음.

## 2026-05-13

### Decision: 스토리 기반 작업은 `docs/story/`를 정식 기준으로 사용

Reason:

- 기존 저장소에는 `STORY_FINAL_SPEC.md`와 대사 통합 문서가 없어 패치 파일을 그대로 적용할 대상이 없음.
- 원본 패치 묶음은 출처 자료로 보존하고, 실제 개발 기준은 `docs/story/`의 정식 문서로 분리하는 편이 이후 구현과 검증에 명확함.
- MVP의 복잡한 컷신 제외 원칙을 유지하면서도 스테이지 설명과 짧은 UI 문구로 세계관을 반영할 수 있음.

### Decision: `story_terms.json`은 런타임 연결 전 기반 데이터로 추가

Reason:

- 향후 용어집, 도감, 툴팁 UI를 만들 때 문서 내용을 코드에 다시 하드코딩하지 않기 위함.
- 현재 단계에서는 저장 데이터 구조를 바꾸지 않으므로 마이그레이션 위험이 없음.

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

## 2026-05-07

### Decision: Milestone 1은 플러그인 없이 Godot 기본 기능으로 구현

Reason:

- 요구된 기능(이동, 추적 AI, 스폰, HUD, 게임오버)은 엔진 기본 노드와 GDScript로 충분히 구현 가능함.
- 외부 의존성을 추가하지 않으면 초기 안정성과 유지보수성이 높음.
- AGENTS.md 의존성 최소화 원칙과 일치함.

### Decision: Placeholder 시각은 `Visual` 하위 Polygon2D로 고정

Reason:

- 로직 노드와 시각 노드 분리를 구조적으로 강제할 수 있음.
- 이후 실제 Sprite2D/애니메이션으로 교체 시 충돌/이동 로직 영향을 줄일 수 있음.
