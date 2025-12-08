--- BoundaryZone: 경계 영역 스크립트
--- 쓰레기가 이 영역을 벗어나면 HP 감소 처리

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

--endregion

--region Variables

---@type number
---@details 경계 이탈 쓰레기 수
local lostCount = 0

---@type boolean
---@details 경계 감지 활성화 여부
local isActive = true

--endregion

--region Unity Lifecycle

function awake()
    -- Collider가 Trigger인지 확인
    local collider = self:GetComponent(typeof(CS.UnityEngine.Collider))
    if collider then
        if not collider.isTrigger then
            Debug.LogWarning("[BoundaryZone] Collider should be set as Trigger")
        end
    else
        Debug.LogError("[BoundaryZone] No Collider found!")
    end
end

function start()
    Debug.Log("[BoundaryZone] Initialized")
end

--endregion

--region Trigger Events

---@details 트리거 탈출 이벤트 (쓰레기가 경계를 벗어남)
---@param other Collider 탈출한 콜라이더
function onTriggerExit(other)
    if not isActive then
        return
    end

    -- TrashItem 컴포넌트 확인
    local trashItem = other.gameObject:GetLuaComponent("TrashItem")
    if trashItem then
        OnTrashExitBoundary(trashItem, other.gameObject)
    end
end

--endregion

--region Boundary Logic

---@details 쓰레기가 경계를 벗어났을 때 처리
---@param trashItem TrashItem 쓰레기 아이템 스크립트
---@param trashObject GameObject 쓰레기 오브젝트
function OnTrashExitBoundary(trashItem, trashObject)
    -- 이미 판정된 쓰레기는 무시
    if trashItem.IsJudged() then
        return
    end

    -- 잡힌 상태면 무시 (플레이어가 들고 있는 경우)
    if trashItem.IsGrabbed() then
        return
    end

    lostCount = lostCount + 1

    -- TrashItem에게 경계 이탈 알림
    trashItem.OnBoundaryExit()

    Debug.Log("[BoundaryZone] Trash lost - Total: " .. lostCount)
end

--endregion

--region Public Functions

---@details 경계 감지 활성화
function Enable()
    isActive = true
end

---@details 경계 감지 비활성화
function Disable()
    isActive = false
end

---@details 활성화 상태 반환
---@return boolean
function IsActive()
    return isActive
end

---@details 이탈 카운트 반환
---@return number
function GetLostCount()
    return lostCount
end

---@details 이탈 카운트 초기화
function ResetLostCount()
    lostCount = 0
end

--endregion
