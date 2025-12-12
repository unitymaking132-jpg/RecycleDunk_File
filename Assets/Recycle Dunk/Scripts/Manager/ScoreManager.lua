--- ScoreManager: 점수 및 HP 관리
--- 게임 내 점수, HP, 콤보, 통계를 관리하는 매니저
--- GameHUD를 직접 호출하여 UI 업데이트

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
---@details GameHUD 오브젝트 (UI 업데이트용)
GameHUDObject = NullableInject(GameHUDObject)

---@type GameObject
---@details GameManager 오브젝트 (게임오버 알림용)
GameManagerObject = NullableInject(GameManagerObject)

--endregion

--region Variables

---@type number
local currentScore = 0

---@type number
local currentHP = 5

---@type number
local startHP = 5

---@type number
local currentCombo = 0

---@type number
local maxCombo = 0

---@type number
local correctCount = 0

---@type number
local wrongCount = 0

---@type table
local wrongCountByCategory = {
    Paper = 0,
    Plastic = 0,
    Glass = 0,
    Metal = 0,
    GeneralGarbage = 0
}

---@type number
local correctScore = 100

---@type number
local comboBonus = 50

---@type GameHUD
local gameHUD = nil

---@type GameManager
local gameManager = nil

--endregion

--region Unity Lifecycle

function awake()
    if GameHUDObject then
        gameHUD = GameHUDObject:GetLuaComponent("GameHUD")
    end
    if GameManagerObject then
        gameManager = GameManagerObject:GetLuaComponent("GameManager")
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

    -- UI 업데이트
    UpdateUI()
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

    -- UI 업데이트
    UpdateUI()

    -- HP가 0이면 게임오버
    if currentHP <= 0 then
        NotifyGameOver("HP_ZERO")
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

    -- UI 업데이트
    UpdateUI()

    -- HP가 0이면 게임오버
    if currentHP <= 0 then
        NotifyGameOver("HP_ZERO")
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
    if gameHUD then
        gameHUD.UpdateScore(currentScore)
        gameHUD.UpdateHP(currentHP, startHP)
        gameHUD.UpdateCombo(currentCombo)
    end
end

---@details GameManager에게 게임오버 알림
---@param reason string 게임오버 사유
function NotifyGameOver(reason)
    if gameManager then
        gameManager.OnGameOver(reason)
    else
        -- GameManager를 찾지 못한 경우 GameObject.Find로 시도
        local gmObj = CS.UnityEngine.GameObject.Find("GameManager")
        if gmObj then
            local gm = gmObj:GetLuaComponent("GameManager")
            if gm then
                gm.OnGameOver(reason)
            end
        end
    end
end

--endregion
