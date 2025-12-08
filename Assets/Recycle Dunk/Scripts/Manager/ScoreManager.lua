--- ScoreManager: 점수 및 HP 관리
--- 게임 내 점수, HP, 콤보, 통계를 관리하는 매니저

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
---@details GameHUD 오브젝트 (UI 업데이트용)
GameHUDObject = NullableInject(GameHUDObject)

--endregion

--region Variables

---@type number
---@details 현재 점수
local currentScore = 0

---@type number
---@details 현재 HP
local currentHP = 5

---@type number
---@details 시작 HP
local startHP = 5

---@type number
---@details 현재 콤보
local currentCombo = 0

---@type number
---@details 최대 콤보
local maxCombo = 0

---@type number
---@details 정답 횟수
local correctCount = 0

---@type number
---@details 오답 횟수
local wrongCount = 0

---@type table
---@details 카테고리별 오답 횟수
local wrongCountByCategory = {
    Paper = 0,
    Plastic = 0,
    Glass = 0,
    Metal = 0,
    GeneralGarbage = 0
}

---@type number
---@details 정답 시 획득 점수
local correctScore = 100

---@type number
---@details 콤보 보너스 점수
local comboBonus = 50

---@type GameHUD
---@details GameHUD 스크립트 참조
local gameHUD = nil

--endregion

--region Unity Lifecycle

function awake()
    if GameHUDObject ~= nil then
        gameHUD = GameHUDObject:GetLuaComponent("GameHUD")
    end
end

function start()
    -- 초기화는 InitScore에서 수행
end

--endregion

--region Public Functions

---@details 점수 시스템 초기화
---@param settings table 게임 설정 (startHP, correctScore, comboBonus)
function InitScore(settings)
    if settings then
        startHP = settings.startHP or 5
        correctScore = settings.correctScore or 100
        comboBonus = settings.comboBonus or 50
    end

    currentScore = 0
    currentHP = startHP
    currentCombo = 0
    maxCombo = 0
    correctCount = 0
    wrongCount = 0

    -- 카테고리별 오답 횟수 초기화
    wrongCountByCategory = {
        Paper = 0,
        Plastic = 0,
        Glass = 0,
        Metal = 0,
        GeneralGarbage = 0
    }

    -- UI 업데이트
    UpdateUI()

    Debug.Log("[ScoreManager] Score initialized - HP: " .. currentHP)
end

---@details 정답 처리
---@param category string 쓰레기 카테고리
function OnCorrectAnswer(category)
    -- 콤보 증가
    currentCombo = currentCombo + 1
    if currentCombo > maxCombo then
        maxCombo = currentCombo
    end

    -- 점수 계산 (기본 점수 + 콤보 보너스)
    local earnedScore = correctScore
    if currentCombo > 1 then
        earnedScore = earnedScore + (comboBonus * (currentCombo - 1))
    end

    currentScore = currentScore + earnedScore
    correctCount = correctCount + 1

    -- 이벤트 발생
    GameEvent.invoke("onScoreUpdate", currentScore)
    GameEvent.invoke("onComboUpdate", currentCombo)
    GameEvent.invoke("onCorrectAnswer", category, earnedScore)

    -- UI 업데이트
    UpdateUI()

    Debug.Log("[ScoreManager] Correct! Score: " .. currentScore .. ", Combo: " .. currentCombo)
end

---@details 오답 처리
---@param trashCategory string 쓰레기 카테고리
---@param binCategory string 쓰레기통 카테고리
function OnWrongAnswer(trashCategory, binCategory)
    -- 콤보 리셋
    currentCombo = 0

    -- HP 감소
    currentHP = currentHP - 1
    wrongCount = wrongCount + 1

    -- 카테고리별 오답 횟수 증가
    if wrongCountByCategory[trashCategory] then
        wrongCountByCategory[trashCategory] = wrongCountByCategory[trashCategory] + 1
    end

    -- 이벤트 발생
    GameEvent.invoke("onHPUpdate", currentHP)
    GameEvent.invoke("onComboUpdate", currentCombo)
    GameEvent.invoke("onWrongAnswer", trashCategory, binCategory)

    -- UI 업데이트
    UpdateUI()

    Debug.Log("[ScoreManager] Wrong! HP: " .. currentHP .. ", Category: " .. trashCategory)

    -- HP가 0이면 게임오버
    if currentHP <= 0 then
        GameEvent.invoke("onGameOver", "HP_ZERO")
    end
end

---@details 쓰레기 이탈 처리 (경계 밖으로 나감)
---@param category string 쓰레기 카테고리
function OnTrashLost(category)
    -- 콤보 리셋
    currentCombo = 0

    -- HP 감소
    currentHP = currentHP - 1
    wrongCount = wrongCount + 1

    -- 카테고리별 오답 횟수 증가
    if category and wrongCountByCategory[category] then
        wrongCountByCategory[category] = wrongCountByCategory[category] + 1
    end

    -- 이벤트 발생
    GameEvent.invoke("onHPUpdate", currentHP)
    GameEvent.invoke("onComboUpdate", currentCombo)
    GameEvent.invoke("onTrashLost", category)

    -- UI 업데이트
    UpdateUI()

    Debug.Log("[ScoreManager] Trash lost! HP: " .. currentHP)

    -- HP가 0이면 게임오버
    if currentHP <= 0 then
        GameEvent.invoke("onGameOver", "HP_ZERO")
    end
end

---@details 현재 점수 반환
---@return number
function GetScore()
    return currentScore
end

---@details 현재 HP 반환
---@return number
function GetHP()
    return currentHP
end

---@details 현재 콤보 반환
---@return number
function GetCombo()
    return currentCombo
end

---@details 최대 콤보 반환
---@return number
function GetMaxCombo()
    return maxCombo
end

---@details 정확도 계산 (%)
---@return number
function GetAccuracy()
    local total = correctCount + wrongCount
    if total == 0 then
        return 0
    end
    return math.floor((correctCount / total) * 100)
end

---@details 가장 많이 틀린 카테고리 반환
---@return string|nil
function GetMostWrongCategory()
    local maxWrong = 0
    local mostWrongCategory = nil

    for category, count in pairs(wrongCountByCategory) do
        if count > maxWrong then
            maxWrong = count
            mostWrongCategory = category
        end
    end

    return mostWrongCategory
end

---@details 게임 결과 데이터 반환
---@return table GameResult
function GetGameResult()
    return {
        totalScore = currentScore,
        correctCount = correctCount,
        wrongCount = wrongCount,
        accuracy = GetAccuracy(),
        maxCombo = maxCombo,
        mostMissedCategory = GetMostWrongCategory()
    }
end

--endregion

--region Private Functions

---@details UI 업데이트
function UpdateUI()
    if gameHUD ~= nil then
        gameHUD.UpdateScore(currentScore)
        gameHUD.UpdateHP(currentHP, startHP)
        gameHUD.UpdateCombo(currentCombo)
    end
end

--endregion
