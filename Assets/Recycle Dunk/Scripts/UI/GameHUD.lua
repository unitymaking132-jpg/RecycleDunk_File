--- GameHUD: 게임 진행 중 HUD UI
--- 타이머, HP, 점수, 콤보 표시

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
---@details 타이머 텍스트 오브젝트
TimerTextObject = checkInject(TimerTextObject)

---@type GameObject
---@details HP 바 이미지 오브젝트 (Filled)
HPBarObject = checkInject(HPBarObject)

---@type GameObject
---@details HP 텍스트 오브젝트 (선택)
HPTextObject = NullableInject(HPTextObject)

---@type GameObject
---@details 점수 텍스트 오브젝트 (선택)
ScoreTextObject = NullableInject(ScoreTextObject)

---@type GameObject
---@details 콤보 텍스트 오브젝트 (선택)
ComboTextObject = NullableInject(ComboTextObject)

--endregion

--region Variables

---@type TMP_Text
---@details 타이머 텍스트 컴포넌트
local timerText = nil

---@type Image
---@details HP 바 이미지 컴포넌트
local hpBarImage = nil

---@type TMP_Text
---@details HP 텍스트 컴포넌트
local hpText = nil

---@type TMP_Text
---@details 점수 텍스트 컴포넌트
local scoreText = nil

---@type TMP_Text
---@details 콤보 텍스트 컴포넌트
local comboText = nil

---@type number
---@details 현재 HP
local currentHP = 5

---@type number
---@details 최대 HP
local maxHP = 5

--endregion

--region Unity Lifecycle

function awake()
    -- 컴포넌트 가져오기
    timerText = TimerTextObject:GetComponent(typeof(TMP_Text))

    hpBarImage = HPBarObject:GetComponent(typeof(CS.UnityEngine.UI.Image))

    if HPTextObject then
        hpText = HPTextObject:GetComponent(typeof(TMP_Text))
    end

    if ScoreTextObject then
        scoreText = ScoreTextObject:GetComponent(typeof(TMP_Text))
    end

    if ComboTextObject then
        comboText = ComboTextObject:GetComponent(typeof(TMP_Text))
    end
end

function start()
    -- 초기 UI 설정
    InitUI()
end

function onEnable()
    -- 이벤트 리스너 등록
    GameEvent.registerEvent("onTimerUpdate", OnTimerUpdate)
    GameEvent.registerEvent("onHPUpdate", OnHPUpdate)
    GameEvent.registerEvent("onScoreUpdate", OnScoreUpdate)
    GameEvent.registerEvent("onComboUpdate", OnComboUpdate)
end

function onDisable()
    -- 이벤트 리스너 해제
    GameEvent.unregisterEvent("onTimerUpdate", OnTimerUpdate)
    GameEvent.unregisterEvent("onHPUpdate", OnHPUpdate)
    GameEvent.unregisterEvent("onScoreUpdate", OnScoreUpdate)
    GameEvent.unregisterEvent("onComboUpdate", OnComboUpdate)
end

--endregion

--region Event Handlers

---@details 타이머 업데이트 이벤트 핸들러
---@param remainingTime number 남은 시간 (초)
function OnTimerUpdate(remainingTime)
    UpdateTimer(remainingTime)
end

---@details HP 업데이트 이벤트 핸들러
---@param hp number 현재 HP
function OnHPUpdate(hp)
    UpdateHP(hp, maxHP)
end

---@details 점수 업데이트 이벤트 핸들러
---@param score number 현재 점수
function OnScoreUpdate(score)
    UpdateScore(score)
end

---@details 콤보 업데이트 이벤트 핸들러
---@param combo number 현재 콤보
function OnComboUpdate(combo)
    UpdateCombo(combo)
end

--endregion

--region Public Functions

---@details UI 초기화
function InitUI()
    UpdateTimer(60)
    UpdateHP(5, 5)
    UpdateScore(0)
    UpdateCombo(0)
end

---@details 타이머 업데이트
---@param remainingTime number 남은 시간 (초)
function UpdateTimer(remainingTime)
    if timerText then
        local minutes = math.floor(remainingTime / 60)
        local seconds = remainingTime % 60
        timerText.text = string.format("%02d:%02d", minutes, seconds)
    end
end

---@details HP 업데이트
---@param hp number 현재 HP
---@param max number 최대 HP
function UpdateHP(hp, max)
    currentHP = hp
    maxHP = max or maxHP

    -- HP 바 업데이트 (fillAmount)
    if hpBarImage then
        hpBarImage.fillAmount = hp / maxHP
    end

    -- HP 텍스트 업데이트
    if hpText then
        hpText.text = tostring(hp)
    end
end

---@details 점수 업데이트
---@param score number 현재 점수
function UpdateScore(score)
    if scoreText then
        scoreText.text = tostring(score)
    end
end

---@details 콤보 업데이트
---@param combo number 현재 콤보
function UpdateCombo(combo)
    if comboText then
        if combo > 1 then
            comboText.text = "x" .. tostring(combo)
            ComboTextObject:SetActive(true)
        else
            ComboTextObject:SetActive(false)
        end
    end
end

--endregion
