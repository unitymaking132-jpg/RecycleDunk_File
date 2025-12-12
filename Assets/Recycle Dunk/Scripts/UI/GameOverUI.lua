--- GameOverUI: 게임오버 화면 UI
--- HP가 0이 되었을 때 표시되는 UI
--- Retry 버튼 클릭 시 GameManager를 직접 호출

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
---@details Retry 버튼
RetryButton = checkInject(RetryButton)

---@type GameObject
---@details Game Over 텍스트 오브젝트 (선택)
GameOverTextObject = NullableInject(GameOverTextObject)

--endregion

--region Variables

---@type Button
local retryButtonComp = nil

--endregion

--region Unity Lifecycle

function awake()
    retryButtonComp = RetryButton:GetComponent(typeof(CS.UnityEngine.UI.Button))
end

function start()
    Debug.Log("[GameOverUI] Initialized")
end

function onEnable()
    if retryButtonComp then
        retryButtonComp.onClick:AddListener(OnRetryClick)
    end
    PlayGameOverAnimation()
end

function onDisable()
    if retryButtonComp then
        retryButtonComp.onClick:RemoveListener(OnRetryClick)
    end
end

--endregion

--region Button Handlers

---@details AudioManager를 찾아서 반환
---@return table|nil AudioManager Lua 컴포넌트
function GetAudioManager()
    local audioManagerObj = CS.UnityEngine.GameObject.Find("AudioManager")
    if audioManagerObj then
        return audioManagerObj:GetLuaComponent("AudioManager")
    end
    return nil
end

---@details UI 클릭 효과음 재생
function PlayClickSound()
    local audioManager = GetAudioManager()
    if audioManager then
        audioManager.PlayUIClick()
    end
end

---@details Retry 버튼 클릭 → GameManager 직접 호출
function OnRetryClick()
    Debug.Log("[GameOverUI] Retry clicked")
    PlayClickSound()

    local gameManagerObj = CS.UnityEngine.GameObject.Find("GameManager")
    if gameManagerObj then
        local gameManager = gameManagerObj:GetLuaComponent("GameManager")
        if gameManager then
            gameManager.OnRetryGame()
        end
    end
end

--endregion

--region Animation

---@details 게임오버 애니메이션 재생
function PlayGameOverAnimation()
    -- TODO: 페이드인 또는 스케일 애니메이션 추가
    Debug.Log("[GameOverUI] Game Over!")
end

--endregion
