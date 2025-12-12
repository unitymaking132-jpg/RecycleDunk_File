--- TrashBin: 쓰레기통 스크립트
--- 쓰레기 아이템을 받아서 판정하는 쓰레기통
--- TrashItem이 직접 이 스크립트의 메서드를 호출

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
---@details 쓰레기통 카테고리 ("Paper", "Plastic", "Glass", "Metal", "Misc")
BinCategory = checkInject(BinCategory)

---@type GameObject
---@details 정답 이펙트 오브젝트 (선택)
CorrectEffectObject = NullableInject(CorrectEffectObject)

---@type GameObject
---@details 오답 이펙트 오브젝트 (선택)
WrongEffectObject = NullableInject(WrongEffectObject)

---@type GameObject
---@details ScoreManager 오브젝트
ScoreManagerObject = NullableInject(ScoreManagerObject)

---@type GameObject
---@details AudioManager 오브젝트
AudioManagerObject = NullableInject(AudioManagerObject)

--endregion

--region Variables

---@type number
local receivedCount = 0

---@type number
local correctCount = 0

---@type number
local wrongCount = 0

---@type ParticleSystem
local correctParticle = nil

---@type ParticleSystem
local wrongParticle = nil

---@type ScoreManager
---@details 점수 매니저 참조
local scoreManager = nil

---@type AudioManager
---@details 오디오 매니저 참조
local audioManager = nil

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

    -- ScoreManager 참조 획득
    if ScoreManagerObject then
        scoreManager = ScoreManagerObject:GetLuaComponent("ScoreManager")
    end

    -- AudioManager 참조 획득
    if AudioManagerObject then
        audioManager = AudioManagerObject:GetLuaComponent("AudioManager")
    end
end

function start()
    -- 카테고리 유효성 검사
    if not IsValidCategory(BinCategory) then
        Debug.LogWarning("[TrashBin] Invalid category: " .. tostring(BinCategory))
        BinCategory = "Misc"
    end

    Debug.Log("[TrashBin] Initialized - Category: " .. BinCategory)
end

--endregion

--region Public Functions (TrashItem에서 직접 호출)

---@details 쓰레기가 이 쓰레기통에 들어왔을 때 처리 (판정 + ScoreManager 호출 + 이펙트)
---@param trashCategory string 쓰레기 카테고리
---@param trashItem table TrashItem Lua 컴포넌트 (선택)
---@return boolean 정답 여부
function OnTrashEntered(trashCategory, trashItem)
    receivedCount = receivedCount + 1

    -- 1. 판정
    local isCorrect = (trashCategory == BinCategory)

    -- 2. ScoreManager 호출
    if isCorrect then
        correctCount = correctCount + 1
        if scoreManager then
            scoreManager.OnCorrectAnswer(trashCategory)
        end
        -- 3. 정답 이펙트 + 사운드
        PlayCorrectEffect()
    else
        wrongCount = wrongCount + 1
        if scoreManager then
            scoreManager.OnWrongAnswer(trashCategory, BinCategory)
        end
        -- 3. 오답 이펙트 + 사운드
        PlayWrongEffect()
    end

    Debug.Log("[TrashBin] Trash entered - Category: " .. trashCategory .. ", BinCategory: " .. BinCategory .. ", IsCorrect: " .. tostring(isCorrect))

    return isCorrect
end

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

--region Effects

---@details 정답 이펙트 재생 (파티클 + 사운드)
function PlayCorrectEffect()
    -- 파티클 이펙트
    if CorrectEffectObject then
        CorrectEffectObject:SetActive(true)
        if correctParticle then
            correctParticle:Play()
        end
    end

    -- 사운드 재생
    if audioManager then
        audioManager.PlayGood()
    end
end

---@details 오답 이펙트 재생 (파티클 + 사운드)
function PlayWrongEffect()
    -- 파티클 이펙트
    if WrongEffectObject then
        WrongEffectObject:SetActive(true)
        if wrongParticle then
            wrongParticle:Play()
        end
    end

    -- 사운드 재생
    if audioManager then
        audioManager.PlayMiss()
    end
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
        Misc = true
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
        Misc = { r = 0.3, g = 0.3, b = 0.3 }
    }
    return colors[BinCategory] or colors["Misc"]
end

--endregion
