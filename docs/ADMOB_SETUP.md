# AdMob Rewarded Ads — Setup Guide

`Nightseed Survivor`는 보상형(rewarded) 광고만 사용합니다. 정책상 가장 안전하고,
[COMMERCIALIZATION_ANALYSIS.md](COMMERCIALIZATION_ANALYSIS.md) §5.4 권고에도
부합합니다. 일반(non-rewarded) 전면 광고, 배너, 자동 광고는 사용하지 않습니다.

코드는 이미 보상형 SDK 통합을 가정한 인터페이스로 작성되어 있고,
**`AdManager.ENABLED = false`** 상태이므로 광고 CTA는 빌드에서 숨겨집니다.
아래 단계를 모두 끝낸 뒤 `ENABLED`를 `true`로 바꾸면 광고가 활성화됩니다.

소요 시간: 약 60-90분 (대부분 AdMob 콘솔 + Android plugin 의존성 정리)

---

## 사전 정보

| 항목 | 값 |
|---|---|
| 패키지명 | `com.nightseed.survivor` |
| 광고 형식 | Rewarded Ad (1종) |
| 사용 위치 | (1) 사망 시 부활 — 1회/run, (2) 결과 화면 골드 2배 — 1회/run |
| Godot 버전 | 4.x |
| 광고 SDK | Google Mobile Ads SDK (AdMob) |

---

## Step 1 — AdMob 콘솔에 앱 등록

1. https://admob.google.com → **앱 → 앱 만들기**
2. 플랫폼: **Android**, "Google Play에 등록된 앱입니까?": **예**
3. **앱 이름 검색**: `Nightseed Survivor` → 선택 (Play Console에 이미 등록되어 있어야 함)
4. 등록 완료 후 **앱 설정** 페이지의 **앱 ID** 복사 — 형식: `ca-app-pub-XXXXXXXXXXXXXXXX~YYYYYYYYYY` (물결 `~`)

---

## Step 2 — 보상형 광고 단위 만들기

1. AdMob → 좌측 메뉴 **앱 → Nightseed Survivor → 광고 단위 → 광고 단위 추가**
2. **보상형 광고 (Rewarded)** 선택
3. **광고 단위 이름**: `Rewarded — Revive & Double Gold`
4. **보상**: `Reward` × 1 (이름과 수량은 표시되지 않지만 보고서엔 남음)
5. 생성 완료 후 **광고 단위 ID** 복사 — 형식: `ca-app-pub-XXXXXXXXXXXXXXXX/ZZZZZZZZZZ` (슬래시 `/`)

---

## Step 3 — Godot용 AdMob 플러그인 추가

코드는 `AdManager.gd`에서 `Engine.has_singleton("AdMob")` 패턴으로 Android 싱글톤을 찾습니다.
공식적으로 권장되는 두 플러그인 중 하나를 선택:

| 플러그인 | 저장소 | 비고 |
|---|---|---|
| **Poing Studios godot-admob-android** | https://github.com/PoingStudios/godot-admob-android | Godot 4.x 지원, 가장 활발 |
| Cengiz-pz Godot-Admob-Plugin | https://github.com/cengiz-pz/godot-android-admob-plugin | 대안 |

설치 흐름 (Poing Studios 기준):
1. Releases에서 최신 .zip 다운로드 (예: `godot-admob-android-vX.Y.Z.zip`)
2. 풀어서 `addons/PoingGodotAdMob/` 폴더를 프로젝트 `godot/addons/` 아래로 복사
3. `godot/export_presets.cfg` Android 프리셋의 `plugins/`에 플러그인 활성화 추가 (Godot 에디터 → Export → Android → Plugins 탭에서 체크)
4. AndroidManifest.xml 에 다음 meta-data 추가 — **Godot에서는 export_plugin이 자동 주입하는 경우가 많음**, 안 되면 `godot/android/build/AndroidManifest.xml` 의 `<application>` 안에 수동 추가:
   ```xml
   <meta-data
       android:name="com.google.android.gms.ads.APPLICATION_ID"
       android:value="ca-app-pub-XXXXXXXXXXXXXXXX~YYYYYYYYYY"/>
   ```

---

## Step 4 — proguard-rules.pro 에 AdMob keep 규칙 추가

R8이 활성화되어 있으므로 ([godot/android/build/proguard-rules.pro](../godot/android/build/proguard-rules.pro))
다음 규칙을 파일 끝에 추가:

```
# Google Mobile Ads (AdMob)
-keep class com.google.android.gms.ads.** { *; }
-keep class com.google.ads.** { *; }
-keep class com.google.android.gms.internal.ads.** { *; }
-dontwarn com.google.android.gms.ads.**
```

---

## Step 5 — `AdManager.gd` 에 ID 꽂아넣기

[godot/scripts/core/AdManager.gd](../godot/scripts/core/AdManager.gd) 상단:

```gdscript
const ENABLED: bool = true   # ← false 에서 true 로
const ADMOB_APP_ID: String = "ca-app-pub-XXXXXXXXXXXXXXXX~YYYYYYYYYY"
const REWARDED_UNIT_ID: String = "ca-app-pub-XXXXXXXXXXXXXXXX/ZZZZZZZZZZ"
```

그리고 `_init_plugin()` 안의 주석 처리된 `Engine.get_singleton("AdMob")` 블록을
선택한 플러그인의 실제 API에 맞게 활성화 (플러그인마다 메서드/시그널 이름이 다를 수 있음).

---

## Step 6 — Google 테스트 광고로 검증

⚠ **실제 광고 ID로 직접 테스트하면 AdMob 계정이 정지될 수 있습니다.**

개발 중에는 Google 공식 테스트 광고 단위 ID를 사용:
- Rewarded 테스트: `ca-app-pub-3940256099942544/5224354917`

`AdManager.REWARDED_UNIT_ID` 를 일시적으로 위 값으로 바꿔 빌드 → 내부 테스트 트랙 업로드 →
폰에서 **사망 후 "부활하기 (광고 시청)"**, **결과 화면 "골드 2배 (광고 시청)"** 버튼이
보이는지 / 광고가 재생되는지 / 보상이 적용되는지 검증.

검증이 끝나면 위 ID를 다시 실제 광고 단위 ID로 교체하고 릴리즈 빌드.

---

## Step 7 — Play Console 광고 표시

Play Console → 앱 → 정책 및 프로그램 → 광고 → **"앱에 광고가 있나요?"** → **예** 선택.
스토어 등록정보에 "광고 포함" 배지가 표시됩니다.

---

## 🎯 마지막 — 저한테 보내주실 정보

콘솔 작업 끝나면 다음 2개만 알려주세요:

```
ADMOB_APP_ID     = ca-app-pub-XXXXXXXXXXXXXXXX~YYYYYYYYYY   (Step 1)
REWARDED_UNIT_ID = ca-app-pub-XXXXXXXXXXXXXXXX/ZZZZZZZZZZ   (Step 2)
```

받으면 Step 5의 상수와 `_init_plugin()` 의 실제 SDK 호출 블록을 활성화하고
ENABLED=true 로 전환합니다. (Step 3~4의 플러그인 설치는 .aar 의존성 추가가
필요해 별도 commit으로 진행 — IDE에서 .aar 파일을 직접 받아 `addons/`에
넣어야 함)

---

## 동작 개요 (참고)

| 상황 | 광고 CTA | 보상 | 1회/run 한도 |
|---|---|---|---|
| 사망 후 결과 화면 | "부활하기 (광고 시청)" | HP 50% 회복 + 무적 3초 + 가까운 적 제거 → 게임 재개 | ✅ |
| 사망/승리 후 결과 화면 | "골드 2배 (광고 시청)" | 이번 판 골드 × 2 (count-up + 다음 목표 라인도 즉시 갱신) | ✅ |

광고가 로드되지 않았거나 SDK가 비활성화 상태이면 두 버튼 모두 숨김.
부활을 한 번 사용한 뒤 다시 사망해도 부활 버튼은 더 이상 나타나지 않음.
