--- GameOverUI: 게임오버 화면 UI
--- HP가 0이 되었을 때 표시되는 UI

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
---@details Retry 버튼
RetryButton = checkInject(RetryButton)

---@type GameObject
---@details Game Over 텍스트 오브젝트 (선택)
GameOverTextObject = NullableInject(GameOverTextObject)

--endregion

--region Variables

---@type Button
---@details Retry 버튼 컴포넌트
local retryButtonComp = nil

--endregion

--region Unity Lifecycle

function awake()
    -- 버튼 컴포넌트 가져오기
    retryButtonComp = RetryButton:GetComponent(typeof(CS.UnityEngine.UI.Button))
end

function start()
    Debug.Log("[GameOverUI] Initialized")
end

function onEnable()
    -- 버튼 이벤트 등록
    if retryButtonComp then
        retryButtonComp.onClick:AddListener(OnRetryClick)
    end

    -- 게임오버 애니메이션 등
    PlayGameOverAnimation()
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
    Debug.Log("[GameOverUI] Retry clicked")
end

--endregion

--region Animation

---@details 게임오버 애니메이션 재생
function PlayGameOverAnimation()
    -- TODO: 페이드인 또는 스케일 애니메이션 추가
    Debug.Log("[GameOverUI] Game Over!")
end

--endregion
