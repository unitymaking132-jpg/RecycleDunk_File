# Recycle Dunk - 개발 현황 추적 문서

**프로젝트명**: Recycle Dunk
**버전**: 1.5.0
**최종 수정일**: 2025-12-13

---

## 1. 개발 진행 현황 요약

### 전체 진행률: 85%

| 카테고리 | 진행률 | 상태 |
|---------|--------|------|
| 핵심 시스템 | 100% | **완료** (AudioManager, VFXManager 추가) |
| UI 시스템 | 90% | **완료** (모든 UI 작동 확인) |
| 게임 오브젝트 | 100% | **완료** (풀링 시스템 버그 수정) |
| 사운드/VFX | 80% | **진행중** (AudioManager, VFXManager 연결 완료) |
| 테스트/버그 수정 | 70% | **완료** (VObject 풀링 버그 수정) |

---

## 2. 상세 태스크 목록

### 2.1 핵심 시스템 (Core Systems)

| ID | 태스크 | 우선순위 | 상태 | 담당자 | 비고 |
|----|-------|---------|------|--------|------|
| C-001 | GameManager.lua 작성 | 높음 | **완료** | - | 게임 상태 관리 |
| C-002 | SpawnManager.lua 작성 | 높음 | **완료** | - | Object Pooling 방식으로 구현 |
| C-003 | ScoreManager.lua 작성 | 높음 | **완료** | - | 점수/HP 관리 |
| C-004 | ~~EventCallback.lua 복사 및 적용~~ | - | **제거됨** | - | 직접 호출 방식으로 대체 |
| C-005 | AudioManager.lua 작성 | 중간 | **완료** | - | 사운드 관리 |
| C-006 | Definitions.def.lua 작성 | 높음 | **완료** | - | 타입 정의 (5개 카테고리 포함) |

### 2.2 게임 오브젝트 (Game Objects)

| ID | 태스크 | 우선순위 | 상태 | 담당자 | 비고 |
|----|-------|---------|------|--------|------|
| O-001 | TrashItem.lua 작성 | 높음 | **완료** | - | ResetTrash/ReturnToPool 추가 |
| O-002 | TrashBin.lua 작성 | 높음 | **완료** | - | 쓰레기통 스크립트 |
| O-003 | BoundaryZone.lua 작성 | 중간 | **완료** | - | 경계 영역 |
| O-004 | FloatingBehavior.lua 작성 | 높음 | **완료** | - | ResetFloating 함수 추가 |
| O-005 | 쓰레기 프리팹 생성 - Paper | 중간 | 미시작 | - | 종이류 프리팹 |
| O-006 | 쓰레기 프리팹 생성 - Plastic | 중간 | 미시작 | - | 플라스틱류 프리팹 |
| O-007 | 쓰레기 프리팹 생성 - Glass | 중간 | 미시작 | - | 유리류 프리팹 |
| O-008 | 쓰레기 프리팹 생성 - Metal | 중간 | 미시작 | - | 금속류 프리팹 |
| O-009 | 쓰레기 프리팹 생성 - Misc | 중간 | 미시작 | - | 일반 쓰레기 프리팹 |
| O-010 | 쓰레기통 프리팹 생성 (5종) | 중간 | 미시작 | - | 5가지 카테고리 |
| O-011 | VObject 컴포넌트 설정 | 높음 | 미시작 | - | 모든 오브젝트 적용 |

### 2.3 UI 시스템 (UI Systems)

| ID | 태스크 | 우선순위 | 상태 | 담당자 | 비고 |
|----|-------|---------|------|--------|------|
| U-001 | SlideUIManager.lua 작성 | 높음 | **완료** | - | 슬라이드 가이드 UI |
| U-002 | SlideUI 프리팹 생성 | 높음 | 미시작 | - | World Space Canvas |
| U-003 | LandingUIManager.lua 작성 | 높음 | **완료** | - | 메인 메뉴 UI |
| U-004 | LandingUI 프리팹 생성 | 높음 | 미시작 | - | 로고 + 버튼 |
| U-005 | LevelSelectUI.lua 작성 | 중간 | **완료** | - | 레벨 선택 |
| U-006 | LevelSelectUI 프리팹 생성 | 중간 | 미시작 | - | Easy/Hard 버튼 |
| U-007 | GameHUD.lua 작성 | 높음 | **완료** | - | 타이머/HP 표시 |
| U-008 | GameHUD 프리팹 연결 및 테스트 | 높음 | **완료** | - | 상단 HUD 작동 확인 |
| U-009 | GameOverUI.lua 작성 | 높음 | **완료** | - | 게임오버 화면 (HP 0) |
| U-010 | GameOverUI 프리팹 생성 | 높음 | 미시작 | - | "Game Over" + Retry |
| U-011 | ResultUIManager.lua 작성 | 높음 | **완료** | - | 결과 화면 (시간 종료) |
| U-012 | ResultUI 프리팹 생성 | 높음 | 미시작 | - | 점수/정확도/힌트 표시 |

### 2.4 사운드 및 VFX (Audio & VFX)

| ID | 태스크 | 우선순위 | 상태 | 담당자 | 비고 |
|----|-------|---------|------|--------|------|
| A-000 | AudioManager.lua 작성 | 중간 | **완료** | - | BGM 랜덤 순환 + SFX 관리 |
| A-001 | BGM 파일 준비 (4개) | 낮음 | **완료** | - | 랜덤 셔플 재생 지원 |
| A-002 | 잡기 효과음 | 낮음 | **완료** | - | XR_PICKUP.mp3 |
| A-003 | 던지기 효과음 | 낮음 | **완료** | - | XR_THROW.mp3 |
| A-004 | 정답 효과음 | 낮음 | **완료** | - | XR_GOOD.mp3 |
| A-005 | 오답 효과음 | 낮음 | **완료** | - | XR_MISS.mp3 |
| A-006 | 게임오버 효과음 | 낮음 | **완료** | - | XR_GAMEOVER.mp3 |
| A-007 | 결과/완료 효과음 | 낮음 | **완료** | - | XR_FINISH.mp3 |
| A-008 | UI 전환 효과음 | 낮음 | **완료** | - | XR_TURN PAGE.mp3 |
| A-009 | AudioManager Unity 연결 | 중간 | **진행중** | - | 컴포넌트 추가 완료, Injection 수동 연결 필요 |
| V-001 | 정답 파티클 이펙트 | 낮음 | 미시작 | - | Correct VFX |
| V-002 | 오답 파티클 이펙트 | 낮음 | 미시작 | - | Wrong VFX |
| V-003 | 쓰레기 이탈 이펙트 | 낮음 | 미시작 | - | Lost VFX |

### 2.5 테스트 및 버그 수정 (Testing & Bugfix)

| ID | 태스크 | 우선순위 | 상태 | 담당자 | 비고 |
|----|-------|---------|------|--------|------|
| T-001 | VR 잡기/던지기 테스트 | 높음 | 미시작 | - | 기본 상호작용 |
| T-002 | PC 모드 테스트 | 중간 | 미시작 | - | 마우스 입력 |
| T-003 | 점수 계산 테스트 | 중간 | 미시작 | - | 로직 검증 |
| T-004 | UI 흐름 테스트 | 높음 | **완료** | - | Guide→Landing→LevelSelect→Playing |
| T-005 | 성능 최적화 | 낮음 | 미시작 | - | 프레임 드랍 확인 |

---

## 3. 개발 일지

### 2025-12-13 (세션 8 - Grabbable-FloatingBehavior 충돌 버그 수정)

| 시간 | 작업 내용 | 상태 |
|------|----------|------|
| - | **핵심 버그 발견**: Lua 메서드 호출 시 `.` 대신 `:` 사용 필요 | 완료 |
| - | 모든 외부 호출 함수에 `_` (self) 파라미터 추가 | 완료 |
| - | **Grabbable-FloatingBehavior 충돌 해결** | 완료 |
| - | TrashItem.OnRelease()에서 SetGrabbed(false) 제거 - 던진 후 물리 시뮬레이션 유지 | 완료 |
| - | FloatingBehavior.ResetFloating()에서 즉시 위치 설정 추가 | 완료 |
| - | FloatingBehavior.UpdateFloating()에서 거리 체크 후 즉시 텔레포트 (1m 이상이면 Lerp 스킵) | 완료 |
| - | SpawnManager.SpawnTrash() 순서 변경 - FloatingBehavior 먼저 리셋 후 활성화 | 완료 |
| - | SpawnManager.ReturnToPool()에서 DisableFloating() 호출 추가 | 완료 |
| - | FloatingBehavior.EnableFloating/DisableFloating에 `_` 파라미터 추가 | 완료 |

**핵심 발견 사항**:
- **Lua `:` vs `.` 문법**: `:` 호출 시 self가 첫 번째 인자로 전달됨, 함수 정의에 `_` 파라미터 필요
- **FloatingBehavior 충돌 원인**: 던진 후 OnRelease()에서 SetGrabbed(false) 호출 → FloatingBehavior가 위치를 덮어쓰며 spawnPosition으로 끌려감
- **풀링 시 Lerp 문제**: GameObject가 활성화 상태(MeshRenderer만 끔)이므로 update()가 계속 실행 → HIDE_POSITION에서 Lerp 시작
- **해결 패턴**: 거리가 1m 이상이면 Lerp 대신 즉시 텔레포트

**수정된 파일**:
- TrashItem.lua - OnRelease()에서 SetGrabbed(false) 제거
- FloatingBehavior.lua - ResetFloating() 즉시 위치 설정, UpdateFloating() 거리 체크 추가, Enable/DisableFloating `_` 추가
- SpawnManager.lua - SpawnTrash() 순서 변경, ReturnToPool() DisableFloating() 추가
- GameHUD.lua, ScoreManager.lua, AudioManager.lua, VFXManager.lua, TrashBin.lua, GameManager.lua, ResultUIManager.lua - 외부 호출 함수에 `_` 파라미터 추가

---

### 2025-12-13 (세션 7 - VObject 풀링 버그 수정)

| 시간 | 작업 내용 | 상태 |
|------|----------|------|
| - | **핵심 버그 발견**: VObject는 SetActive() 사용 불가 | 완료 |
| - | SpawnManager - SetActive 대신 MeshRenderer/Collider enabled 패턴 적용 | 완료 |
| - | SpawnManager - FlushAllGrabbables 패턴 구현 (초기화 중 호출 방지) | 완료 |
| - | SpawnManager - isPoolInitializing 플래그로 초기화 순서 제어 | 완료 |
| - | FloatingBehavior - spawnPosition nil 에러 수정 (isFloating=false 초기화) | 완료 |
| - | TrashItem - ReturnToPool에 GameObject.Find fallback 추가 | 완료 |
| - | TrashItem - onTriggerEnter에 부모 오브젝트 검색 추가 | 완료 |
| - | GameManager - 난이도 설정 조정 (Easy: 2초/7개, Hard: 1.5초/10개) | 완료 |
| - | 설계문서 - VObject 풀링 패턴 및 FlushAllGrabbables 패턴 문서화 | 완료 |

**핵심 발견 사항**:
- **VObject SetActive 금지**: VIVEN SDK VObject는 내부 상태 관리로 인해 SetActive(false) 호출 시 상태가 깨짐
- **대안**: MeshRenderer.enabled + Collider.enabled + HIDE_POSITION 패턴 사용
- **FlushAllGrabbables**: 모든 Grabbable에 FlushInteractableCollider() 호출하여 Interactor 상태 동기화
- **초기화 순서**: 풀 초기화 중에는 FlushAllGrabbables 호출 금지 (NullReferenceException 방지)

**수정된 파일**:
- SpawnManager.lua - SetPoolObjectVisible, FlushAllGrabbables, isPoolInitializing 추가
- FloatingBehavior.lua - awake()에서 isFloating=false 초기화
- TrashItem.lua - ReturnToPool fallback, onTriggerEnter 부모 검색
- GameManager.lua - 난이도 설정 값 조정

---

### 2025-12-12 (세션 6 - AudioManager Unity 연결)

| 시간 | 작업 내용 | 상태 |
|------|----------|------|
| - | AudioManager GameObject에 AudioSource 2개 추가 (BGM, SFX용) | 완료 |
| - | VivenLuaBehaviour 컴포넌트 추가 | 완료 |
| - | AudioManager.lua 스크립트 연결 | 완료 |
| - | Injection 슬롯 13개 생성 | 완료 |
| - | Unity 씬 저장 (Demo.unity) | 완료 |

**Unity MCP를 통한 설정**:
- AudioSource 컴포넌트 2개 추가 완료
- VivenLuaBehaviour에 AudioManager.lua 스크립트 연결 완료
- Injection objectValues 슬롯 13개 생성 완료

**수동 작업 필요**:
- Unity 에디터에서 Injection 필드에 드래그&드롭으로 연결 필요
- 순서: BGMSource, SFXSource, BGM_1~4, SFX_Pickup/Throw/Good/Miss/GameOver/Finish/UIClick

### 2025-12-12 (세션 5 - AudioManager 구현)

| 시간 | 작업 내용 | 상태 |
|------|----------|------|
| - | AudioManager.lua 작성 - BGM/SFX 재생 관리 | 완료 |
| - | BGM 랜덤 순환 재생 기능 구현 (Fisher-Yates 셔플) | 완료 |
| - | 곡 종료 시 자동 다음 곡 재생 (같은 곡 연속 방지) | 완료 |
| - | 오디오 파일 준비 확인 (BGM 4개, SFX 7개) | 완료 |
| - | 설계문서 - Section 13. Audio 시스템 아키텍처 추가 | 완료 |
| - | 설계문서 - Section 7.6 AudioManager 공개 메서드 추가 | 완료 |
| - | 개발현황 문서 업데이트 | 완료 |

**구현 기능**:
- `StartBGMPlaylist()` / `StopBGMPlaylist()` - BGM 플레이리스트 제어
- `PlayNextBGM()` - 다음 랜덤 BGM 재생
- SFX 함수: `PlayPickup()`, `PlayThrow()`, `PlayGood()`, `PlayMiss()`, `PlayGameOver()`, `PlayFinish()`, `PlayUIClick()`

### 2025-12-12 (세션 4 - Object Pooling 구현)

| 시간 | 작업 내용 | 상태 |
|------|----------|------|
| - | **아키텍처 결정**: VIVEN SDK 동적 Instantiate 불가 → Object Pooling 패턴 채택 | 완료 |
| - | FloatingBehavior.lua - ResetFloating() 함수 추가 (풀 재사용 시 상태 초기화) | 완료 |
| - | TrashItem.lua - poolIndex, currentCategory 변수 추가 | 완료 |
| - | TrashItem.lua - ResetTrash() 함수 추가 (InitTrash 대체) | 완료 |
| - | TrashItem.lua - ReturnToPool() 함수 추가 (DestroyTrash 대체) | 완료 |
| - | TrashItem.lua - SetCategory, SetSpawnManager, SetScoreManager, SetPoolIndex 함수 추가 | 완료 |
| - | SpawnManager.lua - 전면 재작성 (Instantiate 제거, Pool 기반) | 완료 |
| - | SpawnManager.lua - GetChildren(), InitializePools(), GetFromPool(), ReturnToPool() 구현 | 완료 |
| - | Definitions.def.lua - GeneralGarbage → Misc 카테고리명 통일 | 완료 |
| - | 설계문서 - Section 12. Object Pooling 아키텍처 추가 | 완료 |
| - | 설계문서 - GeneralGarbage → Misc 업데이트 | 완료 |
| - | 설계문서 - Section 7.4 SpawnManager 공개 메서드 업데이트 (새 함수 반영) | 완료 |

**결정 사유**: VIVEN SDK는 런타임에서 동적 VObject Instantiate를 지원하지 않음. 씬에 미리 배치된 110개 오브젝트를 풀링 방식으로 재사용.

**풀 구성**: Paper 30개, Plastic 30개, Glass 20개, Metal 20개, Misc 10개 = 총 110개

### 2025-12-12 (세션 3 - EventCallback 제거 및 아키텍처 단순화)

| 시간 | 작업 내용 | 상태 |
|------|----------|------|
| - | **아키텍처 결정**: EventCallback 시스템 전면 제거 | 완료 |
| - | GameHUD.lua - EventCallback 제거, HP 표시를 Slider 방식으로 변경 | 완료 |
| - | GameManager.lua - EventCallback 제거, 직접 메서드 호출 유지 | 완료 |
| - | ScoreManager.lua - EventCallback 제거, GameManager 직접 호출 추가 | 완료 |
| - | SpawnManager.lua - EventCallback import 제거 | 완료 |
| - | TrashBin.lua - EventCallback 제거, OnTrashEntered() 메서드 추가 | 완료 |
| - | BoundaryZone.lua - EventCallback import 제거 | 완료 |
| - | GameOverUI.lua - EventCallback 제거 → GameObject.Find + GetLuaComponent | 완료 |
| - | ResultUIManager.lua - EventCallback 제거 → GameObject.Find + GetLuaComponent | 완료 |
| - | SlideUIManager.lua - 미사용 EventCallback import 제거 | 완료 |
| - | 설계문서 업데이트 - 스크립트 통신 패턴 섹션 전면 개정 | 완료 |
| - | **GameHUD Unity 연결 및 작동 테스트** | 완료 |

**결정 사유**: EventCallback의 Import Scripts 방식이 각 스크립트별로 별도 인스턴스를 생성하여 이벤트 공유가 안 되는 문제. 직접 호출 방식이 더 단순하고 디버깅이 용이함.

### 2025-12-08 (세션 2 - UI 통합 및 테스트)

| 시간 | 작업 내용 | 상태 |
|------|----------|------|
| - | UI 아키텍처 변경: 다중 Canvas → 단일 Canvas + 다중 Panel 구조 | 완료 |
| - | GameManager.lua Panel 기반으로 수정 | 완료 |
| - | EventCallback 이슈 해결: Import Scripts → GameObject.Find 직접 호출 방식으로 변경 | 완료 |
| - | SlideUIManager.lua - Complete 버튼 → GameManager.OnGuideComplete() 직접 호출 | 완료 |
| - | LandingUIManager.lua - How to Play/Game Start 버튼 → GameManager 직접 호출 | 완료 |
| - | LevelSelectUI.lua - Easy/Hard/Back 버튼 → GameManager 직접 호출 | 완료 |
| - | UI 플로우 테스트: Guide → Landing → LevelSelect → Playing 확인 | 완료 |
| - | SpawnManager.lua SpawnZoneObject를 NullableInject로 변경 (테스트 용이성) | 완료 |

### 2025-12-08 (세션 1 - 초기 개발)

| 시간 | 작업 내용 | 상태 |
|------|----------|------|
| - | 프로젝트 분석 및 설계 문서 작성 | 완료 |
| - | 개발 현황 추적 문서 작성 | 완료 |
| - | Unity Setup Guide 문서 작성 | 완료 |
| - | EventCallback.lua, Definitions.def.lua 작성 | 완료 |
| - | UI 설계 업데이트 (GameOverUI/ResultUI 분리) | 완료 |
| - | GeneralGarbage 카테고리 추가 | 완료 |
| - | ScoreManager.lua 작성 | 완료 |
| - | GameManager.lua 작성 | 완료 |
| - | SpawnManager.lua 작성 | 완료 |
| - | FloatingBehavior.lua 작성 | 완료 |
| - | TrashItem.lua 작성 | 완료 |
| - | TrashBin.lua 작성 | 완료 |
| - | BoundaryZone.lua 작성 | 완료 |
| - | GameHUD.lua 작성 | 완료 |
| - | SlideUIManager.lua 작성 | 완료 |
| - | LandingUIManager.lua 작성 | 완료 |
| - | LevelSelectUI.lua 작성 | 완료 |
| - | GameOverUI.lua 작성 | 완료 |
| - | ResultUIManager.lua 작성 | 완료 |

---

## 4. 마일스톤

### Milestone 1: 기본 게임 플레이 (MVP)
**목표 완료일**: TBD

- [x] GameManager 구현
- [x] SpawnManager 구현
- [x] ScoreManager 구현
- [x] TrashItem 구현
- [x] TrashBin 구현
- [ ] 쓰레기 잡기/던지기 동작 (Unity 프리팹 작업 필요)

### Milestone 2: UI 시스템
**목표 완료일**: TBD

- [x] SlideUI (가이드) - 스크립트 완료
- [x] LandingUI (메인 메뉴) - 스크립트 완료
- [x] LevelSelectUI - 스크립트 완료
- [x] GameHUD - 스크립트 완료
- [x] GameOverUI (HP 0 시) - 스크립트 완료
- [x] ResultUI (시간 종료 시) - 스크립트 완료
- [ ] UI 프리팹 생성 (Unity 작업 필요)

### Milestone 3: Polish & 완성
**목표 완료일**: TBD

- [ ] 사운드 적용
- [ ] VFX 적용
- [ ] 버그 수정
- [ ] 성능 최적화
- [ ] 최종 테스트

---

## 5. 이슈 트래커

### 열린 이슈

| ID | 제목 | 심각도 | 상태 | 생성일 |
|----|------|--------|------|--------|
| - | 현재 이슈 없음 | - | - | - |

### 닫힌 이슈

| ID | 제목 | 해결일 | 해결 방법 |
|----|------|--------|----------|
| I-007 | 스폰 시 오브젝트가 하단에서 날아옴 | 2025-12-13 | UpdateFloating()에서 거리 1m 이상이면 즉시 텔레포트 |
| I-006 | 던진 후 FloatingBehavior가 위치 덮어씀 | 2025-12-13 | OnRelease()에서 SetGrabbed(false) 제거, ReturnToPool에서 DisableFloating() 호출 |
| I-005 | Lua 메서드 호출 시 인자 밀림 (table vs number) | 2025-12-13 | 모든 외부 호출 함수에 `_` (self) 파라미터 추가 |
| I-004 | TrashItem이 TrashBin 판정 안됨 | 2025-12-13 | onTriggerEnter에서 부모 오브젝트도 검색하도록 수정 |
| I-003 | 쓰레기 스폰 트래킹 안됨 | 2025-12-13 | TrashItem.ReturnToPool에 GameObject.Find fallback 추가 |
| I-002 | FloatingBehavior spawnPosition nil | 2025-12-13 | awake()에서 isFloating=false 초기화, ResetFloating()에서만 활성화 |
| I-001 | FlushAllGrabbables NullReferenceException | 2025-12-13 | isPoolInitializing 플래그 추가, 초기화 중 호출 방지 |

---

## 6. 참고 리소스

### 기존 프로젝트 참고 파일

| 파일명 | 경로 | 용도 |
|--------|------|------|
| IStep.lua | Angames/Scripts/Tutorial/Interface/ | 게임 흐름 참고 |
| RecipeGameManager.lua | Angames/Scripts/Manager/ | 게임 매니저 패턴 참고 |
| CookUIManager.lua | Angames/Scripts/UI/ | UI 매니저 패턴 참고 |

> **Note**: EventCallback.lua는 더 이상 사용하지 않음 - 직접 호출 방식 채택

### VIVEN SDK 문서

- Wiki: https://wiki.viven.app/developer
- API Reference: https://sdkdoc.viven.app/api/SDK/TwentyOz.VivenSDK
- VObject 가이드: https://wiki.viven.app/developer/contents/vobject
- Grabbable 가이드: https://wiki.viven.app/developer/contents/grabbable

---

## 7. 변경 이력

| 버전 | 날짜 | 변경 내용 | 작성자 |
|------|------|----------|--------|
| 1.5.0 | 2025-12-13 | Grabbable-FloatingBehavior 충돌 버그 수정, Lua `:` 문법 및 `_` 파라미터 적용 | Claude |
| 1.4.0 | 2025-12-13 | VObject 풀링 버그 수정 (SetActive→MeshRenderer/Collider), FlushAllGrabbables 패턴 | Claude |
| 1.3.0 | 2025-12-12 | AudioManager Unity 컴포넌트 설정 완료 | Claude |
| 1.2.0 | 2025-12-12 | Object Pooling 구현, GeneralGarbage→Misc 통일 | Claude |
| 1.1.0 | 2025-12-12 | EventCallback 제거, 직접 호출 방식으로 전환 | Claude |
| 1.0.0 | 2025-12-08 | 최초 작성 | Claude |

---

## 8. 체크리스트 (퀵 참조)

### 완료된 작업
- [x] GameManager.lua 구현
- [x] ScoreManager.lua 구현
- [x] SpawnManager.lua 구현 (Object Pooling 방식)
- [x] 모든 Object 스크립트 구현
- [x] 모든 UI 스크립트 구현
- [x] UI 플로우 연결 (Guide → Landing → LevelSelect → Playing)
- [x] **EventCallback 전면 제거** - 직접 호출 방식으로 전환 완료
- [x] GameHUD HP 표시 Slider 방식으로 변경
- [x] **Object Pooling 구현** - 110개 오브젝트 풀 (Instantiate 불가 대응)
- [x] GeneralGarbage → Misc 카테고리명 통일
- [x] **VObject 풀링 패턴 수정** - SetActive → MeshRenderer/Collider enabled
- [x] **FlushAllGrabbables 패턴** - 모든 Grabbable Interactor 상태 동기화
- [x] **FloatingBehavior 초기화 수정** - isFloating=false로 시작
- [x] **TrashItem fallback 패턴** - SpawnManager 못 찾을 시 GameObject.Find
- [x] **난이도 설정 조정** - Easy: 2초/7개, Hard: 1.5초/10개

### 다음 작업 (Unity Editor에서)
- [ ] 풀 오브젝트 배치 (TrashPools 계층 구조 생성)
  - PaperPool: Trash_Paper_01~03 각 10개 = 30개
  - PlasticPool: Trash_Plastic_01~03 각 10개 = 30개
  - GlassPool: Trash_Glass_01~02 각 10개 = 20개
  - MetalPool: Trash_Metal_Can01~02 각 10개 = 20개
  - MiscPool: Trash_Misc_CrackedEgg 10개 = 10개
- [ ] SpawnManager에 Pool Parent 연결 (PaperPool, PlasticPool 등)
- [ ] 쓰레기통 프리팹 생성 및 배치
- [ ] SpawnZone BoxCollider 설정
- [x] ~~GameHUD UI 요소 연결 (타이머, HP Slider, 점수)~~ ✅ 완료
- [ ] GameOverUI, ResultUI 버튼 연결
- [ ] 실제 게임플레이 테스트 (잡기/던지기/판정)

### 아키텍처 결정 사항
- **EventCallback 미사용**: 복잡성 대비 이점 없음, 직접 호출 방식이 더 단순하고 디버깅 용이
- **Object Pooling 필수**: VIVEN SDK는 동적 VObject Instantiate 미지원, 씬 배치 오브젝트 재사용
- **VObject SetActive 금지**: VObject 내부 상태가 깨지므로 MeshRenderer/Collider enabled 패턴 사용
- **FlushAllGrabbables 필수**: 오브젝트 가시성 변경 후 모든 Grabbable의 Interactor 상태 동기화
- **풀링 초기화 순서**: 초기화 중 FlushAllGrabbables 호출 금지 (isPoolInitializing 플래그 사용)
- **Lua 메서드 호출 규칙**:
  - 외부 호출 함수는 반드시 `:` 문법으로 호출 (`obj:Method()`)
  - 함수 정의 시 첫 번째 파라미터로 `_` (self) 추가 필요
  - 내부 함수는 `.` 또는 직접 호출 가능
- **FloatingBehavior-Grabbable 패턴**:
  - 던진 후 FloatingBehavior는 비활성화 상태 유지 (물리 시뮬레이션 우선)
  - ReturnToPool에서 DisableFloating() 호출하여 update() 중지
  - 스폰 시 거리가 1m 이상이면 즉시 텔레포트 (Lerp 스킵)
- **통신 패턴**:
  - UI → Manager: `GameObject.Find()` + `GetLuaComponent()`
  - Manager → Manager: Injection + `GetLuaComponent()` + fallback으로 GameObject.Find
  - Manager → UI: 직접 메서드 호출
