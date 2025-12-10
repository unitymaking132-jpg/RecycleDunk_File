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
│   │   ├── MetalBin (노란색)
│   │   └── GeneralGarbageBin (회색/검정)
│   └── SpawnZone (BoxCollider - 스폰 영역)
│
├── --- UI ---
│   └── MainCanvas (Canvas - World Space)
│       ├── SlideUIPanel
│       ├── LandingUIPanel
│       ├── LevelSelectUIPanel
│       ├── GameHUDPanel
│       ├── GameOverUIPanel
│       └── ResultUIPanel
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

4. **SpawnZone 설정**:
   - 빈 GameObject 생성: `SpawnZone`
   - `BoxCollider` 컴포넌트 추가
   - `Is Trigger`: 체크
   - 콜라이더 크기를 쓰레기 스폰 영역에 맞게 조절

5. **SpawnManager 의존성 주입** (Script Variables):
   ```
   ├── SpawnZoneObject: SpawnZone (GameObject)
   │
   ├── PaperPrefab1: Trash_Paper_01 (Prefab)
   ├── PaperPrefab2: Trash_Paper_02 (Prefab)
   ├── PaperPrefab3: Trash_Paper_03 (Prefab)
   │
   ├── PlasticPrefab1: Trash_Plastic_01 (Prefab)
   ├── PlasticPrefab2: Trash_Plastic_02 (Prefab)
   ├── PlasticPrefab3: Trash_Plastic_03 (Prefab)
   │
   ├── GlassPrefab1: Trash_Glass_01 (Prefab)
   ├── GlassPrefab2: Trash_Glass_02 (Prefab)
   │
   ├── MetalPrefab1: Trash_Metal_Can01 (Prefab)
   ├── MetalPrefab2: Trash_Metal_Can02 (Prefab)
   │
   ├── GeneralGarbagePrefab1: Trash_Misc_CrackedEgg (Prefab)
   │
   └── ScoreManagerObject: ScoreManager (GameObject)
   ```

> **참고**:
> - VIVEN SDK의 의존성 주입은 배열을 지원하지 않아 개별 필드로 주입합니다.
> - 쓰레기는 BoxCollider의 bounds 내 랜덤 위치에 스폰됩니다.
> - 각 프리팹 필드는 Nullable이므로 비어있어도 에러가 나지 않지만, 해당 슬롯은 스폰 풀에서 제외됩니다.

---

## 4.5 쓰레기 프리팹 설정 (TrashItem Prefab)

### 4.5.1 프리팹 구조

각 쓰레기 프리팹은 다음 컴포넌트가 필요합니다:

```
Trash_[Category]_[Name] (Prefab Root)
├── VObject
├── VivenGrabbableModule
├── VivenRigidbodyControlModule
├── VivenGrabbableRigidView
├── VivenLuaBehaviour (TrashItem.lua)
├── VivenLuaBehaviour (FloatingBehavior.lua) [선택]
├── Rigidbody (Use Gravity: false)
└── Collider (Box/Mesh/Capsule)
```

### 4.5.2 TrashItem.lua 의존성 주입

```
Script Variables:
├── TrashCategory: "Paper" | "Plastic" | "Glass" | "Metal" | "GeneralGarbage"
└── ScoreManagerObject: ScoreManager (GameObject) [선택]
```

**TrashCategory 값**:
| 프리팹 폴더 | TrashCategory 값 |
|------------|------------------|
| Prefabs/Trash/Paper/ | "Paper" |
| Prefabs/Trash/Plastic/ | "Plastic" |
| Prefabs/Trash/Glass/ | "Glass" |
| Prefabs/Trash/Metal/ | "Metal" |
| Prefabs/Trash/Misc/ | "GeneralGarbage" |

### 4.5.3 프리팹 생성 절차

1. **3D 모델 준비**: 쓰레기 모델 임포트
2. **빈 GameObject 생성**: `Trash_Paper_01` 형식으로 이름 지정
3. **3D 모델을 자식으로 추가**

4. **컴포넌트 추가** (부모 오브젝트에):
   - `VObject` 추가
   - `Rigidbody` 추가 → `Use Gravity`: **false** (무중력)
   - `Collider` 추가 (모델에 맞는 타입)
   - `VivenGrabbableModule` 추가
   - `VivenRigidbodyControlModule` 추가
   - `VivenGrabbableRigidView` 추가
   - `VivenLuaBehaviour` 추가 → `TrashItem.lua` 연결

5. **VObject 설정**:
   - `Content Type`: Prepared
   - `Object Sync Type`: Continuous

6. **VivenRigidbodyControlModule 설정**:
   - `Use Gravity`: **비활성화** (무중력 효과)

7. **TrashItem.lua 의존성 주입**:
   - `TrashCategory`: 해당 카테고리 문자열 입력 (예: "Paper")
   - `ScoreManagerObject`: 비워두기 (런타임에 SpawnManager가 처리)

8. **프리팹 저장**:
   - `Assets/Recycle Dunk/Prefabs/Trash/[Category]/Trash_[Category]_[Name].prefab`

### 4.5.4 FloatingBehavior 추가 (선택)

무중력 공간에서 자연스러운 떠다니기 효과:

1. `VivenLuaBehaviour` 컴포넌트 추가
2. `Lua Script`: `FloatingBehavior.lua` 연결
3. 별도 의존성 주입 없음 (기본값 사용)

### 4.5.5 현재 프리팹 목록

```
Assets/Recycle Dunk/Prefabs/Trash/
├── Paper/
│   ├── Trash_Paper_01.prefab
│   ├── Trash_Paper_02.prefab
│   └── Trash_Paper_03.prefab
├── Plastic/
│   ├── Trash_Plastic_01.prefab
│   ├── Trash_Plastic_02.prefab
│   └── Trash_Plastic_03.prefab
├── Glass/
│   ├── Trash_Glass_01.prefab
│   └── Trash_Glass_02.prefab
├── Metal/
│   ├── Trash_Metal_Can01.prefab
│   └── Trash_Metal_Can02.prefab
└── Misc/
    └── Trash_Misc_CrackedEgg.prefab
```

> **주의**: Glass 폴더의 프리팹 이름이 `Trash_Galss_01.prefab`으로 오타가 있습니다. `Trash_Glass_01.prefab`으로 수정 권장.

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

6. **나머지 4개도 동일하게 생성**:
   - PlasticBin (빨간색)
   - GlassBin (초록색)
   - MetalBin (노란색)
   - GeneralGarbageBin (회색/검정)

### 5.2 쓰레기통 배치

지구 주변에 5개의 쓰레기통을 배치합니다:
- Paper (파란색)
- Plastic (빨간색)
- Glass (초록색)
- Metal (노란색)
- GeneralGarbage (회색/검정)

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
| GeneralGarbage | 음식물 묻은 용기, 복합 재질, 오염된 종이 |

---

## 7. UI 설정

### 7.1 단일 Canvas + 다중 Panel 구조

**단일 Canvas**에 **모든 UI Panel**을 배치하고, GameManager가 상태에 따라 Panel을 켜고 끄는 방식입니다.

1. **MainCanvas 생성**: `GameObject` → `UI` → `Canvas`
2. **Canvas 설정**:
   - `Render Mode`: World Space
   - `Event Camera`: XR Camera 연결
   - `Scale`: (0.001, 0.001, 0.001) 또는 적절한 크기

3. **VivenUIPointerEvents 추가** (VR 상호작용용)

4. **Canvas 하위에 Panel들 생성**:
   - 각 Panel에 해당 `VivenLuaBehaviour` 컴포넌트 부착

```
MainCanvas (Canvas - World Space)
├── [VivenUIPointerEvents]
│
├── SlideUIPanel (Panel)
│   ├── [VivenLuaBehaviour: SlideUIManager.lua]
│   ├── Background (Image)
│   ├── Slide1 (Image + Text)
│   ├── Slide2 (Image + Text)
│   ├── Slide3 (Image + Text)
│   ├── PrevButton (Button)
│   ├── NextButton (Button)
│   └── CompleteButton (Button)
│
├── LandingUIPanel (Panel)
│   ├── [VivenLuaBehaviour: LandingUIManager.lua]
│   ├── Background (Image)
│   ├── Logo (Image)
│   ├── HowToPlayButton (Button)
│   └── GameStartButton (Button)
│
├── LevelSelectUIPanel (Panel)
│   ├── [VivenLuaBehaviour: LevelSelectUI.lua]
│   ├── Background (Image)
│   ├── EasyButton (Button)
│   ├── HardButton (Button)
│   ├── DescriptionText (TextMeshPro)
│   └── BackButton (Button)
│
├── GameHUDPanel (Panel)
│   ├── [VivenLuaBehaviour: GameHUD.lua]
│   ├── TimerText (TextMeshPro)
│   ├── HPBar (Image - Filled)
│   ├── HPText (TextMeshPro)
│   ├── ScoreText (TextMeshPro)
│   └── ComboText (TextMeshPro)
│
├── GameOverUIPanel (Panel)
│   ├── [VivenLuaBehaviour: GameOverUI.lua]
│   ├── Background (Image)
│   ├── GameOverText (TextMeshPro)
│   └── RetryButton (Button)
│
└── ResultUIPanel (Panel)
    ├── [VivenLuaBehaviour: ResultUIManager.lua]
    ├── Background (Image)
    ├── ScoreText (TextMeshPro)
    ├── AccuracyText (TextMeshPro)
    ├── MostWrongText (TextMeshPro)
    ├── HintText (TextMeshPro)
    └── RetryButton (Button)
```

### 7.2 Panel 전환 원리

GameManager가 `ChangeState()` 함수를 통해 Panel을 전환합니다:

```lua
-- GameManager.lua
function ChangeState(newState)
    HideAllUI()  -- 모든 Panel 비활성화

    if newState == "Guide" then
        ShowUI("slideUI")  -- SlideUIPanel만 활성화
    elseif newState == "Landing" then
        ShowUI("landingUI")  -- LandingUIPanel만 활성화
    -- ... 기타 상태
    end
end
```

### 7.3 GameManager UI 의존성 주입

GameManager의 인스펙터에서 각 Panel을 연결합니다:

```
Script Variables:
├── SlideUIPanel: SlideUIPanel (Panel GameObject)
├── LandingUIPanel: LandingUIPanel (Panel GameObject)
├── LevelSelectUIPanel: LevelSelectUIPanel (Panel GameObject)
├── GameHUDPanel: GameHUDPanel (Panel GameObject)
├── GameOverUIPanel: GameOverUIPanel (Panel GameObject)
└── ResultUIPanel: ResultUIPanel (Panel GameObject)
```

### 7.4 각 Panel의 VivenLuaBehaviour 의존성 주입

각 Panel의 스크립트에서 자식 요소들을 연결합니다:

**SlideUIPanel (SlideUIManager.lua)**:
```
├── Slide1: Slide1 (GameObject)
├── Slide2: Slide2 (GameObject)
├── Slide3: Slide3 (GameObject)
├── Slide4: (비워두기 또는 None)
├── Slide5: (비워두기 또는 None)
├── PrevButton: PrevButton (GameObject)
├── NextButton: NextButton (GameObject)
└── CompleteButton: CompleteButton (GameObject)
```

**LandingUIPanel (LandingUIManager.lua)**:
```
├── HowToPlayButton: HowToPlayButton (GameObject)
├── GameStartButton: GameStartButton (GameObject)
└── LogoObject: Logo (GameObject, 선택)
```

**LevelSelectUIPanel (LevelSelectUI.lua)**:
```
├── EasyButton: EasyButton (GameObject)
├── HardButton: HardButton (GameObject)
├── BackButton: BackButton (GameObject, 선택)
└── DescriptionTextObject: DescriptionText (GameObject, 선택)
```

**GameHUDPanel (GameHUD.lua)**:
```
├── TimerTextObject: TimerText (GameObject)
├── HPBarObject: HPBar (GameObject)
├── HPTextObject: HPText (GameObject, 선택)
├── ScoreTextObject: ScoreText (GameObject, 선택)
└── ComboTextObject: ComboText (GameObject, 선택)
```

**GameOverUIPanel (GameOverUI.lua)**:
```
├── RetryButton: RetryButton (GameObject)
└── GameOverTextObject: GameOverText (GameObject, 선택)
```

**ResultUIPanel (ResultUIManager.lua)**:
```
├── ScoreTextObject: ScoreText (GameObject)
├── AccuracyTextObject: AccuracyText (GameObject)
├── MostWrongTextObject: MostWrongText (GameObject)
├── HintTextObject: HintText (GameObject)
└── RetryButton: RetryButton (GameObject)
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
Assets/Recycle Dunk/Scripts/UI/GameOverUI.lua
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
├── ScoreManagerObject: ScoreManager (GameObject)
├── SpawnManagerObject: SpawnManager (GameObject)
├── SlideUIPanel: SlideUIPanel (Panel)
├── LandingUIPanel: LandingUIPanel (Panel)
├── LevelSelectUIPanel: LevelSelectUIPanel (Panel)
├── GameHUDPanel: GameHUDPanel (Panel)
├── GameOverUIPanel: GameOverUIPanel (Panel)
└── ResultUIPanel: ResultUIPanel (Panel)
```

> **참고**: 모든 UI Panel은 단일 MainCanvas의 자식으로 배치됩니다.

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
| UI 버튼 클릭 후 화면 전환 안됨 | GameManager GameObject 이름 불일치 | GameObject 이름이 정확히 "GameManager"인지 확인 |

### 12.2 콘솔 에러 확인

Unity Console에서 `[Lua]` 또는 `Viven` 관련 에러 확인

### 12.3 스크립트 간 통신 방식

**중요**: 이 프로젝트에서는 EventCallback 대신 **GameObject.Find()를 통한 직접 호출 방식**을 사용합니다.

```lua
-- UI 스크립트에서 GameManager 직접 호출 예시
function GetGameManager()
    local gameManagerObj = CS.UnityEngine.GameObject.Find("GameManager")
    if gameManagerObj then
        return gameManagerObj:GetLuaComponent("GameManager")
    end
    Debug.Log("ERROR: GameManager not found")
    return nil
end

function OnButtonClick()
    local gameManager = GetGameManager()
    if gameManager then
        gameManager.OnGuideComplete()
    end
end
```

**주의사항**:
- GameManager가 있는 GameObject의 이름은 반드시 **"GameManager"**여야 합니다
- 대소문자 구분됨

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

### 단일 Canvas + 다중 Panel UI
```
MainCanvas (World Space):
├── Canvas (Render Mode: World Space)
├── VivenUIPointerEvents
└── UI Panels
    ├── SlideUIPanel + [VivenLuaBehaviour]
    ├── LandingUIPanel + [VivenLuaBehaviour]
    ├── LevelSelectUIPanel + [VivenLuaBehaviour]
    ├── GameHUDPanel + [VivenLuaBehaviour]
    ├── GameOverUIPanel + [VivenLuaBehaviour]
    └── ResultUIPanel + [VivenLuaBehaviour]
```
