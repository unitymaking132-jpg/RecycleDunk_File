---@meta
-- Recycle Dunk 타입 정의 파일

-------------------------------------------------
-- 게임 상태 정의
-------------------------------------------------

---@alias GameState
---| "Idle"        # 초기 상태
---| "Guide"       # 가이드 UI 표시 중
---| "Landing"     # 랜딩 UI (메인 메뉴)
---| "LevelSelect" # 레벨 선택 화면
---| "Playing"     # 게임 진행 중
---| "Paused"      # 일시 정지
---| "GameOver"    # 게임 오버 (HP 0)
---| "TimeUp"      # 시간 종료
---| "Result"      # 결과 화면

-------------------------------------------------
-- 쓰레기 카테고리 정의
-------------------------------------------------

---@alias TrashCategory
---| "Paper"           # 종이류 (파란색)
---| "Plastic"         # 플라스틱 (빨간색)
---| "Glass"           # 유리 (초록색)
---| "Metal"           # 금속 (노란색)
---| "GeneralGarbage"  # 일반 쓰레기 (회색/검정)

-------------------------------------------------
-- 난이도 정의
-------------------------------------------------

---@alias DifficultyLevel
---| "Easy"  # 쉬움
---| "Hard"  # 어려움 (추후 개발)

-------------------------------------------------
-- 게임 설정 클래스
-------------------------------------------------

---@class GameSettings
---@field gameTime number 게임 시간 (초)
---@field startHP number 시작 HP
---@field spawnInterval number 쓰레기 스폰 간격 (초)
---@field maxTrashCount number 최대 동시 쓰레기 수
---@field correctScore number 정답 점수
---@field comboBonus number 콤보 보너스 점수
GameSettings = {}

-------------------------------------------------
-- 게임 결과 클래스
-------------------------------------------------

---@class GameResult
---@field totalScore number 총 점수
---@field correctCount number 정답 횟수
---@field wrongCount number 오답 횟수
---@field accuracy number 정확도 (0-100)
---@field maxCombo number 최대 콤보
---@field mostMissedCategory TrashCategory | nil 가장 많이 틀린 카테고리
---@field playTime number 플레이 시간 (초)
GameResult = {}

-------------------------------------------------
-- 쓰레기 아이템 데이터 클래스
-------------------------------------------------

---@class TrashItemData
---@field category TrashCategory 쓰레기 카테고리
---@field prefabPath string 프리팹 경로
---@field displayName string 표시 이름
TrashItemData = {}

-------------------------------------------------
-- 스폰 포인트 데이터 클래스
-------------------------------------------------

---@class SpawnPointData
---@field position Vector3 스폰 위치
---@field isOccupied boolean 점유 여부
SpawnPointData = {}

-------------------------------------------------
-- 점수 변경 이벤트 데이터
-------------------------------------------------

---@class ScoreChangeData
---@field previousScore number 이전 점수
---@field newScore number 새 점수
---@field change number 변경량
---@field reason string 변경 이유
ScoreChangeData = {}

-------------------------------------------------
-- HP 변경 이벤트 데이터
-------------------------------------------------

---@class HPChangeData
---@field previousHP number 이전 HP
---@field newHP number 새 HP
---@field change number 변경량
---@field reason string 변경 이유
HPChangeData = {}

-------------------------------------------------
-- 쓰레기 판정 결과 데이터
-------------------------------------------------

---@class TrashJudgementData
---@field trashCategory TrashCategory 쓰레기 카테고리
---@field binCategory TrashCategory 쓰레기통 카테고리
---@field isCorrect boolean 정답 여부
TrashJudgementData = {}

-------------------------------------------------
-- 난이도별 기본 설정
-------------------------------------------------

---@type table<DifficultyLevel, GameSettings>
DifficultySettings = {
    Easy = {
        gameTime = 60,
        startHP = 5,
        spawnInterval = 3,
        maxTrashCount = 5,
        correctScore = 100,
        comboBonus = 50
    },
    Hard = {
        gameTime = 90,
        startHP = 3,
        spawnInterval = 2,
        maxTrashCount = 8,
        correctScore = 150,
        comboBonus = 75
    }
}

-------------------------------------------------
-- 카테고리별 색상 정의
-------------------------------------------------

---@type table<TrashCategory, table>
CategoryColors = {
    Paper = { r = 0.2, g = 0.4, b = 0.8 },           -- 파란색
    Plastic = { r = 0.8, g = 0.2, b = 0.2 },         -- 빨간색
    Glass = { r = 0.2, g = 0.8, b = 0.3 },           -- 초록색
    Metal = { r = 0.9, g = 0.8, b = 0.2 },           -- 노란색
    GeneralGarbage = { r = 0.3, g = 0.3, b = 0.3 }   -- 회색
}

-------------------------------------------------
-- 카테고리별 힌트 메시지 정의
-------------------------------------------------

---@type table<TrashCategory, string>
CategoryHintMessages = {
    Paper = "Make sure paper is clean and dry!",
    Plastic = "Check if the plastic has recycling marks!",
    Glass = "Glass bottles should be emptied first!",
    Metal = "Cans should be rinsed before recycling!",
    GeneralGarbage = "Check the types of regular garbage again!"
}
