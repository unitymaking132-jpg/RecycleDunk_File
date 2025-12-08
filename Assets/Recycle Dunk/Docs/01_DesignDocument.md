# Recycle Dunk - 게임 설계서

**프로젝트명**: Recycle Dunk
**플랫폼**: VR (VIVEN Platform) / PC
**SDK**: VIVEN SDK (Lua Scripting)
**버전**: 1.0.0
**최종 수정일**: 2025-12-08

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
| General Garbage (일반 쓰레기) | 회색/검정 | 음식물 묻은 용기, 복합 재질 |

> **참고**: General Garbage는 재활용이 안 되는 일반 쓰레기로, 별도의 일반 쓰레기통에 버려야 함

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
  - trashCategory: string ("Paper" | "Plastic" | "Glass" | "Metal")
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
  - binCategory: string ("Paper" | "Plastic" | "Glass" | "Metal")
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
│    (활성화)       (비활성화)          │
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
| General Garbage | "Check the types of regular garbage again!" |

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
│       ├── EventCallback.lua      # 이벤트 시스템
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

## 7. 이벤트 시스템

### 7.1 게임 이벤트

| 이벤트명 | 발생 시점 | 파라미터 |
|---------|----------|---------|
| `onGameStart` | 게임 시작 | - |
| `onGamePause` | 일시 정지 | - |
| `onGameResume` | 게임 재개 | - |
| `onGameOver` | HP 0 또는 시간 종료 | reason: string |
| `onTrashSpawn` | 쓰레기 스폰 | trashItem: GameObject |
| `onTrashGrab` | 쓰레기 잡음 | trashItem: GameObject |
| `onTrashRelease` | 쓰레기 놓음 | trashItem: GameObject |
| `onTrashBinned` | 쓰레기통에 들어감 | isCorrect: boolean, category: string |
| `onTrashLost` | 쓰레기 범위 이탈 | trashItem: GameObject |
| `onScoreUpdate` | 점수 변경 | newScore: number |
| `onHPUpdate` | HP 변경 | newHP: number |
| `onComboUpdate` | 콤보 변경 | combo: number |

---

## 8. 난이도 설계

### 8.1 Easy Mode (현재 구현 대상)

| 항목 | 값 |
|------|-----|
| 게임 시간 | 60초 |
| 시작 HP | 5 |
| 쓰레기 스폰 간격 | 3초 |
| 최대 동시 쓰레기 수 | 5개 |
| 쓰레기 이동 속도 | 낮음 |
| 쓰레기통 크기 | 큼 |

### 8.2 Hard Mode (추후 개발)

| 항목 | 값 |
|------|-----|
| 게임 시간 | 90초 |
| 시작 HP | 3 |
| 쓰레기 스폰 간격 | 2초 |
| 최대 동시 쓰레기 수 | 8개 |
| 쓰레기 이동 속도 | 중간 |
| 쓰레기통 크기 | 중간 |
| 추가 기믹 | 세척 필요, 복합 재질 |

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

## 부록 A: 참고 프로젝트

### Angames (요리 시뮬레이션)
- 위치: `D:\workspace\cooking\Assets\Angames`
- 참고 요소: IStep 시스템, EventCallback, UI 패턴

### Fantasia (멀티플레이어 RPG)
- 위치: `D:\workspace\Wemeet\2025-xr-pbl-1\Assets\Fantasia`
- 참고 요소: RPC 시스템, 게임 상태 관리, UI 매니저 패턴
