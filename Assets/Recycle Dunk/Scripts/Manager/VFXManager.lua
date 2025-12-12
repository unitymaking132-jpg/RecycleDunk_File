--- VFXManager: 파티클 VFX 관리
--- Instantiate 방식으로 VFX 프리팹을 생성하고 자동 삭제

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
---@details 정답 VFX 프리팹 (Flash_star_ellow_green 권장)
VFX_Correct = NullableInject(VFX_Correct)

---@type GameObject
---@details 오답 VFX 프리팹 (Flash_ellow_pink 권장)
VFX_Wrong = NullableInject(VFX_Wrong)

---@type GameObject
---@details 축하 Confetti VFX 프리팹 (Confetti_blast_multicolor 권장)
VFX_Confetti = NullableInject(VFX_Confetti)

---@type GameObject
---@details 콤보 VFX 프리팹 (Sparkle_ellow 권장, 선택)
VFX_Combo = NullableInject(VFX_Combo)

--endregion

--region Variables

---@type number
---@details VFX 기본 지속 시간 (초)
local defaultDuration = 2.0

---@type boolean
---@details 초기화 완료 여부
local isInitialized = false

--endregion

--region Unity Lifecycle

function awake()
    isInitialized = true
    Debug.Log("[VFXManager] Initialized")
end

function start()
    -- VFX 프리팹 유효성 검사
    local count = 0
    if VFX_Correct then count = count + 1 end
    if VFX_Wrong then count = count + 1 end
    if VFX_Confetti then count = count + 1 end
    if VFX_Combo then count = count + 1 end

    Debug.Log("[VFXManager] Loaded " .. count .. " VFX prefabs")
end

--endregion

--region Core VFX Functions

---@details VFX 프리팹을 지정 위치에 Instantiate
---@param prefab GameObject VFX 프리팹
---@param position Vector3 생성 위치
---@param duration number 지속 시간 (초), nil이면 기본값 사용
---@return GameObject 생성된 VFX 오브젝트
function SpawnVFX(prefab, position, duration)
    if prefab == nil then
        Debug.LogWarning("[VFXManager] VFX prefab is nil")
        return nil
    end

    local dur = duration or defaultDuration
    local rotation = CS.UnityEngine.Quaternion.identity

    -- Instantiate
    local vfxObj = CS.UnityEngine.Object.Instantiate(prefab, position, rotation)

    if vfxObj then
        -- 일정 시간 후 자동 삭제
        CS.UnityEngine.Object.Destroy(vfxObj, dur)
        Debug.Log("[VFXManager] Spawned VFX at " .. tostring(position))
    end

    return vfxObj
end

---@details VFX를 Transform 위치에 Instantiate
---@param prefab GameObject VFX 프리팹
---@param transform Transform 대상 Transform
---@param offset Vector3 위치 오프셋 (선택)
---@param duration number 지속 시간 (초)
---@return GameObject
function SpawnVFXAtTransform(prefab, transform, offset, duration)
    if transform == nil then
        Debug.LogWarning("[VFXManager] Transform is nil")
        return nil
    end

    local pos = transform.position
    if offset then
        pos = pos + offset
    end

    return SpawnVFX(prefab, pos, duration)
end

--endregion

--region Public VFX Functions

---@details 정답 VFX 재생
---@param position Vector3 생성 위치
function PlayCorrectVFX(position)
    if VFX_Correct then
        SpawnVFX(VFX_Correct, position, 2.0)
    end
end

---@details 정답 VFX 재생 (Transform 위치)
---@param transform Transform 대상 Transform
function PlayCorrectVFXAt(transform)
    if VFX_Correct and transform then
        SpawnVFXAtTransform(VFX_Correct, transform, nil, 2.0)
    end
end

---@details 오답 VFX 재생
---@param position Vector3 생성 위치
function PlayWrongVFX(position)
    if VFX_Wrong then
        SpawnVFX(VFX_Wrong, position, 2.0)
    end
end

---@details 오답 VFX 재생 (Transform 위치)
---@param transform Transform 대상 Transform
function PlayWrongVFXAt(transform)
    if VFX_Wrong and transform then
        SpawnVFXAtTransform(VFX_Wrong, transform, nil, 2.0)
    end
end

---@details Confetti 축하 VFX 재생
---@param position Vector3 생성 위치
function PlayConfettiVFX(position)
    if VFX_Confetti then
        SpawnVFX(VFX_Confetti, position, 3.0)
    end
end

---@details Confetti VFX 재생 (Transform 위치)
---@param transform Transform 대상 Transform
function PlayConfettiVFXAt(transform)
    if VFX_Confetti and transform then
        SpawnVFXAtTransform(VFX_Confetti, transform, nil, 3.0)
    end
end

---@details 콤보 VFX 재생
---@param position Vector3 생성 위치
function PlayComboVFX(position)
    if VFX_Combo then
        SpawnVFX(VFX_Combo, position, 1.5)
    end
end

---@details 콤보 VFX 재생 (Transform 위치)
---@param transform Transform 대상 Transform
function PlayComboVFXAt(transform)
    if VFX_Combo and transform then
        SpawnVFXAtTransform(VFX_Combo, transform, nil, 1.5)
    end
end

--endregion

--region Utility

---@details 초기화 여부 반환
---@return boolean
function IsInitialized()
    return isInitialized
end

---@details 기본 지속 시간 설정
---@param duration number 지속 시간 (초)
function SetDefaultDuration(duration)
    if duration > 0 then
        defaultDuration = duration
    end
end

--endregion
