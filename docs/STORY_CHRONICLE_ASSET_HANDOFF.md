# Story Chronicle Asset Handoff

작성일: 2026-05-19

이 문서는 StoryUI 고대 장부 리디자인의 이미지 자산 적용을 다음 세션에서 이어가기 위한 인수인계 메모다.

## 기준 문서

- 디자인 가이드 원본: `D:\Project\story-design-guide\REDESIGN_GUIDE.md`
- 자산 생성 프롬프트: `docs/ASSETS_TO_GENERATE.md` §2.1
- UI 구성 계획: `docs/UI_REDESIGN_SPEC.md` §5.9, §6.7

## 현재 준비된 ST-P0 자산

아래 4개는 사용자가 ChatGPT로 생성한 뒤 다운로드 폴더에 둔 크로마키 버전을 후처리해 저장소에 배치한 파일이다.

| ID | 파일 | 목표 크기 | 용도 |
|---|---|---:|---|
| ST-PANEL-01 | `godot/assets/sprites/ui/story/panel_story_parchment.9.png` | 192×224 | 해금 스토리 카드 양피지 패널 |
| ST-PANEL-02 | `godot/assets/sprites/ui/story/panel_story_locked.9.png` | 192×224 | 잠금 스토리 카드 석판/봉인 패널 |
| ST-DIV-01 | `godot/assets/sprites/ui/story/divider_story_diamond.png` | 512×32 | 섹션 구분 장식선 |
| ST-LOCK-01 | `godot/assets/sprites/ui/story/icon_story_lock.png` | 96×96 | 잠금 카드 중앙 lock 아이콘 |

같은 폴더에 Godot `.import` 파일도 생성되어 있다.

```text
godot/assets/sprites/ui/story/
  divider_story_diamond.png
  divider_story_diamond.png.import
  icon_story_lock.png
  icon_story_lock.png.import
  panel_story_locked.9.png
  panel_story_locked.9.png.import
  panel_story_parchment.9.png
  panel_story_parchment.9.png.import
```

## 후처리 기록

다운로드 원본은 실제 투명 PNG가 아니라 녹색 크로마키 배경이었다.

처리 내용:

- 강한 녹색 배경 threshold 제거
- 가장자리 olive/green spill 추가 제거
- 목표 크기로 nearest-neighbor 리사이즈
- 패널은 target canvas를 채우도록 crop/resize
- lock은 비율 유지 후 96×96 중앙 배치

검사 결과:

```text
divider_story_diamond.png: corner alpha 0, chroma green leftover 0
icon_story_lock.png: corner alpha 0, chroma green leftover 0
panel_story_locked.9.png: corner alpha 0, chroma green leftover 0
panel_story_parchment.9.png: corner alpha 0, chroma green leftover 0
```

## 현재 코드 연결 상태

`godot/scripts/ui/StoryUI.gd`에는 이미 texture fallback 연결이 들어가 있다.

연결 방식:

- `ResourceLoader.exists()`로 자산 존재 확인
- 패널: `StyleBoxTexture`
- divider: `TextureRect`
- lock: `TextureRect` + 기존 `LOCKED` 라벨 유지
- 자산이 없으면 기존 코드 기반 `StyleBoxFlat` / 동적 divider fallback 사용

관련 상수:

```gdscript
const STORY_PARCHMENT_PATH := "res://assets/sprites/ui/story/panel_story_parchment.9.png"
const STORY_LOCKED_PATH := "res://assets/sprites/ui/story/panel_story_locked.9.png"
const STORY_DIVIDER_PATH := "res://assets/sprites/ui/story/divider_story_diamond.png"
const STORY_LOCK_ICON_PATH := "res://assets/sprites/ui/story/icon_story_lock.png"
const STORY_PANEL_MARGIN := 24
```

## 다음 세션 작업 계획

1. Godot 에디터 또는 실기 빌드에서 StoryUI 실제 화면 확인
2. 카드 9-slice가 찌그러지면 `STORY_PANEL_MARGIN`을 20~32 범위에서 조정
3. divider가 너무 두껍거나 잘리면 `TextureRect.custom_minimum_size.y`를 20~32 범위에서 조정
4. lock 아이콘이 크면 `_add_locked_body()`의 `custom_minimum_size = Vector2(88, 88)` 조정
5. 720×1280 / 540×960, 한국어 / 영어 모두 스크롤과 줄바꿈 확인
6. 확인 후 StoryUI 변경분과 자산을 한 커밋으로 정리

## 주의 사항

- 현재 저장소에는 StoryUI 외에도 기존 unstaged 변경이 많다. 커밋 전 반드시 `git diff --stat`와 파일별 diff를 확인해 StoryUI 작업 범위만 분리한다.
- 다운로드 원본 파일은 저장소 기준 자료가 아니며, 최종 기준은 `godot/assets/sprites/ui/story/`의 후처리된 PNG다.
- ChatGPT가 투명 배경을 계속 실패하면 `docs/ASSETS_TO_GENERATE.md`의 크로마키 우회 프롬프트를 사용한다.
