# Story Stage Dialogue

## 1. 목적

이 문서는 Nightseed의 의미를 스테이지 진행에 맞춰 단계적으로 공개하기 위한 대사 기준이다.

## 2. 대사 작성 원칙

Nightseed를 한 번에 전부 설명하지 않는다. 각 스테이지마다 한 조각씩 드러낸다.

| 스테이지 | 공개 정보 |
|---|---|
| Forest of Echoes | 이름만 등장 |
| Frozen Wastes | 맹세와 연결 |
| Twilight Sanctum | 봉인과 연결 |
| Inferno Chasm | 단순 파괴 불가 |
| Cursed Tomb | Vagrant의 잃어버린 이름과 연결 |

## 3. Forest of Echoes

Boss intro:

```text
Forest Warden: 밤의 씨앗은 아직 잠들어야 한다.
Vagrant: 그렇다면 왜 숲이 먼저 나를 불렀지?
```

확장 후보:

```text
Forest Warden: 씨앗은 흙이 아니라 기억 속에서 자란다.
Vagrant: 기억 속에서...?
```

## 4. Frozen Wastes

Boss intro:

```text
Frostbound Guard: 맹세를 잊은 자는 이 문을 넘지 못한다.
Vagrant: 맹세라... 내가 무엇을 지켰지?
```

확장 후보:

```text
Spirit Sister: 이 얼음은 물이 아니라 멈춘 약속이야.
Vagrant: 그래서 밤이 여기서 자랐군.
```

## 5. Twilight Sanctum

Boss intro:

```text
Twilight Keeper: 너는 봉인을 지킨 자이자, 연 자다.
Vagrant: 둘 다 사실일 수는 없다.
```

강한 반전 후보:

```text
Twilight Keeper: 밤의 씨앗은 문 안에 있지 않다. 네가 문이다.
Vagrant: ...내가?
```

이 대사는 최초 클리어 이후 힌트 또는 후반부 연출에 우선 사용한다.

## 6. Inferno Chasm

Boss intro:

```text
Ashen Guardian: 씨앗을 태우려 하지 마라. 깨어날 뿐이다.
Vagrant: 그럼 무엇을 해야 하지?
```

확장 후보:

```text
Pyromancer: 태울 수 없는 씨앗이라면, 비춰야 해.
Vagrant: 숨은 뿌리를 찾으라는 뜻인가.
```

## 7. Cursed Tomb

Boss intro:

```text
Last Warden: 너는 문을 닫은 마지막 기사였다.
Last Warden: 그리고 다시 열 수 있는 유일한 열쇠다.
```

Clear:

```text
Vagrant: 내가 지킨 건 세계였나, 아니면 진실이었나.
Unknown Voice: 밤의 씨앗은 아직 하나가 아니다.
```

확장 후보:

```text
Last Warden: 네 이름은 사라진 것이 아니다. 씨앗 안에 봉인되었다.
Vagrant: 그럼 내가 찾던 건 이름이 아니라 열쇠였군.
```

## 8. 반복 힌트 후보

```json
[
  {
    "id": "repeat_hint_nightseed_001",
    "trigger": "repeat_hint",
    "fallback_ko": "밤의 씨앗은 어둠이 아니라, 잊힌 맹세가 자라난 흔적이다.",
    "fallback_en": "The Nightseed is not darkness, but the growth of forgotten oaths."
  },
  {
    "id": "repeat_hint_nightseed_002",
    "trigger": "repeat_hint",
    "fallback_ko": "검의 금은 상처가 아니라, 봉인의 지도를 그리고 있다.",
    "fallback_en": "The cracks in the blade are not wounds. They are drawing the seal's map."
  },
  {
    "id": "repeat_hint_nightseed_003",
    "trigger": "repeat_hint",
    "fallback_ko": "이름을 잃은 자만이 이름을 봉인할 수 있었다.",
    "fallback_en": "Only one who lost a name could seal a name away."
  }
]
```
