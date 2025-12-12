--- GameManager: 메인 게임 로직 관리
--- 게임 상태, 타이머, 게임 흐름을 관리하는 핵심 매니저
--- UI 스크립트들이 직접 이 매니저의 메서드를 호출함

--region Injection list
local _INJECTED_ORDER = 0
local function checkInject(OBJECT)
    _INJECTED_ORDER = _INJECTED_ORDER + 1
    assert(OBJECT, _INJECTED_ORDER .. "th object is missing")
    return OBJECT
end
local function NullableInject(OBJECT)
    _INJECTED_ORDER = _INJECTED_ORDER + 1
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

---@type GameObject
---@details AudioManager 오브젝트
AudioManagerObject = NullableInject(AudioManagerObject)

---@type GameObject
---@details VFXManager 오브젝트
VFXManagerObject = NullableInject(VFXManagerObject)

---@type GameObject
---@details Confetti 재생 위치용 Transform (선택, 없으면 카메라 앞)
ConfettiSpawnPoint = NullableInject(ConfettiSpawnPoint)

--endregion

--region Variables

local util = require 'xlua.util'

---@alias GameState "Idle"|"Guide"|"Landing"|"LevelSelect"|"Playing"|"Paused"|"GameOver"|"TimeUp"|"Result"

---@type GameState
local currentState = "Idle"

---@type string
local currentDifficulty = "Easy"

---@type number
local remainingTime = 60

---@type number
local totalGameTime = 60

---@type boolean
local isTimerRunning = false

---@type table
local difficultySettings = {
    Easy = {
        gameTime = 60,
        startHP = 5,
        spawnInterval = 2,      -- 3 → 2초 (더 자주 스폰)
        maxTrashCount = 7,      -- 5 → 7개 (더 많이)
        correctScore = 100,
        comboBonus = 50
    },
    Hard = {
        gameTime = 90,
        startHP = 3,
        spawnInterval = 1.5,    -- 2 → 1.5초 (더 빠르게)
        maxTrashCount = 10,     -- 8 → 10개 (더 많이)
        correctScore = 150,
        comboBonus = 75
    }
}

---@type ScoreManager
local scoreManager = nil

---@type SpawnManager
local spawnManager = nil

---@type table
local uiManagers = {}

---@type any
local timerCoroutine = nil

---@type AudioManager
---@details 오디오 매니저 참조
local audioManager = nil

---@type VFXManager
---@details VFX 매니저 참조
local vfxManager = nil

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

    -- UI 매니저 참조 가져오기
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

    -- AudioManager 참조 가져오기
    if AudioManagerObject then
        audioManager = AudioManagerObject:GetLuaComponent("AudioManager")
    end

    -- VFXManager 참조 가져오기
    if VFXManagerObject then
        vfxManager = VFXManagerObject:GetLuaComponent("VFXManager")
    end
end

function start()
    -- 모든 UI 먼저 숨기기
    HideAllUI()

    -- 초기 상태 설정 (Guide UI만 표시)
    ChangeState("Guide")
end

--endregion

--region Public Methods (UI에서 직접 호출)

---@details 가이드 완료 → Landing으로 이동
function OnGuideComplete()
    ChangeState("Landing")
end

---@details How to Play 클릭 → Guide로 이동
function OnGoToGuide()
    ChangeState("Guide")
end

---@details Game Start 클릭 → LevelSelect로 이동
function GoToLevelSelect()
    ChangeState("LevelSelect")
end

---@details 레벨 선택 완료 → 게임 시작
---@param difficulty string 선택한 난이도
function OnLevelSelected(difficulty)
    currentDifficulty = difficulty or "Easy"
    StartGame()
end

---@details 뒤로가기 → Landing으로 이동
function OnGoToMain()
    StopConfettiEffect()
    ChangeState("Landing")
end

---@details 재시작
function OnRetryGame()
    StopConfettiEffect()
    StartGame()
end

---@details 게임오버 처리 (ScoreManager에서 호출)
---@param reason string 게임오버 사유
function OnGameOver(reason)
    if reason == "HP_ZERO" then
        ChangeState("GameOver")
    end
end

--endregion

--region State Management

---@details 게임 상태 변경
---@param newState GameState 새로운 상태
function ChangeState(newState)
    currentState = newState

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
        ShowUI("gameHUD")
    elseif newState == "GameOver" then
        StopGame()
        ShowUI("gameOverUI")
        -- 게임오버 사운드 재생
        if audioManager then
            audioManager.PlayGameOver()
        end
    elseif newState == "TimeUp" then
        StopGame()
        ShowUI("resultUI")
        -- 결과 데이터 전달
        if uiManagers.resultUI and scoreManager then
            local result = scoreManager.GetGameResult()
            uiManagers.resultUI.ShowResult(result)
        end
        -- 축하 이펙트 재생
        PlayConfettiEffect()
        -- 완료 사운드 재생
        if audioManager then
            audioManager.PlayFinish()
        end
    elseif newState == "Result" then
        ShowUI("resultUI")
    end
end

---@details 현재 상태 반환
---@return GameState
function GetCurrentState()
    return currentState
end

--endregion

--region Effects

---@details Confetti 축하 이펙트 재생 (VFXManager 사용)
function PlayConfettiEffect()
    if vfxManager then
        -- ConfettiSpawnPoint가 있으면 해당 위치, 없으면 ResultUI 위치 사용
        local spawnPos = nil
        if ConfettiSpawnPoint then
            spawnPos = ConfettiSpawnPoint.transform.position
        elseif ResultUIPanel then
            spawnPos = ResultUIPanel.transform.position
        else
            -- 기본 위치 (원점 앞쪽)
            spawnPos = CS.UnityEngine.Vector3(0, 1, 2)
        end
        vfxManager.PlayConfettiVFX(spawnPos)
    end
end

---@details Confetti 이펙트 정지 (Instantiate 방식은 자동 삭제되므로 빈 함수)
function StopConfettiEffect()
    -- Instantiate 방식은 자동으로 Destroy되므로 별도 처리 불필요
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
        spawnManager.InitSpawn(settings)
        spawnManager.StartSpawning()
    end

    -- 상태 변경
    ChangeState("Playing")

    -- 타이머 시작
    StartTimer()
end

---@details 게임 정지
function StopGame()
    StopTimer()

    if spawnManager then
        spawnManager.StopSpawning()
    end
end

---@details 게임 일시정지
function PauseGame()
    if currentState ~= "Playing" then
        return
    end

    isTimerRunning = false
    ChangeState("Paused")

    if spawnManager then
        spawnManager.PauseSpawning()
    end
end

---@details 게임 재개
function ResumeGame()
    if currentState ~= "Paused" then
        return
    end

    ChangeState("Playing")
    isTimerRunning = true

    if spawnManager then
        spawnManager.ResumeSpawning()
    end
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

                -- GameHUD 직접 업데이트
                if uiManagers.gameHUD then
                    uiManagers.gameHUD.UpdateTimer(remainingTime)
                end
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
