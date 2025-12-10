--- GameManager: 메인 게임 로직 관리
--- 게임 상태, 타이머, 게임 흐름을 관리하는 핵심 매니저

-- EventCallback 모듈 로드 (Import Scripts에서 EventCallback 추가 필요)
local GameEvent = ImportLuaScript(EventCallback)

--region Injection list
local _INJECTED_ORDER = 0
local function checkInject(OBJECT)
    _INJECTED_ORDER = _INJECTED_ORDER + 1
    assert(OBJECT, _INJECTED_ORDER .. "th object is missing")
    return OBJECT
end
local function NullableInject(OBJECT)
    _INJECTED_ORDER = _INJECTED_ORDER + 1
    if OBJECT == nil then
        Debug.Log(_INJECTED_ORDER .. "th object is missing")
    end
    return OBJECT
end

---@type GameObject
---@details ScoreManager 오브젝트
ScoreManagerObject = NullableInject(ScoreManagerObject)

---@type GameObject
---@details SpawnManager 오브젝트
SpawnManagerObject = NullableInject(SpawnManagerObject)

---@type GameObject
---@details SlideUI 패널 (Guide/How to Play)
SlideUIPanel = NullableInject(SlideUIPanel)

---@type GameObject
---@details LandingUI 패널 (메인 메뉴)
LandingUIPanel = NullableInject(LandingUIPanel)

---@type GameObject
---@details LevelSelectUI 패널 (난이도 선택)
LevelSelectUIPanel = NullableInject(LevelSelectUIPanel)

---@type GameObject
---@details GameHUD 패널 (게임 진행 중 HUD)
GameHUDPanel = NullableInject(GameHUDPanel)

---@type GameObject
---@details GameOverUI 패널 (게임오버)
GameOverUIPanel = NullableInject(GameOverUIPanel)

---@type GameObject
---@details ResultUI 패널 (결과 화면)
ResultUIPanel = NullableInject(ResultUIPanel)

--endregion

--region Variables

local util = require 'xlua.util'

---@alias GameState "Idle"|"Guide"|"Landing"|"LevelSelect"|"Playing"|"Paused"|"GameOver"|"TimeUp"|"Result"

---@type GameState
---@details 현재 게임 상태
local currentState = "Idle"

---@type string
---@details 현재 난이도 ("Easy" | "Hard")
local currentDifficulty = "Easy"

---@type number
---@details 게임 남은 시간 (초)
local remainingTime = 300

---@type number
---@details 게임 총 시간 (초)
local totalGameTime = 300

---@type boolean
---@details 타이머 실행 중 여부
local isTimerRunning = false

---@type table
---@details 난이도별 설정
local difficultySettings = {
    Easy = {
        gameTime = 300,
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

---@type ScoreManager
local scoreManager = nil

---@type SpawnManager
local spawnManager = nil

---@type table
---@details UI 매니저 참조들
local uiManagers = {}

---@type any
---@details 타이머 코루틴 참조
local timerCoroutine = nil

--endregion

--region Unity Lifecycle

function awake()
    -- 매니저 참조 가져오기
    if ScoreManagerObject then
        scoreManager = ScoreManagerObject:GetLuaComponent("ScoreManager")
    end
    if SpawnManagerObject then
        spawnManager = SpawnManagerObject:GetLuaComponent("SpawnManager")
    end

    -- UI 매니저 참조 가져오기 (각 Panel에서 Lua 컴포넌트 가져오기)
    if SlideUIPanel then
        uiManagers.slideUI = SlideUIPanel:GetLuaComponent("SlideUIManager")
    end
    if LandingUIPanel then
        uiManagers.landingUI = LandingUIPanel:GetLuaComponent("LandingUIManager")
    end
    if LevelSelectUIPanel then
        uiManagers.levelSelectUI = LevelSelectUIPanel:GetLuaComponent("LevelSelectUI")
    end
    if GameHUDPanel then
        uiManagers.gameHUD = GameHUDPanel:GetLuaComponent("GameHUD")
    end
    if GameOverUIPanel then
        uiManagers.gameOverUI = GameOverUIPanel:GetLuaComponent("GameOverUI")
    end
    if ResultUIPanel then
        uiManagers.resultUI = ResultUIPanel:GetLuaComponent("ResultUIManager")
    end
end

function start()
    -- 이벤트 리스너 등록
    RegisterEventListeners()

    -- 모든 UI 먼저 숨기기
    HideAllUI()

    -- 초기 상태 설정 (Guide UI만 표시)
    ChangeState("Guide")

    Debug.Log("[GameManager] Initialized - Starting with Guide UI")
end

function onEnable()
    RegisterEventListeners()
end

function onDisable()
    UnregisterEventListeners()
end

--endregion

--region Event Listeners

function RegisterEventListeners()
    Debug.Log("[GameManager] Registering event listeners...")
    GameEvent.registerEvent("onGameOver", OnGameOverEvent)
    GameEvent.registerEvent("onGuideComplete", OnGuideComplete)
    GameEvent.registerEvent("onGoToGuide", OnGoToGuide)
    GameEvent.registerEvent("onLevelSelected", OnLevelSelected)
    GameEvent.registerEvent("onRetryGame", OnRetryGame)
    GameEvent.registerEvent("onGoToMain", OnGoToMain)
    Debug.Log("[GameManager] Event listeners registered")
end

function UnregisterEventListeners()
    GameEvent.unregisterEvent("onGameOver", OnGameOverEvent)
    GameEvent.unregisterEvent("onGuideComplete", OnGuideComplete)
    GameEvent.unregisterEvent("onGoToGuide", OnGoToGuide)
    GameEvent.unregisterEvent("onLevelSelected", OnLevelSelected)
    GameEvent.unregisterEvent("onRetryGame", OnRetryGame)
    GameEvent.unregisterEvent("onGoToMain", OnGoToMain)
end

---@details 게임오버 이벤트 핸들러
---@param reason string 게임오버 사유
function OnGameOverEvent(reason)
    if reason == "HP_ZERO" then
        ChangeState("GameOver")
    end
end

---@details 가이드 완료 이벤트 핸들러
function OnGuideComplete()
    Debug.Log("[GameManager] OnGuideComplete received!")
    ChangeState("Landing")
end

---@details 가이드로 이동 이벤트 핸들러
function OnGoToGuide()
    Debug.Log("[GameManager] OnGoToGuide called")
    ChangeState("Guide")
end

---@details 레벨 선택 이벤트 핸들러
---@param difficulty string 선택한 난이도
function OnLevelSelected(difficulty)
    Debug.Log("[GameManager] OnLevelSelected called: " .. tostring(difficulty))
    currentDifficulty = difficulty or "Easy"
    StartGame()
end

---@details 재시작 이벤트 핸들러
function OnRetryGame()
    StartGame()
end

---@details 메인으로 이동 이벤트 핸들러
function OnGoToMain()
    Debug.Log("[GameManager] OnGoToMain called")
    ChangeState("Landing")
end

--endregion

--region State Management

---@details 게임 상태 변경
---@param newState GameState 새로운 상태
function ChangeState(newState)
    local previousState = currentState
    currentState = newState

    Debug.Log("[GameManager] State changed: " .. previousState .. " -> " .. newState)

    -- 모든 UI 비활성화
    HideAllUI()

    -- 새 상태에 따른 처리
    if newState == "Guide" then
        ShowUI("slideUI")
    elseif newState == "Landing" then
        ShowUI("landingUI")
    elseif newState == "LevelSelect" then
        ShowUI("levelSelectUI")
    elseif newState == "Playing" then
        ShowUI("gameHUD")
    elseif newState == "Paused" then
        -- 일시정지 UI 표시 (GameHUD 유지)
        ShowUI("gameHUD")
    elseif newState == "GameOver" then
        StopGame()
        ShowUI("gameOverUI")
    elseif newState == "TimeUp" then
        StopGame()
        ShowUI("resultUI")
        -- 결과 데이터 전달
        if uiManagers.resultUI and scoreManager then
            local result = scoreManager.GetGameResult()
            uiManagers.resultUI.ShowResult(result)
        end
    elseif newState == "Result" then
        ShowUI("resultUI")
    end

    -- 이벤트 발생
    GameEvent.invoke("onStateChanged", newState, previousState)
end

---@details 현재 상태 반환
---@return GameState
function GetCurrentState()
    return currentState
end

--endregion

--region Game Flow

---@details 게임 시작
function StartGame()
    local settings = difficultySettings[currentDifficulty]
    if not settings then
        settings = difficultySettings["Easy"]
    end

    -- 게임 시간 설정
    totalGameTime = settings.gameTime
    remainingTime = totalGameTime

    -- ScoreManager 초기화
    if scoreManager then
        scoreManager.InitScore(settings)
    end

    -- SpawnManager 초기화 및 시작
    if spawnManager then
        Debug.Log("[GameManager] SpawnManager found, calling InitSpawn")
        spawnManager.InitSpawn(settings)
        spawnManager.StartSpawning()
    else
        Debug.Log("[GameManager] WARNING: SpawnManager is nil! Check SpawnManagerObject injection")
    end

    -- 상태 변경
    ChangeState("Playing")

    -- 타이머 시작
    StartTimer()

    -- 이벤트 발생
    GameEvent.invoke("onGameStart", currentDifficulty)

    Debug.Log("[GameManager] Game started - Difficulty: " .. currentDifficulty)
end

---@details 게임 정지
function StopGame()
    -- 타이머 정지
    StopTimer()

    -- SpawnManager 정지
    if spawnManager then
        spawnManager.StopSpawning()
    end

    Debug.Log("[GameManager] Game stopped")
end

---@details 게임 일시정지
function PauseGame()
    if currentState ~= "Playing" then
        return
    end

    isTimerRunning = false
    ChangeState("Paused")

    -- SpawnManager 일시정지
    if spawnManager then
        spawnManager.PauseSpawning()
    end

    GameEvent.invoke("onGamePause")
    Debug.Log("[GameManager] Game paused")
end

---@details 게임 재개
function ResumeGame()
    if currentState ~= "Paused" then
        return
    end

    ChangeState("Playing")
    isTimerRunning = true

    -- SpawnManager 재개
    if spawnManager then
        spawnManager.ResumeSpawning()
    end

    GameEvent.invoke("onGameResume")
    Debug.Log("[GameManager] Game resumed")
end

---@details 레벨 선택 화면으로 이동
function GoToLevelSelect()
    ChangeState("LevelSelect")
end

---@details How to Play 화면으로 이동
function GoToGuide()
    ChangeState("Guide")
end

--endregion

--region Timer

---@details 타이머 시작
function StartTimer()
    isTimerRunning = true

    if timerCoroutine then
        self:StopCoroutine(timerCoroutine)
    end

    timerCoroutine = self:StartCoroutine(util.cs_generator(function()
        while isTimerRunning and remainingTime > 0 do
            coroutine.yield(WaitForSeconds(1))

            if isTimerRunning then
                remainingTime = remainingTime - 1

                -- UI 업데이트
                if uiManagers.gameHUD then
                    uiManagers.gameHUD.UpdateTimer(remainingTime)
                end

                -- 이벤트 발생
                GameEvent.invoke("onTimerUpdate", remainingTime)
            end
        end

        -- 시간 종료
        if remainingTime <= 0 and currentState == "Playing" then
            ChangeState("TimeUp")
        end
    end))
end

---@details 타이머 정지
function StopTimer()
    isTimerRunning = false
    if timerCoroutine then
        self:StopCoroutine(timerCoroutine)
        timerCoroutine = nil
    end
end

---@details 남은 시간 반환
---@return number
function GetRemainingTime()
    return remainingTime
end

---@details 남은 시간을 MM:SS 형식으로 반환
---@return string
function GetFormattedTime()
    local minutes = math.floor(remainingTime / 60)
    local seconds = remainingTime % 60
    return string.format("%02d:%02d", minutes, seconds)
end

--endregion

--region UI Management

---@details 모든 UI 패널 비활성화
function HideAllUI()
    if SlideUIPanel then SlideUIPanel:SetActive(false) end
    if LandingUIPanel then LandingUIPanel:SetActive(false) end
    if LevelSelectUIPanel then LevelSelectUIPanel:SetActive(false) end
    if GameHUDPanel then GameHUDPanel:SetActive(false) end
    if GameOverUIPanel then GameOverUIPanel:SetActive(false) end
    if ResultUIPanel then ResultUIPanel:SetActive(false) end
end

---@details 특정 UI 패널 표시
---@param uiName string UI 이름
function ShowUI(uiName)
    if uiName == "slideUI" and SlideUIPanel then
        SlideUIPanel:SetActive(true)
    elseif uiName == "landingUI" and LandingUIPanel then
        LandingUIPanel:SetActive(true)
    elseif uiName == "levelSelectUI" and LevelSelectUIPanel then
        LevelSelectUIPanel:SetActive(true)
    elseif uiName == "gameHUD" and GameHUDPanel then
        GameHUDPanel:SetActive(true)
    elseif uiName == "gameOverUI" and GameOverUIPanel then
        GameOverUIPanel:SetActive(true)
    elseif uiName == "resultUI" and ResultUIPanel then
        ResultUIPanel:SetActive(true)
    end
end

--endregion

--region Getters

---@details 현재 난이도 반환
---@return string
function GetCurrentDifficulty()
    return currentDifficulty
end

---@details 난이도 설정 반환
---@param difficulty string 난이도
---@return table
function GetDifficultySettings(difficulty)
    return difficultySettings[difficulty or currentDifficulty]
end

--endregion
