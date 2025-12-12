# Recycle Dunk - 개발 현황 추적 문서

**프로젝트명**: Recycle Dunk
**버전**: 1.1.0
**최종 수정일**: 2025-12-12

---

## 1. 개발 진행 현황 요약

### 전체 진행률: 65%

| 카테고리 | 진행률 | 상태 |
|---------|--------|------|
| 핵심 시스템 | 100% | **완료** (AudioManager 추가) |
| UI 시스템 | 80% | **진행중** (GameHUD 연결 완료, 작동 확인) |
| 게임 오브젝트 | 36% | 진행중 |
| 사운드/VFX | 50% | **진행중** (AudioManager 완료, 오디오 파일 준비 완료) |
| 테스트/버그 수정 | 30% | **진행중** (GameHUD 테스트 완료) |

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
| A-009 | AudioManager Unity 연결 | 중간 | 미시작 | - | AudioSource + 클립 연결 필요 |
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
| - | 현재 이슈 없음 | - | - |

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
- **통신 패턴**:
  - UI → Manager: `GameObject.Find()` + `GetLuaComponent()`
  - Manager → Manager: Injection + `GetLuaComponent()`
  - Manager → UI: 직접 메서드 호출
