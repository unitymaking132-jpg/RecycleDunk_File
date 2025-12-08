--- TrashBin: 쓰레기통 스크립트
--- 쓰레기 아이템을 받아서 판정하는 쓰레기통

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

---@type string
---@details 쓰레기통 카테고리 ("Paper", "Plastic", "Glass", "Metal", "GeneralGarbage")
BinCategory = checkInject(BinCategory)

---@type GameObject
---@details 정답 이펙트 오브젝트 (선택)
CorrectEffectObject = NullableInject(CorrectEffectObject)

---@type GameObject
---@details 오답 이펙트 오브젝트 (선택)
WrongEffectObject = NullableInject(WrongEffectObject)

--endregion

--region Variables

---@type number
---@details 받은 쓰레기 개수
local receivedCount = 0

---@type number
---@details 정답 개수
local correctCount = 0

---@type number
---@details 오답 개수 (잘못 들어온 것)
local wrongCount = 0

---@type ParticleSystem
---@details 정답 파티클 시스템
local correctParticle = nil

---@type ParticleSystem
---@details 오답 파티클 시스템
local wrongParticle = nil

--endregion

--region Unity Lifecycle

function awake()
    -- 이펙트 컴포넌트 가져오기
    if CorrectEffectObject then
        correctParticle = CorrectEffectObject:GetComponent(typeof(CS.UnityEngine.ParticleSystem))
        CorrectEffectObject:SetActive(false)
    end

    if WrongEffectObject then
        wrongParticle = WrongEffectObject:GetComponent(typeof(CS.UnityEngine.ParticleSystem))
        WrongEffectObject:SetActive(false)
    end
end

function start()
    -- 카테고리 유효성 검사
    if not IsValidCategory(BinCategory) then
        Debug.LogWarning("[TrashBin] Invalid category: " .. tostring(BinCategory))
        BinCategory = "GeneralGarbage"
    end

    Debug.Log("[TrashBin] Initialized - Category: " .. BinCategory)
end

function onEnable()
    -- 이벤트 리스너 등록
    GameEvent.registerEvent("onTrashBinned", OnTrashBinnedEvent)
end

function onDisable()
    -- 이벤트 리스너 해제
    GameEvent.unregisterEvent("onTrashBinned", OnTrashBinnedEvent)
end

--endregion

--region Event Handlers

---@details 쓰레기 판정 이벤트 핸들러
---@param isCorrect boolean 정답 여부
---@param trashCategory string 쓰레기 카테고리
---@param binCategory string 쓰레기통 카테고리
function OnTrashBinnedEvent(isCorrect, trashCategory, binCategory)
    -- 이 쓰레기통에 들어온 경우만 처리
    if binCategory ~= BinCategory then
        return
    end

    receivedCount = receivedCount + 1

    if isCorrect then
        correctCount = correctCount + 1
        PlayCorrectEffect()
    else
        wrongCount = wrongCount + 1
        PlayWrongEffect()
    end
end

--endregion

--region Effects

---@details 정답 이펙트 재생
function PlayCorrectEffect()
    if CorrectEffectObject then
        CorrectEffectObject:SetActive(true)
        if correctParticle then
            correctParticle:Play()
        end
    end

    -- TODO: 사운드 재생
end

---@details 오답 이펙트 재생
function PlayWrongEffect()
    if WrongEffectObject then
        WrongEffectObject:SetActive(true)
        if wrongParticle then
            wrongParticle:Play()
        end
    end

    -- TODO: 사운드 재생
end

--endregion

--region Public Functions

---@details 쓰레기통 카테고리 반환
---@return string
function GetBinCategory()
    return BinCategory
end

---@details 받은 쓰레기 개수 반환
---@return number
function GetReceivedCount()
    return receivedCount
end

---@details 정답 개수 반환
---@return number
function GetCorrectCount()
    return correctCount
end

---@details 오답 개수 반환
---@return number
function GetWrongCount()
    return wrongCount
end

---@details 통계 초기화
function ResetStats()
    receivedCount = 0
    correctCount = 0
    wrongCount = 0
end

---@details 쓰레기가 올바른 카테고리인지 확인
---@param trashCategory string 쓰레기 카테고리
---@return boolean
function IsCorrectCategory(trashCategory)
    return trashCategory == BinCategory
end

--endregion

--region Utility

---@details 카테고리 유효성 검사
---@param category string 검사할 카테고리
---@return boolean
function IsValidCategory(category)
    local validCategories = {
        Paper = true,
        Plastic = true,
        Glass = true,
        Metal = true,
        GeneralGarbage = true
    }
    return validCategories[category] == true
end

---@details 카테고리별 색상 반환
---@return table {r, g, b}
function GetCategoryColor()
    local colors = {
        Paper = { r = 0.2, g = 0.4, b = 0.8 },
        Plastic = { r = 0.8, g = 0.2, b = 0.2 },
        Glass = { r = 0.2, g = 0.8, b = 0.3 },
        Metal = { r = 0.9, g = 0.8, b = 0.2 },
        GeneralGarbage = { r = 0.3, g = 0.3, b = 0.3 }
    }
    return colors[BinCategory] or colors["GeneralGarbage"]
end

--endregion
