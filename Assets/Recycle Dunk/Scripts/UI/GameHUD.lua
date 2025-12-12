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
    if OBJECT == nil then
        Debug.Log(_INJECTED_ORDER .. "th object is missing")
    end
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

--region Unity Lifecycle

function awake()
    -- 타이머 텍스트 컴포넌트 가져오기
    timerText = TimerTextObject:GetComponent(typeof(TMP_Text))
    if timerText == nil then
        Debug.LogWarning("[GameHUD] TimerTextObject에서 TMP_Text를 찾을 수 없습니다")
    end

    -- HP Slider 컴포넌트 가져오기
    hpSlider = HPSliderObject:GetComponent(typeof(CS.UnityEngine.UI.Slider))
    if hpSlider == nil then
        Debug.LogWarning("[GameHUD] HPSliderObject에서 Slider를 찾을 수 없습니다")
    end

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

    Debug.Log("[GameHUD] Awake 완료")
end

function start()
    -- 초기 UI 설정
    InitUI()
end

--endregion

--region Public Functions (외부에서 직접 호출)

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
