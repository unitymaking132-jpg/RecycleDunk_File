--- FloatingBehavior: Perlin Noise 기반 무중력 떠다니기 효과
--- 쓰레기 아이템에 부착하여 우주에서 떠다니는 느낌을 구현

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

--endregion

--region Variables

---@type Vector3
---@details 스폰 위치 (기준점)
local spawnPosition = nil

---@type number
---@details 노이즈 스케일 (움직임의 부드러움)
local noiseScale = 0.5

---@type number
---@details 노이즈 속도 (움직임의 빠르기)
local noiseSpeed = 0.3

---@type number
---@details 떠다니는 범위 (미터)
local floatRange = 0.1

---@type number
---@details 회전 속도
local rotationSpeed = 5

---@type boolean
---@details 떠다니기 활성화 여부
local isFloating = true

---@type boolean
---@details 잡힌 상태 여부
local isGrabbed = false

---@type number
---@details 노이즈 오프셋 (각 오브젝트마다 다르게)
local noiseOffsetX = 0
local noiseOffsetY = 0
local noiseOffsetZ = 0

---@type Vector3
---@details 현재 노이즈 오프셋
local currentOffset = nil

--endregion

--region Unity Lifecycle

function awake()
    -- 랜덤 오프셋 설정 (각 오브젝트마다 다른 움직임)
    noiseOffsetX = math.random() * 100
    noiseOffsetY = math.random() * 100
    noiseOffsetZ = math.random() * 100

    -- 떠다니기 비활성화 (ResetFloating 호출 전까지)
    isFloating = false
    isGrabbed = false

    -- spawnPosition은 ResetFloating에서 설정됨 (awake 시점에는 nil)
    spawnPosition = nil
    currentOffset = nil
end

function start()
    -- 풀링 시스템 사용 시 start()에서는 아무것도 하지 않음
    -- ResetFloating()이 호출될 때 초기화됨
end

function update()
    -- 떠다니기 비활성화 상태면 스킵
    if not isFloating then
        return
    end

    -- 잡힌 상태면 스킵
    if isGrabbed then
        return
    end

    -- spawnPosition이 nil이거나 x가 nil이면 스킵
    if not spawnPosition or spawnPosition.x == nil then
        return
    end

    UpdateFloating()
    UpdateRotation()
end

--endregion

--region Floating Logic

---@details 떠다니기 업데이트
function UpdateFloating()
    local time = Time.time * noiseSpeed

    -- Perlin Noise로 각 축의 오프셋 계산
    local offsetX = (Mathf.PerlinNoise(time + noiseOffsetX, 0) - 0.5) * 2 * floatRange
    local offsetY = (Mathf.PerlinNoise(0, time + noiseOffsetY) - 0.5) * 2 * floatRange
    local offsetZ = (Mathf.PerlinNoise(time + noiseOffsetZ, time) - 0.5) * 2 * floatRange

    -- 새 위치 계산
    local newPosition = Vector3(
        spawnPosition.x + offsetX,
        spawnPosition.y + offsetY,
        spawnPosition.z + offsetZ
    )

    -- 부드럽게 이동
    self.transform.position = Vector3.Lerp(
        self.transform.position,
        newPosition,
        Time.deltaTime * noiseScale * 10
    )

    currentOffset = Vector3(offsetX, offsetY, offsetZ)
end

---@details 회전 업데이트 (천천히 회전)
function UpdateRotation()
    local time = Time.time * rotationSpeed * 0.1

    -- 각 축에 대해 천천히 회전
    local rotX = Mathf.Sin(time + noiseOffsetX) * rotationSpeed * Time.deltaTime
    local rotY = Mathf.Sin(time * 0.7 + noiseOffsetY) * rotationSpeed * Time.deltaTime
    local rotZ = Mathf.Sin(time * 0.5 + noiseOffsetZ) * rotationSpeed * Time.deltaTime

    self.transform:Rotate(rotX, rotY, rotZ, CS.UnityEngine.Space.Self)
end

--endregion

--region Public Functions

---@details 떠다니기 설정 초기화
---@param settings table 설정 (noiseScale, noiseSpeed, floatRange, rotationSpeed)
function InitFloating(settings)
    if settings then
        noiseScale = settings.noiseScale or 0.5
        noiseSpeed = settings.noiseSpeed or 0.3
        floatRange = settings.floatRange or 0.1
        rotationSpeed = settings.rotationSpeed or 5
    end

    -- 스폰 위치 갱신
    spawnPosition = self.transform.position
    isFloating = true
    isGrabbed = false
end

---@details 스폰 위치 설정
---@param position Vector3 새 스폰 위치
function SetSpawnPosition(position)
    spawnPosition = position
end

---@details 떠다니기 활성화
function EnableFloating()
    isFloating = true
end

---@details 떠다니기 비활성화
function DisableFloating()
    isFloating = false
end

---@details 잡힌 상태 설정 (외부 호출용, : 문법으로 호출)
---@param _ any self (사용 안함)
---@param grabbed boolean 잡힌 상태
function SetGrabbed(_, grabbed)
    isGrabbed = grabbed
end

---@details 잡힌 상태 반환
---@return boolean
function IsGrabbed()
    return isGrabbed
end

---@details 떠다니기 범위 설정
---@param range number 범위 (미터)
function SetFloatRange(range)
    floatRange = range
end

---@details 떠다니기 속도 설정
---@param speed number 속도
function SetNoiseSpeed(speed)
    noiseSpeed = speed
end

---@details 현재 스폰 위치 반환
---@return Vector3
function GetSpawnPosition()
    return spawnPosition
end

---@details 떠다니기 완전 리셋 (외부 호출용, : 문법으로 호출)
---@param _ any self (사용 안함)
---@param position Vector3 새 스폰 위치
---@param settings table|nil 설정 (nil이면 기본값 유지)
function ResetFloating(_, position, settings)
    -- 스폰 위치 설정 (position이 nil이면 기본값 유지)
    if position then
        spawnPosition = position
    end

    -- 설정 적용
    if settings then
        noiseScale = settings.noiseScale or 0.5
        noiseSpeed = settings.noiseSpeed or 0.3
        floatRange = settings.floatRange or 0.1
        rotationSpeed = settings.rotationSpeed or 5
    end

    -- 노이즈 오프셋 재생성 (각 오브젝트마다 다른 움직임)
    noiseOffsetX = math.random() * 100
    noiseOffsetY = math.random() * 100
    noiseOffsetZ = math.random() * 100

    -- 현재 오프셋 초기화
    currentOffset = Vector3(0, 0, 0)

    -- 상태 초기화
    isFloating = true
    isGrabbed = false
end

--endregion
