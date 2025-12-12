--- GameHUD: 게임 진행 중 HUD UI
--- 타이머, HP, 점수, 콤보 표시
--- GameManager, ScoreManager에서 직접 메서드 호출하여 업데이트

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
---@details 타이머 텍스트 오브젝트 (TMP_Text가 있는 오브젝트)
TimerTextObject = checkInject(TimerTextObject)

---@type GameObject
---@details HP Slider 오브젝트 (Unity Slider 컴포넌트가 있는 오브젝트)
HPSliderObject = checkInject(HPSliderObject)

---@type GameObject
---@details HP 텍스트 오브젝트 (선택, HP 숫자 표시용)
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
local timerText = nil

---@type Slider
local hpSlider = nil

---@type TMP_Text
local hpText = nil

---@type TMP_Text
local scoreText = nil

---@type TMP_Text
local comboText = nil

---@type number
local currentHP = 5

---@type number
local maxHP = 5

--endregion

--region Internal Functions (self 파라미터 없는 내부용)

local function UpdateTimerInternal(remainingTime)
    if timerText then
        local minutes = math.floor(remainingTime / 60)
        local seconds = remainingTime % 60
        timerText.text = string.format("%02d:%02d", minutes, seconds)
    end
end

local function UpdateHPInternal(hp, max)
    currentHP = hp
    maxHP = max or maxHP

    -- HP Slider 업데이트
    if hpSlider then
        hpSlider.maxValue = maxHP
        hpSlider.value = hp
    end

    -- HP 텍스트 업데이트
    if hpText then
        hpText.text = tostring(hp)
    end
end

local function UpdateScoreInternal(score)
    if scoreText then
        scoreText.text = tostring(score)
    end
end

local function UpdateComboInternal(combo)
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

--region Unity Lifecycle

function awake()
    -- 타이머 텍스트 컴포넌트 가져오기
    timerText = TimerTextObject:GetComponent(typeof(TMP_Text))

    -- HP Slider 컴포넌트 가져오기
    hpSlider = HPSliderObject:GetComponent(typeof(CS.UnityEngine.UI.Slider))

    -- 선택적 컴포넌트들
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

--endregion

--region Public Functions (외부에서 직접 호출)

---@details UI 초기화
function InitUI()
    UpdateTimerInternal(60)
    UpdateHPInternal(5, 5)
    UpdateScoreInternal(0)
    UpdateComboInternal(0)
end

---@details 타이머 업데이트 (외부 호출용, : 문법으로 호출)
---@param _ any self (사용 안함)
---@param remainingTime number 남은 시간 (초)
function UpdateTimer(_, remainingTime)
    UpdateTimerInternal(remainingTime)
end

---@details HP 업데이트 (외부 호출용, : 문법으로 호출)
---@param _ any self (사용 안함)
---@param hp number 현재 HP
---@param max number 최대 HP
function UpdateHP(_, hp, max)
    UpdateHPInternal(hp, max)
end

---@details 점수 업데이트 (외부 호출용, : 문법으로 호출)
---@param _ any self (사용 안함)
---@param score number 현재 점수
function UpdateScore(_, score)
    UpdateScoreInternal(score)
end

---@details 콤보 업데이트 (외부 호출용, : 문법으로 호출)
---@param _ any self (사용 안함)
---@param combo number 현재 콤보
function UpdateCombo(_, combo)
    UpdateComboInternal(combo)
end

--endregion
