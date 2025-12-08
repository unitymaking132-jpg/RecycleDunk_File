# Recycle Dunk - Unity Setup Guide

**프로젝트명**: Recycle Dunk
**Unity 버전**: 2022.3 LTS 이상 권장
**최종 수정일**: 2025-12-08

---

## 1. 프로젝트 초기 설정

### 1.1 필수 패키지 확인

Package Manager에서 다음 패키지가 설치되어 있는지 확인:

```
com.unity.xr.management: 4.5.0+
com.unity.xr.openxr: 1.14.0+
com.unity.xr.hands: 1.5.0+
com.unity.xr.interaction.toolkit: 3.0.7+
com.unity.render-pipelines.universal: 17.0.4+
com.unity.inputsystem: 1.13.1+
com.unity.timeline: 1.8.7+
```

### 1.2 VIVEN SDK 확인

`TwentyOz/VivenSDK` 폴더가 프로젝트에 포함되어 있는지 확인합니다.

---

## 2. 폴더 구조 생성

### 2.1 수동으로 생성해야 할 폴더

Unity Project 창에서 다음 폴더를 생성합니다:

```
Assets/Recycle Dunk/
├── Scripts/
│   ├── Manager/
│   ├── Objects/
│   ├── UI/
│   └── Utils/
├── Prefabs/
│   ├── Trash/
│   │   ├── Paper/
│   │   ├── Plastic/
│   │   ├── Glass/
│   │   └── Metal/
│   ├── Bins/
│   └── UI/
├── Materials/
├── Audio/
│   ├── BGM/
│   └── SFX/
├── Scenes/
└── Docs/
```

### 2.2 폴더 생성 방법

1. **Assets 폴더**에서 우클릭 → `Create` → `Folder`
2. `Recycle Dunk` 폴더 생성
3. 하위 폴더들을 순차적으로 생성

---

## 3. 씬 설정

### 3.1 새 씬 생성

1. `File` → `New Scene`
2. `File` → `Save As` → `Assets/Recycle Dunk/Scenes/RecycleDunk.unity`

### 3.2 기본 씬 구조

Hierarchy에 다음 구조로 게임 오브젝트를 생성합니다:

```
RecycleDunk (Scene)
├── --- ENVIRONMENT ---
│   ├── Skybox (우주 배경)
│   ├── Earth (지구 모델)
│   ├── DirectionalLight
│   └── Boundary (경계 영역)
│
├── --- MANAGERS ---
│   ├── GameManager
│   │   └── [VivenLuaBehaviour: GameManager.lua]
│   ├── SpawnManager
│   │   └── [VivenLuaBehaviour: SpawnManager.lua]
│   ├── ScoreManager
│   │   └── [VivenLuaBehaviour: ScoreManager.lua]
│   └── AudioManager
│       └── [VivenLuaBehaviour: AudioManager.lua]
│
├── --- GAMEPLAY ---
│   ├── TrashBins
│   │   ├── PaperBin (파란색)
│   │   ├── PlasticBin (빨간색)
│   │   ├── GlassBin (초록색)
│   │   └── MetalBin (노란색)
│   └── SpawnPoints
│       └── (쓰레기 스폰 위치들)
│
├── --- UI ---
│   ├── SlideUI (Canvas - World Space)
│   ├── LandingUI (Canvas - World Space)
│   ├── LevelSelectUI (Canvas - World Space)
│   ├── GameHUD (Canvas - World Space)
│   └── ResultUI (Canvas - World Space)
│
└── --- VIVEN ---
    └── VivenSystemPrefab (VIVEN SDK 기본 프리팹)
```

### 3.3 구분선 오브젝트 생성 (선택)

가독성을 위해 빈 GameObject를 생성하고 `--- CATEGORY ---` 형식으로 이름을 지정합니다.

---

## 4. 매니저 오브젝트 설정

### 4.1 GameManager 설정

1. **빈 GameObject 생성**: `GameManager`
2. **컴포넌트 추가**:
   - `VObject` 컴포넌트 추가
   - `VivenLuaBehaviour` 컴포넌트 추가
3. **VivenLuaBehaviour 설정**:
   - `Lua Script`: `Assets/Recycle Dunk/Scripts/Manager/GameManager.lua`
4. **인스펙터에서 의존성 주입 필드 연결** (스크립트 작성 후):
   - SpawnManager, ScoreManager, AudioManager 연결
   - UI Manager들 연결

### 4.2 SpawnManager 설정

1. **빈 GameObject 생성**: `SpawnManager`
2. **컴포넌트 추가**:
   - `VObject` 컴포넌트 추가
   - `VivenLuaBehaviour` 컴포넌트 추가
3. **VivenLuaBehaviour 설정**:
   - `Lua Script`: `Assets/Recycle Dunk/Scripts/Manager/SpawnManager.lua`
4. **SpawnPoints 설정**:
   - 여러 개의 빈 GameObject를 SpawnPoints 아래에 생성
   - 각각 플레이어 앞 적절한 위치에 배치

### 4.3 ScoreManager 설정

1. **빈 GameObject 생성**: `ScoreManager`
2. **컴포넌트 추가**:
   - `VObject` 컴포넌트 추가
   - `VivenLuaBehaviour` 컴포넌트 추가
3. **VivenLuaBehaviour 설정**:
   - `Lua Script`: `Assets/Recycle Dunk/Scripts/Manager/ScoreManager.lua`

---

## 5. 쓰레기통 (TrashBin) 설정

### 5.1 쓰레기통 프리팹 생성

각 카테고리별로 쓰레기통 프리팹을 생성합니다:

1. **기본 구조 생성**:
   - 빈 GameObject 생성: `PaperBin`
   - 자식으로 쓰레기통 3D 모델 추가
   - Collider 추가 (Box 또는 Mesh)

2. **컴포넌트 추가**:
   - `VObject` 컴포넌트
   - `VivenLuaBehaviour` 컴포넌트 (TrashBin.lua)
   - `Collider` (Is Trigger 체크)

3. **VObject 설정**:
   - `Object ID`: 자동 생성
   - `Content Type`: Prepared
   - `Object Sync Type`: None (정적 오브젝트)

4. **TrashBin.lua 의존성 주입**:
   - `binCategory`: "Paper" (또는 Plastic, Glass, Metal)

5. **프리팹으로 저장**:
   - `Assets/Recycle Dunk/Prefabs/Bins/PaperBin.prefab`

6. **나머지 3개도 동일하게 생성**:
   - PlasticBin (빨간색)
   - GlassBin (초록색)
   - MetalBin (노란색)

### 5.2 쓰레기통 배치

이미지 참고에 따라 지구 주변에 4개의 쓰레기통을 배치합니다:
- 상단: Paper (파란색)
- 좌측: Plastic (빨간색)
- 하단: Glass (초록색)
- 우측: Metal (노란색)

---

## 6. 쓰레기 아이템 (TrashItem) 프리팹 설정

### 6.1 쓰레기 프리팹 생성 절차

1. **빈 GameObject 생성**: `PaperTrash_Newspaper`
2. **자식으로 3D 모델 추가**: 신문지 모델

3. **컴포넌트 추가** (부모 오브젝트에):
   ```
   - VObject
   - VivenGrabbableModule
   - VivenRigidbodyControlModule
   - VivenGrabbableRigidView
   - VivenLuaBehaviour (TrashItem.lua)
   - Rigidbody (Use Gravity: false)
   - Collider
   ```

4. **VObject 설정**:
   - `Content Type`: Prepared
   - `Object Sync Type`: Continuous

5. **VivenGrabbableModule 설정**:
   - 기본 설정 유지

6. **VivenRigidbodyControlModule 설정**:
   - 기본 설정 유지
   - Use Gravity: 비활성화 (무중력 효과)

7. **TrashItem.lua 의존성 주입**:
   - `trashCategory`: "Paper"

8. **프리팹 저장**:
   - `Assets/Recycle Dunk/Prefabs/Trash/Paper/PaperTrash_Newspaper.prefab`

### 6.2 카테고리별 쓰레기 아이템 목록

| 카테고리 | 아이템 예시 |
|---------|------------|
| Paper | 신문지, 상자, 종이컵, 노트 |
| Plastic | 페트병, 플라스틱 용기, 빨대 |
| Glass | 유리병, 유리컵, 유리 조각 |
| Metal | 캔, 알루미늄 용기, 병뚜껑 |

---

## 7. UI 설정

### 7.1 World Space Canvas 생성

모든 UI는 World Space Canvas로 생성합니다:

1. **Canvas 생성**: `GameObject` → `UI` → `Canvas`
2. **Canvas 설정**:
   - `Render Mode`: World Space
   - `Event Camera`: XR Camera 연결
   - `Scale`: (0.001, 0.001, 0.001) 또는 적절한 크기

3. **VivenUIPointerEvents 추가** (VR 상호작용용)

### 7.2 SlideUI 설정

```
SlideUI (Canvas - World Space)
├── Background (Image)
├── SlideContainer
│   ├── Slide1 (Image + Text)
│   ├── Slide2 (Image + Text)
│   ├── Slide3 (Image + Text)
│   └── Slide4 (Image + Text)
├── Navigation
│   ├── PrevButton (Button)
│   ├── NextButton (Button)
│   └── Indicators (HorizontalLayoutGroup)
│       ├── Dot1
│       ├── Dot2
│       ├── Dot3
│       └── Dot4
└── [VivenLuaBehaviour: SlideUIManager.lua]
```

### 7.3 LandingUI 설정

```
LandingUI (Canvas - World Space)
├── Background (Image)
├── Logo (Image)
├── Buttons
│   ├── HowToPlayButton (Button)
│   └── GameStartButton (Button)
└── [VivenLuaBehaviour: LandingUIManager.lua]
```

### 7.4 GameHUD 설정

```
GameHUD (Canvas - World Space)
├── TimerPanel
│   └── TimerText (TextMeshPro)
├── HPPanel
│   ├── HPBar (Image - Filled)
│   └── HPText (TextMeshPro)
└── [VivenLuaBehaviour: GameHUD.lua]
```

### 7.5 ResultUI 설정

```
ResultUI (Canvas - World Space)
├── Background (Image)
├── Title (TextMeshPro - "GAME OVER")
├── ScorePanel
│   ├── ScoreLabel (TextMeshPro)
│   └── ScoreValue (TextMeshPro)
├── AccuracyPanel
│   ├── AccuracyLabel (TextMeshPro)
│   └── AccuracyValue (TextMeshPro)
├── MostMissedPanel
│   ├── MostMissedLabel (TextMeshPro)
│   └── MostMissedValue (TextMeshPro)
├── Buttons
│   ├── RetryButton (Button)
│   └── MainMenuButton (Button)
└── [VivenLuaBehaviour: ResultUIManager.lua]
```

---

## 8. 경계 영역 (Boundary) 설정

### 8.1 Boundary Zone 설정

1. **빈 GameObject 생성**: `Boundary`
2. **Sphere Collider 추가**:
   - `Is Trigger`: 체크
   - `Radius`: 충분히 큰 값 (예: 10)
3. **VivenLuaBehaviour 추가**: `BoundaryZone.lua`

쓰레기가 이 Sphere Collider를 벗어나면 (OnTriggerExit) HP 감소 이벤트 발생

---

## 9. Lua 스크립트 연결

### 9.1 스크립트 파일 위치

Unity에서 Lua 스크립트를 연결할 때 경로:

```
Assets/Recycle Dunk/Scripts/Manager/GameManager.lua
Assets/Recycle Dunk/Scripts/Manager/SpawnManager.lua
Assets/Recycle Dunk/Scripts/Manager/ScoreManager.lua
Assets/Recycle Dunk/Scripts/Manager/AudioManager.lua
Assets/Recycle Dunk/Scripts/Objects/TrashItem.lua
Assets/Recycle Dunk/Scripts/Objects/TrashBin.lua
Assets/Recycle Dunk/Scripts/Objects/BoundaryZone.lua
Assets/Recycle Dunk/Scripts/Objects/FloatingBehavior.lua
Assets/Recycle Dunk/Scripts/UI/SlideUIManager.lua
Assets/Recycle Dunk/Scripts/UI/LandingUIManager.lua
Assets/Recycle Dunk/Scripts/UI/LevelSelectUI.lua
Assets/Recycle Dunk/Scripts/UI/GameHUD.lua
Assets/Recycle Dunk/Scripts/UI/ResultUIManager.lua
Assets/Recycle Dunk/Scripts/Utils/EventCallback.lua
Assets/Recycle Dunk/Scripts/Utils/Definitions.def.lua
```

### 9.2 VivenLuaBehaviour 의존성 주입

VivenLuaBehaviour 컴포넌트의 인스펙터에서:

1. **Lua Script** 필드에 해당 .lua 파일 드래그
2. **Script Variables** 섹션에서 의존성 주입 필드 확인
3. 각 필드에 해당하는 GameObject 연결

예시 (GameManager.lua):
```
Script Variables:
├── SpawnManagerObject: SpawnManager (GameObject)
├── ScoreManagerObject: ScoreManager (GameObject)
├── AudioManagerObject: AudioManager (GameObject)
├── SlideUIObject: SlideUI (Canvas)
├── LandingUIObject: LandingUI (Canvas)
├── LevelSelectUIObject: LevelSelectUI (Canvas)
├── GameHUDObject: GameHUD (Canvas)
└── ResultUIObject: ResultUI (Canvas)
```

---

## 10. 테스트 실행

### 10.1 에디터에서 테스트

1. **Play Mode 진입**: `Ctrl + P`
2. **VR 시뮬레이터** 또는 **연결된 VR 헤드셋**으로 테스트

### 10.2 체크리스트

- [ ] 가이드 UI 슬라이드가 정상 동작하는가?
- [ ] 랜딩 UI 버튼이 클릭되는가?
- [ ] 게임 시작 시 쓰레기가 스폰되는가?
- [ ] 쓰레기가 무중력으로 떠다니는가?
- [ ] 쓰레기를 잡고 던질 수 있는가?
- [ ] 쓰레기통에 들어가면 판정이 되는가?
- [ ] HP와 타이머가 정상 표시되는가?
- [ ] 게임 오버 시 결과 UI가 표시되는가?

---

## 11. 빌드 설정

### 11.1 빌드 세팅

`File` → `Build Settings`:
- **Platform**: Android (Quest) 또는 Windows (PC VR)
- **Scenes In Build**: `Assets/Recycle Dunk/Scenes/RecycleDunk.unity` 추가

### 11.2 Player Settings

`Edit` → `Project Settings` → `Player`:
- **Company Name**: 설정
- **Product Name**: Recycle Dunk
- **XR Settings**: OpenXR 활성화

---

## 12. 트러블슈팅

### 12.1 일반적인 문제

| 문제 | 원인 | 해결 방법 |
|------|------|----------|
| Lua 스크립트가 실행되지 않음 | VivenLuaBehaviour 미연결 | 스크립트 파일 다시 연결 |
| 의존성 주입 오류 | checkInject 실패 | 인스펙터에서 모든 필드 연결 확인 |
| UI 클릭 안됨 | EventCamera 미설정 | Canvas의 Event Camera 연결 |
| 쓰레기 잡기 안됨 | VivenGrabbableModule 설정 오류 | 컴포넌트 설정 확인 |
| 물리 동작 이상 | Rigidbody 설정 오류 | Use Gravity, Constraints 확인 |

### 12.2 콘솔 에러 확인

Unity Console에서 `[Lua]` 또는 `Viven` 관련 에러 확인

---

## 13. 참고 자료

### VIVEN SDK 문서
- Wiki: https://wiki.viven.app/developer
- API Reference: https://sdkdoc.viven.app/api/SDK/TwentyOz.VivenSDK
- VObject 가이드: https://wiki.viven.app/developer/contents/vobject
- Grabbable 가이드: https://wiki.viven.app/developer/contents/grabbable
- Scripting 가이드: https://wiki.viven.app/developer/dev-guide/viven-script

### 기존 프로젝트 참고
- Angames: `D:\workspace\cooking\Assets\Angames`
- Fantasia: `D:\workspace\Wemeet\2025-xr-pbl-1\Assets\Fantasia`

---

## 부록: 컴포넌트 조합 요약

### Grabbable 쓰레기 아이템
```
Required Components:
├── VObject
├── VivenGrabbableModule
├── VivenRigidbodyControlModule
├── VivenGrabbableRigidView
├── VivenLuaBehaviour
├── Rigidbody (Use Gravity: false)
└── Collider
```

### 정적 쓰레기통
```
Required Components:
├── VObject
├── VivenLuaBehaviour
└── Collider (Is Trigger: true)
```

### World Space UI
```
Required Components:
├── Canvas (Render Mode: World Space)
├── VivenUIPointerEvents
└── VivenLuaBehaviour
```
