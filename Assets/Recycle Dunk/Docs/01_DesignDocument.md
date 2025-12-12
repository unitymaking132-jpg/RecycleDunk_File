# Recycle Dunk - 게임 설계서

**프로젝트명**: Recycle Dunk
**플랫폼**: VR (VIVEN Platform) / PC
**SDK**: VIVEN SDK (Lua Scripting)
**버전**: 1.4.0
**최종 수정일**: 2025-12-13

---

## 1. 게임 개요

### 1.1 컨셉
우주 공간에서 지구를 살리기 위해 재활용품을 올바른 쓰레기통에 던져 넣는 VR/PC 게임

### 1.2 핵심 게임플레이
- 플레이어 앞에 무중력 상태로 떠다니는 재활용품을 잡아서 올바른 쓰레기통에 던져 넣음
- 정확한 분리수거 시 점수 획득, 잘못된 분류 시 HP 감소
- 제한 시간 내에 최대한 많은 점수 획득

### 1.3 타겟 플레이어
- VR 입문자 및 일반 사용자
- 환경 교육 목적의 학생 및 교육 기관

---

## 2. 게임 흐름

```
[앱 시작]
    ↓
[가이드 UI] ←────────────────────────┐
    ↓ (슬라이드 읽기 완료)             │
[랜딩 UI (메인 메뉴)]                  │
    ├── [How to Play] ───────────────┘
    └── [Game Start]
            ↓
[레벨 선택 UI]
    ├── [Easy Mode] ──→ [게임 플레이]
    └── [Hard Mode (비활성화)] ──→ (추후 개발)
            ↓
[게임 플레이]
    ├── 쓰레기 스폰 (Perlin Noise 무중력)
    ├── 잡기 → 던지기 → 판정
    ├── HP/타이머 관리
    └── 게임 종료 조건 확인
            ↓
[결과 UI]
    ├── 점수 표시
    ├── 정확도 표시
    ├── 가장 많이 틀린 카테고리
    └── [다시 하기] / [메인으로]
```

---

## 3. 시스템 설계

### 3.1 게임 상태 (Game State)

| 상태 | 설명 |
|------|------|
| `Idle` | 초기 상태 |
| `Guide` | 가이드 UI 표시 중 |
| `Landing` | 랜딩 UI (메인 메뉴) |
| `LevelSelect` | 레벨 선택 화면 |
| `Playing` | 게임 진행 중 |
| `Paused` | 일시 정지 |
| `GameOver` | 게임 오버 (HP 0) |
| `TimeUp` | 시간 종료 |
| `Result` | 결과 화면 |

### 3.2 쓰레기 카테고리

| 카테고리 | 색상 | 예시 아이템 |
|---------|------|------------|
| Paper (종이) | 파란색 | 신문지, 상자, 종이컵 |
| Plastic (플라스틱) | 빨간색 | 페트병, 플라스틱 용기 |
| Glass (유리) | 초록색 | 유리병, 유리컵 |
| Metal (금속) | 노란색 | 캔, 알루미늄 용기 |
| Misc (일반 쓰레기) | 회색/검정 | 음식물 묻은 용기, 복합 재질 |

> **참고**: Misc는 재활용이 안 되는 일반 쓰레기로, 별도의 일반 쓰레기통에 버려야 함

### 3.3 점수 시스템

| 행동 | 점수/HP |
|------|---------|
| 올바른 분류 | +100점 |
| 잘못된 분류 | -1 HP |
| 쓰레기 놓침 (범위 이탈) | -1 HP |
| 연속 정답 보너스 | +50점 × 연속 횟수 |

### 3.4 HP 시스템

- **시작 HP**: 5
- **HP 감소 조건**:
  - 잘못된 쓰레기통에 투척
  - 쓰레기가 일정 범위 밖으로 이탈
- **HP 0**: 게임 오버

### 3.5 타이머 시스템

- **게임 시간**: 60초 (Easy Mode)
- **표시 형식**: MM:SS
- **시간 종료**: 자동 결과 화면 전환

---

## 4. 오브젝트 설계

### 4.1 쓰레기 오브젝트 (Trash Item)

```yaml
컴포넌트:
  - VObject (네트워크 동기화)
  - VivenGrabbableModule (잡기 가능)
  - VivenRigidbodyControlModule (물리 제어)
  - VivenGrabbableRigidView (네트워크 뷰)
  - VivenLuaBehaviour (TrashItem.lua)
  - Collider (트리거 감지용)

속성:
  - trashCategory: string ("Paper" | "Plastic" | "Glass" | "Metal" | "Misc")
  - isGrabbed: boolean
  - spawnPosition: Vector3
  - floatOffset: Vector3 (Perlin Noise 오프셋)
```

### 4.2 쓰레기통 오브젝트 (Trash Bin)

```yaml
컴포넌트:
  - VObject
  - VivenLuaBehaviour (TrashBin.lua)
  - Collider (Trigger)

속성:
  - binCategory: string ("Paper" | "Plastic" | "Glass" | "Metal" | "Misc")
  - binColor: Color
```

### 4.3 경계 영역 (Boundary Zone)

```yaml
컴포넌트:
  - Collider (Trigger, 큰 구 형태)
  - VivenLuaBehaviour (BoundaryZone.lua)

기능:
  - 쓰레기가 이 영역을 벗어나면 HP 감소 이벤트 발생
```

---

## 5. UI 설계

### 5.0 UI 아키텍처

**단일 Canvas + 다중 Panel 구조**를 사용합니다.

```
MainCanvas (World Space)
├── SlideUIPanel (Guide/How to Play)
├── LandingUIPanel (메인 메뉴)
├── LevelSelectUIPanel (난이도 선택)
├── GameHUDPanel (게임 진행 중 HUD)
├── GameOverUIPanel (게임오버)
└── ResultUIPanel (결과 화면)
```

**설계 원칙**:
- 하나의 Canvas에 모든 UI Panel 배치
- GameManager가 상태에 따라 Panel을 SetActive(true/false)로 전환
- 각 Panel에 해당 UI 스크립트(VivenLuaBehaviour) 부착
- World Space Canvas로 VR 환경에 적합하게 구성

**Panel 전환 흐름**:
```
GameManager.ChangeState(newState)
    ↓
HideAllUI() - 모든 Panel 비활성화
    ↓
ShowUI(uiName) - 해당 상태의 Panel만 활성화
```

### 5.1 가이드 UI (SlideUI)

```
┌─────────────────────────────────────┐
│                                     │
│     [슬라이드 이미지/텍스트]          │
│                                     │
├─────────────────────────────────────┤
│  [◀ 이전]              [다음 ▶]     │
│            [● ○ ○ ○]               │
└─────────────────────────────────────┘
```

**기능**:
- 좌/우 화살표로 슬라이드 이동
- 점 인디케이터로 현재 위치 표시
- 마지막 슬라이드에서 "시작하기" 버튼

### 5.2 랜딩 UI (LandingUI)

```
┌─────────────────────────────────────┐
│                                     │
│         [RECYCLE DUNK 로고]          │
│                                     │
├─────────────────────────────────────┤
│  [How to Play]      [Game Start]    │
└─────────────────────────────────────┘
```

### 5.3 레벨 선택 UI (LevelSelectUI)

```
┌─────────────────────────────────────┐
│          레벨 선택                   │
├─────────────────────────────────────┤
│                                     │
│   [Easy Mode]    [Hard Mode]        │
│                   (추후 개발)         │
│                                     │
│         [난이도 설명 텍스트]          │
│                                     │
│              [뒤로가기]              │
└─────────────────────────────────────┘
```

### 5.4 게임 HUD (GameHUD)

```
┌─────────────────────────────────────┐
│  01:00                      ██████  │  ← 타이머, HP 바
│                             (HP 5)  │
├─────────────────────────────────────┤
│                                     │
│         [게임 영역]                  │
│                                     │
└─────────────────────────────────────┘
```

### 5.5 게임오버 UI (GameOverUI)

HP가 0이 되어 게임이 종료되었을 때 표시되는 UI

```
┌─────────────────────────────────────┐
│                                     │
│           Game Over                 │
│         (빨간색 텍스트)              │
│                                     │
├─────────────────────────────────────┤
│            [Retry]                  │
└─────────────────────────────────────┘
```

**기능**:
- 간단한 게임 오버 메시지 표시
- Retry 버튼으로 즉시 재시작

### 5.6 결과 UI (ResultUI)

시간이 종료되어 게임이 정상 종료되었을 때 표시되는 UI

```
┌─────────────────────────────────────┐
│                                     │
│   Final Score: 80 points            │
│                                     │
│   Accuracy: 63%                     │
│                                     │
│   Most Wrong Item: General Garbage  │
│                                     │
│   "Check the types of regular       │
│    garbage again!"                  │
│         (힌트 메시지)                │
│                                     │
├─────────────────────────────────────┤
│            [Retry]                  │
└─────────────────────────────────────┘
```

**기능**:
- Final Score: 최종 점수 표시
- Accuracy: 정확도 (%) 표시
- Most Wrong Item: 가장 많이 틀린 카테고리 표시
- 힌트 메시지: 가장 많이 틀린 카테고리에 대한 학습 유도 메시지
- Retry 버튼으로 재시작

**힌트 메시지 예시**:

| 카테고리 | 메시지 |
|---------|--------|
| Paper | "Make sure paper is clean and dry!" |
| Plastic | "Check if the plastic has recycling marks!" |
| Glass | "Glass bottles should be emptied first!" |
| Metal | "Cans should be rinsed before recycling!" |
| Misc | "Check the types of regular garbage again!" |

---

## 6. 스크립트 구조

### 6.1 폴더 구조

```
Assets/Recycle Dunk/
├── Docs/                          # 문서
│   ├── 01_DesignDocument.md
│   ├── 02_DevelopmentTracking.md
│   └── 03_UnitySetupGuide.md
│
├── Scripts/                       # Lua 스크립트
│   ├── Manager/                   # 게임 매니저
│   │   ├── GameManager.lua        # 메인 게임 로직
│   │   ├── SpawnManager.lua       # 쓰레기 스폰 관리
│   │   ├── ScoreManager.lua       # 점수/HP 관리
│   │   └── AudioManager.lua       # 사운드 관리
│   │
│   ├── Objects/                   # 오브젝트 스크립트
│   │   ├── TrashItem.lua          # 쓰레기 아이템
│   │   ├── TrashBin.lua           # 쓰레기통
│   │   ├── BoundaryZone.lua       # 경계 영역
│   │   └── FloatingBehavior.lua   # 무중력 떠다니기
│   │
│   ├── UI/                        # UI 스크립트
│   │   ├── SlideUIManager.lua     # 슬라이드 가이드 UI
│   │   ├── LandingUIManager.lua   # 랜딩 UI
│   │   ├── LevelSelectUI.lua      # 레벨 선택 UI
│   │   ├── GameHUD.lua            # 게임 HUD
│   │   ├── GameOverUI.lua         # 게임오버 UI (HP 0)
│   │   └── ResultUIManager.lua    # 결과 UI (시간 종료)
│   │
│   └── Utils/                     # 유틸리티
│       └── Definitions.def.lua    # 타입 정의
│
├── Prefabs/                       # 프리팹
│   ├── Trash/                     # 쓰레기 프리팹
│   │   ├── Paper/
│   │   ├── Plastic/
│   │   ├── Glass/
│   │   └── Metal/
│   ├── Bins/                      # 쓰레기통 프리팹
│   └── UI/                        # UI 프리팹
│
├── Materials/                     # 머티리얼
├── Audio/                         # 사운드
└── Scenes/                        # 씬
    └── RecycleDunk.unity
```

### 6.2 스크립트 의존성 다이어그램

```
GameManager
    ├── SpawnManager (쓰레기 스폰)
    ├── ScoreManager (점수/HP)
    ├── AudioManager (사운드)
    └── UI Managers
        ├── SlideUIManager
        ├── LandingUIManager
        ├── LevelSelectUI
        ├── GameHUD
        ├── GameOverUI (HP 0 시)
        └── ResultUIManager (시간 종료 시)

TrashItem
    ├── FloatingBehavior (무중력 효과)
    └── → TrashBin (충돌 시 판정)

TrashBin
    └── → ScoreManager (점수 처리)

BoundaryZone
    └── → ScoreManager (HP 감소)
```

---

## 7. 스크립트 간 통신 패턴

### 7.1 직접 호출 방식 (유일한 방식)

모든 스크립트 간 통신은 **직접 메서드 호출** 방식을 사용합니다.
EventCallback 시스템은 복잡성 대비 이점이 없어 **사용하지 않습니다**.

#### UI → Manager 호출 (GameObject.Find 방식)

```lua
-- UI 스크립트에서 GameManager 직접 호출
function OnRetryClick()
    local gameManagerObj = CS.UnityEngine.GameObject.Find("GameManager")
    if gameManagerObj then
        local gameManager = gameManagerObj:GetLuaComponent("GameManager")
        if gameManager then
            gameManager.OnRetryGame()
        end
    end
end
```

#### Manager → Manager 호출 (Injection 방식)

```lua
-- Injection을 통해 참조 획득
---@type GameObject
GameManagerObject = NullableInject(GameManagerObject)

-- awake()에서 컴포넌트 캐싱
function awake()
    if GameManagerObject then
        gameManager = GameManagerObject:GetLuaComponent("GameManager")
    end
end

-- 직접 메서드 호출
function NotifyGameOver(reason)
    if gameManager then
        gameManager.OnGameOver(reason)
    end
end
```

#### Manager → UI 호출 (직접 메서드 호출)

```lua
-- GameManager에서 GameHUD 직접 호출
if gameHUD then
    gameHUD.UpdateScore(currentScore)
    gameHUD.UpdateHP(currentHP, startHP)
end
```

**장점**:
- 단순하고 명확한 호출 흐름
- 디버깅 용이 (스택 트레이스 추적 가능)
- Import Scripts 인스턴스 분리 문제 없음
- 코드 복잡도 감소

### 7.2 GameManager 공개 메서드

| 메서드명 | 호출 위치 | 설명 |
|---------|----------|------|
| `OnGuideComplete()` | SlideUIManager | 가이드 완료 → Landing 상태로 전환 |
| `OnGoToGuide()` | LandingUIManager | How to Play 클릭 → Guide 상태로 전환 |
| `GoToLevelSelect()` | LandingUIManager | Game Start 클릭 → LevelSelect 상태로 전환 |
| `OnLevelSelected(difficulty)` | LevelSelectUI | 난이도 선택 → 게임 시작 |
| `OnGoToMain()` | LevelSelectUI, ResultUI | 뒤로가기 → Landing 상태로 전환 |
| `OnRetryGame()` | GameOverUI, ResultUI | 재시작 → 게임 다시 시작 |
| `OnGameOver(reason)` | ScoreManager | HP 0 → 게임오버 처리 |

### 7.3 ScoreManager 공개 메서드

| 메서드명 | 호출 위치 | 설명 |
|---------|----------|------|
| `OnCorrectAnswer(category)` | TrashItem | 올바른 분류 → 점수 증가 |
| `OnWrongAnswer(trashCategory, binCategory)` | TrashItem | 잘못된 분류 → HP 감소 |
| `OnTrashLost(category)` | TrashItem | 경계 이탈 → HP 감소 |

### 7.4 SpawnManager 공개 메서드

| 메서드명 | 호출 위치 | 설명 |
|---------|----------|------|
| `InitSpawn(settings)` | GameManager | 스폰 설정 초기화 |
| `StartSpawning()` | GameManager | 스폰 시작 |
| `StopSpawning()` | GameManager | 스폰 정지 |
| `PauseSpawning()` | GameManager | 스폰 일시정지 |
| `ResumeSpawning()` | GameManager | 스폰 재개 |
| `ClearAllTrash()` | GameManager | 모든 쓰레기 풀로 반환 |
| `OnTrashDestroyed(obj, category, poolIndex)` | TrashItem | 쓰레기 제거 → 풀 반환 |
| `ReturnAllToPool()` | GameManager | 모든 오브젝트 풀로 반환 |
| `GetActiveTrashCount()` | 내부 | 활성 쓰레기 수 반환 |
| `GetPoolStatus()` | 디버그 | 카테고리별 풀 상태 반환 |

### 7.5 TrashBin 공개 메서드

| 메서드명 | 호출 위치 | 설명 |
|---------|----------|------|
| `OnTrashEntered(trashCategory)` | TrashItem | 쓰레기 진입 판정 (boolean 반환) |

### 7.6 AudioManager 공개 메서드

| 메서드명 | 호출 위치 | 설명 |
|---------|----------|------|
| `PlayMainBGM()` | GameManager | 메인 게임 BGM 재생 |
| `PlayMenuBGM()` | GameManager | 메뉴/랜딩 BGM 재생 |
| `StopBGM()` | GameManager | BGM 정지 |
| `PauseBGM()` | GameManager | BGM 일시정지 |
| `ResumeBGM()` | GameManager | BGM 재개 |
| `PlayPickup()` | TrashItem | 잡기 효과음 재생 |
| `PlayThrow()` | TrashItem | 던지기 효과음 재생 |
| `PlayGood()` | ScoreManager | 정답 효과음 재생 |
| `PlayMiss()` | ScoreManager | 오답 효과음 재생 |
| `PlayGameOver()` | GameManager | 게임오버 효과음 재생 |
| `PlayFinish()` | GameManager | 결과/완료 효과음 재생 |
| `PlayUIClick()` | UI Scripts | UI 클릭/전환 효과음 재생 |

---

## 8. 난이도 설계

### 8.1 Easy Mode (현재 구현 대상)

| 항목 | 값 |
|------|-----|
| 게임 시간 | 60초 |
| 시작 HP | 5 |
| 쓰레기 스폰 간격 | **2초** |
| 최대 동시 쓰레기 수 | **7개** |
| 정답 점수 | 100점 |
| 콤보 보너스 | 50점 |

### 8.2 Hard Mode

| 항목 | 값 |
|------|-----|
| 게임 시간 | 90초 |
| 시작 HP | 3 |
| 쓰레기 스폰 간격 | **1.5초** |
| 최대 동시 쓰레기 수 | **10개** |
| 정답 점수 | 150점 |
| 콤보 보너스 | 75점 |

---

## 9. Perlin Noise 무중력 효과

### 9.1 알고리즘

```lua
-- FloatingBehavior.lua
local noiseOffset = Vector3.zero
local noiseScale = 0.5      -- 노이즈 스케일
local noiseSpeed = 0.3      -- 노이즈 속도
local floatRange = 0.1      -- 떠다니는 범위

function update()
    local time = Time.time * noiseSpeed

    noiseOffset.x = (Mathf.PerlinNoise(time, 0) - 0.5) * floatRange
    noiseOffset.y = (Mathf.PerlinNoise(0, time) - 0.5) * floatRange
    noiseOffset.z = (Mathf.PerlinNoise(time, time) - 0.5) * floatRange

    transform.localPosition = spawnPosition + noiseOffset
end
```

---

## 10. 기술 요구사항

### 10.1 VIVEN SDK 컴포넌트

- `VObject`: 네트워크 동기화 (싱글플레이어이지만 기본 구조 유지)
- `VivenGrabbableModule`: 손으로 잡기
- `VivenRigidbodyControlModule`: 물리 기반 이동
- `VivenLuaBehaviour`: Lua 스크립트 실행

### 10.2 VR 입력

- **잡기**: Grip 버튼
- **던지기**: Grip 해제 + 손 속도 기반 투척
- **UI 상호작용**: 레이저 포인터 + 트리거

### 10.3 PC 입력 (옵션)

- **마우스**: 쓰레기 선택 및 던지기
- **클릭 & 드래그**: 잡기 및 던지기 방향 지정

---

## 11. 향후 확장 계획

### Phase 1 (현재)
- [x] 기본 게임 메커니즘
- [x] Easy Mode
- [x] 4가지 쓰레기 카테고리
- [x] 기본 UI 시스템
- [x] AudioManager 구현 (BGM 랜덤 셔플 재생)
- [ ] AudioManager Unity Injection 연결 (수동 작업 필요)

### Phase 2 (추후)
- [ ] Hard Mode
- [ ] 세척 기믹
- [ ] 복합 재질 쓰레기
- [ ] 리더보드

### Phase 3 (추후)
- [ ] 멀티플레이어 협동/대전
- [ ] 추가 스테이지
- [ ] 업적 시스템

---

## 12. Object Pooling 아키텍처

### 12.1 개요

VIVEN SDK는 런타임에서 동적 VObject Instantiate를 지원하지 않습니다.
따라서 쓰레기 오브젝트는 **Object Pooling** 패턴으로 관리합니다.

**핵심 원칙**:
- 씬에 미리 배치된 오브젝트 재사용
- `Instantiate()` 대신 `SetActive(true/false)`
- VObject ID는 씬 배치 시 생성된 고유 ID 유지

### 12.2 풀 구성

| 카테고리 | 프리팹 종류 | 종류 수 | 풀 크기 |
|---------|------------|--------|--------|
| Paper | Trash_Paper_01, 02, 03 | 3종 | 30개 |
| Plastic | Trash_Plastic_01, 02, 03 | 3종 | 30개 |
| Glass | Trash_Glass_01, 02 | 2종 | 20개 |
| Metal | Trash_Metal_Can01, Can02 | 2종 | 20개 |
| Misc | Trash_Misc_CrackedEgg | 1종 | 10개 |
| **총계** | | **11종** | **110개** |

### 12.3 씬 계층 구조

```
TrashPools/                    # 빈 GameObject
├── PaperPool/                 # Paper 풀 부모 (30개)
│   ├── Trash_Paper_01 x 10개
│   ├── Trash_Paper_02 x 10개
│   └── Trash_Paper_03 x 10개
├── PlasticPool/               # Plastic 풀 부모 (30개)
│   ├── Trash_Plastic_01 x 10개
│   ├── Trash_Plastic_02 x 10개
│   └── Trash_Plastic_03 x 10개
├── GlassPool/                 # Glass 풀 부모 (20개)
│   ├── Trash_Glass_01 x 10개
│   └── Trash_Glass_02 x 10개
├── MetalPool/                 # Metal 풀 부모 (20개)
│   ├── Trash_Metal_Can01 x 10개
│   └── Trash_Metal_Can02 x 10개
└── MiscPool/                  # Misc 풀 부모 (10개)
    └── Trash_Misc_CrackedEgg x 10개
```

### 12.4 풀링 흐름도

```
[게임 시작]
    ↓
[awake] InitializePools()
    ├── GetChildren()로 자식 오브젝트 수집
    ├── poolObjects, poolScripts에 캐싱
    ├── poolInitialPose에 초기 위치/회전 저장
    ├── TrashItem에 매니저 참조 설정
    └── 모든 오브젝트 비활성화
    ↓
[스폰 요청] SpawnTrash(category, position)
    ├── GetFromPool(category)
    │   ├── available[1] → inUse로 이동
    │   └── 오브젝트, 스크립트, 인덱스 반환
    ├── 위치 설정 + SetActive(true)
    ├── ResetTrash(category, position, poolIndex)
    └── ResetFloating(position, settings)
    ↓
[판정/이탈] ReturnToPool()
    ├── grabbable:Release()
    ├── grabbable:FlushInteractableCollider()
    ├── SpawnManager.OnTrashDestroyed()
    │   └── ReturnToPool(category, poolIndex)
    │       ├── inUse → available로 이동
    │       ├── 위치/회전 복원
    │       └── SetActive(false)
    └── 재사용 대기
```

### 12.5 핵심 함수

#### SpawnManager.lua

| 함수 | 설명 |
|------|------|
| `GetChildren(parent, objTable, scriptTable, scriptName)` | 자식 오브젝트 수집 |
| `InitializePools()` | 모든 풀 초기화 (awake에서 호출) |
| `InitializePool(category, poolParent)` | 단일 풀 초기화 + 초기 위치 저장 |
| `GetFromPool(category)` | available → inUse 이동, 오브젝트 반환 |
| `ReturnToPool(category, poolIndex)` | inUse → available 이동, 위치 복원, 비활성화 |
| `ReturnAllToPool()` | 모든 오브젝트 풀로 반환 |

#### TrashItem.lua

| 함수 | 설명 |
|------|------|
| `ResetTrash(category, position, index)` | 풀에서 활성화 시 상태 초기화 |
| `ReturnToPool()` | 판정/이탈 시 풀로 반환 |
| `SetCategory(category)` | 카테고리 설정 |
| `SetPoolIndex(index)` | 풀 인덱스 설정 |

#### FloatingBehavior.lua

| 함수 | 설명 |
|------|------|
| `ResetFloating(position, settings)` | 떠다니기 상태 완전 초기화 |

### 12.6 VObject 풀링 핵심 패턴

**⚠️ 중요: VObject는 SetActive() 사용 불가!**

VIVEN SDK의 VObject는 내부 상태 관리로 인해 `SetActive(false)` 호출 시 내부 상태가 깨질 수 있습니다.
대신 **MeshRenderer + Collider** 방식을 사용합니다:

```lua
-- ❌ 잘못된 방식 (VObject 내부 상태 깨짐)
gameObject:SetActive(false)

-- ✅ 올바른 방식 (컴포넌트 개별 비활성화)
local HIDE_POSITION = Vector3(0, -1000, 0)

function SetPoolObjectVisible(obj, visible)
    -- 위치로 숨기기/보이기
    if visible then
        obj.transform.position = spawnPosition
    else
        obj.transform.position = HIDE_POSITION
    end

    -- MeshRenderer 비활성화
    local renderers = obj:GetComponentsInChildren(typeof(CS.UnityEngine.MeshRenderer))
    for i = 0, renderers.Length - 1 do
        renderers[i].enabled = visible
    end

    -- Collider 비활성화
    local colliders = obj:GetComponentsInChildren(typeof(CS.UnityEngine.Collider))
    for i = 0, colliders.Length - 1 do
        colliders[i].enabled = visible
    end
end
```

### 12.7 FlushAllGrabbables 패턴

**모든 Grabbable 오브젝트의 상태를 동기화하는 패턴**

풀 오브젝트의 가시성/상태가 변경될 때, 모든 Grabbable의 Interactor 상태를 갱신해야 합니다:

```lua
-- 모든 Grabbable 모듈 수집 (InitializePools에서)
local allGrabbableModules = {}

function InitializePools()
    -- ... 풀 초기화 중 ...
    for _, obj in ipairs(poolObjects) do
        local grabbable = obj:GetComponent("VivenGrabbableModule")
        if grabbable then
            table.insert(allGrabbableModules, grabbable)
        end
    end
end

-- 상태 변경 후 모든 Grabbable 갱신
function FlushAllGrabbables()
    for _, grabbable in ipairs(allGrabbableModules) do
        local success, err = pcall(function()
            grabbable:FlushInteractableCollider()
        end)
    end
end

-- 사용 예시: 오브젝트 가시성 변경 후 호출
SetPoolObjectVisible(obj, true)
FlushAllGrabbables()
```

### 12.8 주의사항

1. **VObject ID 보존**: 씬에 배치 시 자동 생성된 고유 ID 유지 (재생성 안 함)
2. **Grabbable 상태**: ReturnToPool 시 반드시 `Release()` + `FlushInteractableCollider()` 호출
3. **위치 복원**: 풀 초기화 시 저장한 position/rotation으로 복원
4. **카테고리 통일**: 모든 코드에서 `Misc` 사용 (`GeneralGarbage` 제거됨)
5. **SetActive 금지**: VObject에는 절대 `SetActive()` 사용하지 않기
6. **FlushAllGrabbables**: 오브젝트 가시성 변경 후 반드시 호출
7. **초기화 순서**: 풀 초기화 중에는 FlushAllGrabbables 호출 금지 (isPoolInitializing 플래그 사용)

---

## 13. Audio 시스템 아키텍처

### 13.1 오디오 파일 구조

```
Assets/Recycle Dunk/Audio/
├── BGM/                              # 배경 음악
│   ├── Exploring the Cosmos.mp3      # 메인 BGM 옵션 1
│   ├── Starry Drift.mp3              # 메인 BGM 옵션 2
│   ├── XR_BGM 1.mp3                  # 게임 BGM 옵션 1
│   └── XR_BGM 2.mp3                  # 게임 BGM 옵션 2
│
└── SFX/                              # 효과음
    ├── XR_PICKUP.mp3                 # 잡기 효과음
    ├── XR_THROW.mp3                  # 던지기 효과음
    ├── XR_GOOD.mp3                   # 정답 효과음
    ├── XR_MISS.mp3                   # 오답 효과음
    ├── XR_GAMEOVER.mp3               # 게임오버 효과음
    ├── XR_FINISH.mp3                 # 결과/완료 효과음
    └── XR_TURN PAGE.mp3              # UI 전환 효과음
```

### 13.2 AudioManager Unity 설정

**구현 상태**: ✅ 완료 (Unity 컴포넌트 연결 완료, Injection 수동 설정 필요)

```yaml
AudioManager GameObject:
  위치: MANAGERS/AudioManager
  Components:
    - VivenLuaBehaviour (AudioManager.lua) ✅
    - AudioSource #1 (BGM용) ✅
      - Loop: false (자동 순환을 위해 false)
      - PlayOnAwake: false
      - Volume: 0.5
    - AudioSource #2 (SFX용) ✅
      - Loop: false
      - PlayOnAwake: false
      - Volume: 1.0

Injection 필드 (Unity 에디터에서 드래그&드롭 필요):
  # AudioSource
  - BGMSource: BGM용 AudioSource 컴포넌트
  - SFXSource: SFX용 AudioSource 컴포넌트

  # BGM (4개 - 랜덤 순환 재생)
  - BGM_1: Exploring the Cosmos.mp3
  - BGM_2: Starry Drift.mp3
  - BGM_3: XR_BGM 1.mp3
  - BGM_4: XR_BGM 2.mp3

  # SFX
  - SFX_Pickup: XR_PICKUP.mp3
  - SFX_Throw: XR_THROW.mp3
  - SFX_Good: XR_GOOD.mp3
  - SFX_Miss: XR_MISS.mp3
  - SFX_GameOver: XR_GAMEOVER.mp3
  - SFX_Finish: XR_FINISH.mp3
  - SFX_UIClick: XR_TURN PAGE.mp3
```

### 13.3 BGM 랜덤 순환 재생 시스템

**동작 방식**:
1. 게임 시작 시 4개 BGM을 Fisher-Yates 알고리즘으로 셔플
2. 셔플된 순서대로 BGM 재생
3. 곡이 끝나면 자동으로 다음 곡 재생 (update()에서 감지)
4. 모든 곡 재생 완료 시 다시 셔플 (같은 곡 연속 방지)

**주요 함수**:
| 함수명 | 설명 |
|--------|------|
| `StartBGMPlaylist()` | BGM 랜덤 순환 재생 시작 |
| `StopBGMPlaylist()` | BGM 플레이리스트 정지 |
| `PlayNextBGM()` | 다음 BGM 재생 |
| `GetCurrentBGMInfo()` | 현재 재생 중인 BGM 정보 반환 |

### 13.4 사운드 재생 타이밍

| 이벤트 | 효과음 | 호출 위치 |
|--------|--------|----------|
| 게임 시작 | BGM 재생 | GameManager.StartGame() |
| 쓰레기 잡기 | PlayPickup() | TrashItem.onGrab() |
| 쓰레기 던지기 | PlayThrow() | TrashItem.onRelease() |
| 올바른 분류 | PlayGood() | ScoreManager.OnCorrectAnswer() |
| 잘못된 분류 | PlayMiss() | ScoreManager.OnWrongAnswer() |
| HP 0 게임오버 | PlayGameOver() | GameManager.OnGameOver() |
| 시간 종료 | PlayFinish() | GameManager.OnTimeUp() |
| UI 버튼 클릭 | PlayUIClick() | 각 UI 버튼 핸들러 |

---

## 부록 A: 참고 프로젝트

### Angames (요리 시뮬레이션)
- 위치: `D:\workspace\cooking\Assets\Angames`
- 참고 요소: IStep 시스템, EventCallback, UI 패턴

### Fantasia (멀티플레이어 RPG)
- 위치: `D:\workspace\Wemeet\2025-xr-pbl-1\Assets\Fantasia`
- 참고 요소: RPC 시스템, 게임 상태 관리, UI 매니저 패턴
