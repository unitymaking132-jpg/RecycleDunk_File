--- ResultUIManager: 게임 결과 화면 UI
--- 시간 종료 후 점수, 정확도, 가장 많이 틀린 카테고리 표시

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
---@details 최종 점수 텍스트 오브젝트
ScoreTextObject = checkInject(ScoreTextObject)

---@type GameObject
---@details 정확도 텍스트 오브젝트
AccuracyTextObject = checkInject(AccuracyTextObject)

---@type GameObject
---@details 가장 많이 틀린 카테고리 텍스트 오브젝트
MostWrongTextObject = checkInject(MostWrongTextObject)

---@type GameObject
---@details 힌트 메시지 텍스트 오브젝트
HintTextObject = checkInject(HintTextObject)

---@type GameObject
---@details Retry 버튼
RetryButton = checkInject(RetryButton)

--endregion

--region Variables

---@type TMP_Text
---@details 점수 텍스트 컴포넌트
local scoreText = nil

---@type TMP_Text
---@details 정확도 텍스트 컴포넌트
local accuracyText = nil

---@type TMP_Text
---@details 가장 많이 틀린 카테고리 텍스트 컴포넌트
local mostWrongText = nil

---@type TMP_Text
---@details 힌트 메시지 텍스트 컴포넌트
local hintText = nil

---@type Button
---@details Retry 버튼 컴포넌트
local retryButtonComp = nil

---@type table
---@details 카테고리별 힌트 메시지
local categoryHints = {
    Paper = "Make sure paper is clean and dry!",
    Plastic = "Check if the plastic has recycling marks!",
    Glass = "Glass bottles should be emptied first!",
    Metal = "Cans should be rinsed before recycling!",
    GeneralGarbage = "Check the types of regular garbage again!"
}

--endregion

--region Unity Lifecycle

function awake()
    -- 컴포넌트 가져오기
    scoreText = ScoreTextObject:GetComponent(typeof(TMP_Text))
    accuracyText = AccuracyTextObject:GetComponent(typeof(TMP_Text))
    mostWrongText = MostWrongTextObject:GetComponent(typeof(TMP_Text))
    hintText = HintTextObject:GetComponent(typeof(TMP_Text))
    retryButtonComp = RetryButton:GetComponent(typeof(CS.UnityEngine.UI.Button))
end

function start()
    Debug.Log("[ResultUIManager] Initialized")
end

function onEnable()
    -- 버튼 이벤트 등록
    if retryButtonComp then
        retryButtonComp.onClick:AddListener(OnRetryClick)
    end
end

function onDisable()
    -- 버튼 이벤트 해제
    if retryButtonComp then
        retryButtonComp.onClick:RemoveListener(OnRetryClick)
    end
end

--endregion

--region Button Handlers

---@details Retry 버튼 클릭
function OnRetryClick()
    -- 게임 재시작 이벤트 발생
    GameEvent.invoke("onRetryGame")
    Debug.Log("[ResultUIManager] Retry clicked")
end

--endregion

--region Public Functions

---@details 결과 표시
---@param result table GameResult 데이터
function ShowResult(result)
    if not result then
        Debug.LogWarning("[ResultUIManager] No result data provided")
        return
    end

    -- 점수 표시
    if scoreText then
        scoreText.text = "Final Score: " .. tostring(result.totalScore) .. " points"
    end

    -- 정확도 표시
    if accuracyText then
        accuracyText.text = "Accuracy: " .. tostring(result.accuracy) .. "%"
    end

    -- 가장 많이 틀린 카테고리 표시
    local mostWrongCategory = result.mostMissedCategory
    if mostWrongText then
        if mostWrongCategory then
            mostWrongText.text = "Most Wrong Item: " .. GetCategoryDisplayName(mostWrongCategory)
        else
            mostWrongText.text = "Most Wrong Item: None"
        end
    end

    -- 힌트 메시지 표시
    if hintText then
        if mostWrongCategory and categoryHints[mostWrongCategory] then
            hintText.text = categoryHints[mostWrongCategory]
        else
            hintText.text = "Great job! Keep up the good work!"
        end
    end

    Debug.Log("[ResultUIManager] Result displayed - Score: " .. result.totalScore .. ", Accuracy: " .. result.accuracy .. "%")
end

---@details 카테고리 표시 이름 반환
---@param category string 카테고리
---@return string
function GetCategoryDisplayName(category)
    local displayNames = {
        Paper = "Paper",
        Plastic = "Plastic",
        Glass = "Glass",
        Metal = "Metal",
        GeneralGarbage = "General Garbage"
    }
    return displayNames[category] or category
end

--endregion
