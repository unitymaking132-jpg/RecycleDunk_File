--- SpawnManager: 쓰레기 스폰 관리 (Object Pooling 방식)
--- 씬에 미리 배치된 오브젝트를 풀에서 가져와 재사용
--- VIVEN SDK에서 동적 VObject Instantiate가 불가능하므로 풀링 방식 사용

-- EventCallback 모듈 제거됨 (직접 메서드 호출 방식으로 전환)

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

-- Inspector 순서와 일치해야 함!
---@type GameObject
---@details 스폰 영역 오브젝트 (BoxCollider 포함)
SpawnZoneObject = NullableInject(SpawnZoneObject)

---@type GameObject
---@details ScoreManager 오브젝트
ScoreManagerObject = NullableInject(ScoreManagerObject)

-- 풀 부모 오브젝트 (카테고리별)
---@type GameObject
---@details Paper 풀 부모 오브젝트
PaperPool = NullableInject(PaperPool)

---@type GameObject
---@details Plastic 풀 부모 오브젝트
PlasticPool = NullableInject(PlasticPool)

---@type GameObject
---@details Glass 풀 부모 오브젝트
GlassPool = NullableInject(GlassPool)

---@type GameObject
---@details Metal 풀 부모 오브젝트
MetalPool = NullableInject(MetalPool)

---@type GameObject
---@details Misc(일반쓰레기) 풀 부모 오브젝트
MiscPool = NullableInject(MiscPool)

--endregion

--region Variables

local util = require 'xlua.util'

---@type number
---@details 스폰 간격 (초)
local spawnInterval = 3

---@type number
---@details 최대 동시 쓰레기 수
local maxTrashCount = 5

---@type boolean
---@details 스폰 활성화 여부
local isSpawning = false

---@type boolean
---@details 스폰 일시정지 여부
local isPaused = false

---@type table
---@details 활성화된 쓰레기 아이템 목록 {object, category, poolIndex}
local activeTrashItems = {}

---@type BoxCollider
---@details 스폰 영역 콜라이더
local spawnZoneCollider = nil

---@type Vector3
---@details 스폰 영역 최소 좌표
local spawnBoundsMin = nil

---@type Vector3
---@details 스폰 영역 최대 좌표
local spawnBoundsMax = nil

---@type any
---@details 스폰 코루틴 참조
local spawnCoroutine = nil

---@type ScoreManager
---@details 점수 매니저 참조
local scoreManager = nil

---@type boolean
---@details 초기화 완료 여부
local isInitialized = false

--endregion

--region Pool Variables

---@type table<string, table>
---@details 카테고리별 풀 테이블 {available = {인덱스...}, inUse = {인덱스...}}
local pools = {
    Paper = { available = {}, inUse = {} },
    Plastic = { available = {}, inUse = {} },
    Glass = { available = {}, inUse = {} },
    Metal = { available = {}, inUse = {} },
    Misc = { available = {}, inUse = {} }
}

---@type table<string, table>
---@details 카테고리별 오브젝트 테이블 (GameObject 배열)
local poolObjects = {
    Paper = {},
    Plastic = {},
    Glass = {},
    Metal = {},
    Misc = {}
}

---@type table<string, table>
---@details 카테고리별 스크립트 테이블 (TrashItem 스크립트 배열)
local poolScripts = {
    Paper = {},
    Plastic = {},
    Glass = {},
    Metal = {},
    Misc = {}
}

---@type table<string, table>
---@details 카테고리별 초기 위치/회전 저장 테이블
local poolInitialPose = {
    Paper = {},
    Plastic = {},
    Glass = {},
    Metal = {},
    Misc = {}
}

---@type table<string, GameObject>
---@details 카테고리별 풀 부모 매핑
local poolParents = {}

--endregion

--region Unity Lifecycle

function awake()
    -- Pool injection 체크 - 하나도 없으면 스킵 (테스트 모드)
    if not PaperPool and not PlasticPool and not GlassPool and not MetalPool and not MiscPool then
        Debug.Log("[SpawnManager] No pools injected - disabled (test mode)")
        isInitialized = false
        return
    end

    -- 풀 부모 매핑 설정
    poolParents = {
        Paper = PaperPool,
        Plastic = PlasticPool,
        Glass = GlassPool,
        Metal = MetalPool,
        Misc = MiscPool
    }

    -- 스폰 영역 BoxCollider에서 bounds 가져오기
    if SpawnZoneObject then
        spawnZoneCollider = SpawnZoneObject:GetComponent(typeof(CS.UnityEngine.BoxCollider))
        if spawnZoneCollider then
            local bounds = spawnZoneCollider.bounds
            spawnBoundsMin = bounds.min
            spawnBoundsMax = bounds.max
            Debug.Log("[SpawnManager] Spawn zone bounds - Min: " .. tostring(spawnBoundsMin) .. ", Max: " .. tostring(spawnBoundsMax))
        else
            Debug.Log("[SpawnManager] SpawnZoneObject does not have BoxCollider!")
        end
    end

    -- ScoreManager 참조
    if ScoreManagerObject then
        scoreManager = ScoreManagerObject:GetLuaComponent("ScoreManager")
    end

    -- 풀 초기화
    InitializePools()

    -- 초기화 완료 플래그 설정
    isInitialized = true

    Debug.Log("[SpawnManager] Initialized with Object Pooling")
end

function start()
    if not isInitialized then return end
    -- 이벤트 리스너 등록
    RegisterEventListeners()
end

function onEnable()
    if not isInitialized then return end
    RegisterEventListeners()
end

function onDisable()
    if not isInitialized then return end
    UnregisterEventListeners()
    StopSpawning()
end

--endregion

--region Event Listeners

function RegisterEventListeners()
    -- EventCallback 제거됨 - 직접 호출 방식 사용
end

function UnregisterEventListeners()
    -- EventCallback 제거됨 - 직접 호출 방식 사용
end

---@details 쓰레기 제거 이벤트 핸들러 (EventCallback에서 호출)
---@param trashObject GameObject 제거된 쓰레기 오브젝트
---@param category string 카테고리
function OnTrashDestroyedEvent(trashObject, category)
    -- activeTrashItems에서 제거
    for i = #activeTrashItems, 1, -1 do
        if activeTrashItems[i].object == trashObject then
            table.remove(activeTrashItems, i)
            break
        end
    end
end

--endregion

--region Pool Management

---@details 자식 오브젝트 수집 유틸리티 함수
---@param parentObj GameObject 부모 오브젝트
---@param objTable table 오브젝트 저장 테이블
---@param scriptTable table 스크립트 저장 테이블
---@param scriptName string 스크립트 이름
function GetChildren(parentObj, objTable, scriptTable, scriptName)
    -- 테이블 초기화
    for i = 1, #objTable do objTable[i] = nil end
    if scriptTable then
        for i = 1, #scriptTable do scriptTable[i] = nil end
    end

    -- 자식 수집
    for i = 0, parentObj.transform.childCount - 1 do
        local child = parentObj.transform:GetChild(i).gameObject
        objTable[#objTable + 1] = child

        if scriptTable and scriptName then
            local script = child:GetLuaComponent(scriptName)
            scriptTable[#scriptTable + 1] = script
        end
    end
end

---@details 모든 풀 초기화
function InitializePools()
    for category, poolParent in pairs(poolParents) do
        if poolParent then
            InitializePool(category, poolParent)
        else
            Debug.Log("[SpawnManager] Pool parent not found for: " .. category)
        end
    end

    Debug.Log("[SpawnManager] All pools initialized")
end

---@details 단일 카테고리 풀 초기화
---@param category string 카테고리명
---@param poolParent GameObject 풀 부모 오브젝트
function InitializePool(category, poolParent)
    if not poolParent then
        Debug.Log("[SpawnManager] Pool parent is nil for: " .. category)
        return
    end

    -- 기존 테이블 초기화
    poolObjects[category] = {}
    poolScripts[category] = {}
    poolInitialPose[category] = {}
    pools[category].available = {}
    pools[category].inUse = {}

    -- GetChildren으로 자식 오브젝트 수집
    GetChildren(poolParent, poolObjects[category], poolScripts[category], "TrashItem")

    -- 초기 위치/회전 저장 및 풀에 추가
    for i, obj in ipairs(poolObjects[category]) do
        -- 초기 위치 저장
        poolInitialPose[category][i] = {
            Pos = obj.transform.position,
            Rot = obj.transform.rotation
        }

        -- available 풀에 추가
        table.insert(pools[category].available, i)

        -- TrashItem 스크립트 초기화
        if poolScripts[category][i] then
            poolScripts[category][i].SetCategory(category)
            poolScripts[category][i].SetSpawnManager(self)
            poolScripts[category][i].SetScoreManager(scoreManager)
            poolScripts[category][i].SetPoolIndex(i)
        end

        -- 비활성화
        obj:SetActive(false)
    end

    Debug.Log("[SpawnManager] Pool initialized: " .. category .. " (" .. #poolObjects[category] .. " items)")
end

---@details 풀에서 오브젝트 가져오기
---@param category string 카테고리명
---@return GameObject|nil, TrashItem|nil, number 오브젝트, 스크립트, 인덱스
function GetFromPool(category)
    local pool = pools[category]
    if not pool or #pool.available == 0 then
        Debug.Log("[SpawnManager] No available object in pool: " .. category)
        return nil, nil, -1
    end

    -- available에서 하나 가져오기
    local index = pool.available[1]
    table.remove(pool.available, 1)
    table.insert(pool.inUse, index)

    local obj = poolObjects[category][index]
    local script = poolScripts[category][index]

    return obj, script, index
end

---@details 풀로 오브젝트 반환
---@param category string 카테고리명
---@param poolIndex number 풀 내 인덱스
function ReturnToPool(category, poolIndex)
    local pool = pools[category]
    if not pool then
        Debug.Log("[SpawnManager] Invalid category: " .. tostring(category))
        return
    end

    -- inUse에서 제거
    for i = #pool.inUse, 1, -1 do
        if pool.inUse[i] == poolIndex then
            table.remove(pool.inUse, i)
            break
        end
    end

    -- 이미 available에 있는지 확인
    for _, idx in ipairs(pool.available) do
        if idx == poolIndex then
            Debug.Log("[SpawnManager] Object already in available pool: " .. category .. " index: " .. poolIndex)
            return
        end
    end

    -- available에 추가
    table.insert(pool.available, poolIndex)

    -- 오브젝트 비활성화 및 위치 복원
    local obj = poolObjects[category][poolIndex]
    local initialPose = poolInitialPose[category][poolIndex]

    if obj then
        -- 강제 릴리즈
        local grabbable = obj:GetComponent("VivenGrabbableModule")
        if grabbable then
            grabbable:Release()
            grabbable:FlushInteractableCollider()
        end

        -- 위치/회전 복원
        if initialPose then
            obj.transform.position = initialPose.Pos
            obj.transform.rotation = initialPose.Rot
        end

        -- 비활성화
        obj:SetActive(false)
    end

    Debug.Log("[SpawnManager] Returned to pool: " .. category .. " index: " .. poolIndex)
end

---@details 모든 오브젝트를 풀로 반환
function ReturnAllToPool()
    for category, pool in pairs(pools) do
        -- inUse 복사본 생성 (반복 중 수정 방지)
        local inUseCopy = {}
        for _, index in ipairs(pool.inUse) do
            table.insert(inUseCopy, index)
        end

        -- 모두 반환
        for _, index in ipairs(inUseCopy) do
            ReturnToPool(category, index)
        end
    end

    activeTrashItems = {}
    Debug.Log("[SpawnManager] All objects returned to pool")
end

--endregion

--region Public Functions

---@details 스폰 설정 초기화
---@param settings table 게임 설정
function InitSpawn(settings)
    Debug.Log("[SpawnManager] InitSpawn called")

    if settings then
        spawnInterval = settings.spawnInterval or 3
        maxTrashCount = settings.maxTrashCount or 5
    end

    -- 스폰 영역 bounds 갱신
    UpdateSpawnBounds()

    -- 기존 활성 쓰레기 모두 풀로 반환
    ReturnAllToPool()

    Debug.Log("[SpawnManager] InitSpawn - Interval: " .. spawnInterval .. "s, MaxCount: " .. maxTrashCount)
end

---@details 스폰 영역 bounds 갱신
function UpdateSpawnBounds()
    if spawnZoneCollider then
        local bounds = spawnZoneCollider.bounds
        spawnBoundsMin = bounds.min
        spawnBoundsMax = bounds.max
    end
end

---@details 스폰 시작
function StartSpawning()
    Debug.Log("[SpawnManager] StartSpawning called")

    if isSpawning then
        Debug.Log("[SpawnManager] Already spawning, returning")
        return
    end

    isSpawning = true
    isPaused = false

    Debug.Log("[SpawnManager] Calling SpawnInitialTrash")
    -- 초기 쓰레기 즉시 스폰
    SpawnInitialTrash()

    -- 스폰 코루틴 시작
    if spawnCoroutine then
        self:StopCoroutine(spawnCoroutine)
    end

    spawnCoroutine = self:StartCoroutine(util.cs_generator(function()
        while isSpawning do
            coroutine.yield(WaitForSeconds(spawnInterval))

            if isSpawning and not isPaused then
                TrySpawnTrash()
            end
        end
    end))

    Debug.Log("[SpawnManager] Spawning started")
end

---@details 스폰 정지
function StopSpawning()
    isSpawning = false
    isPaused = false

    if spawnCoroutine then
        self:StopCoroutine(spawnCoroutine)
        spawnCoroutine = nil
    end

    Debug.Log("[SpawnManager] Spawning stopped")
end

---@details 스폰 일시정지
function PauseSpawning()
    isPaused = true
    Debug.Log("[SpawnManager] Spawning paused")
end

---@details 스폰 재개
function ResumeSpawning()
    isPaused = false
    Debug.Log("[SpawnManager] Spawning resumed")
end

---@details 모든 쓰레기 제거 (풀로 반환)
function ClearAllTrash()
    ReturnAllToPool()
    Debug.Log("[SpawnManager] All trash cleared (returned to pool)")
end

---@details 쓰레기가 제거될 때 호출 (TrashItem에서 직접 호출)
---@param trashObject GameObject 제거된 쓰레기 오브젝트
---@param category string 카테고리
---@param poolIndex number 풀 인덱스
function OnTrashDestroyed(trashObject, category, poolIndex)
    -- activeTrashItems에서 제거
    for i = #activeTrashItems, 1, -1 do
        if activeTrashItems[i].object == trashObject then
            table.remove(activeTrashItems, i)
            break
        end
    end

    -- 풀로 반환
    if category and poolIndex and poolIndex > 0 then
        ReturnToPool(category, poolIndex)
    end
end

--endregion

--region Spawning Logic

---@details 초기 쓰레기 스폰 (게임 시작 시)
function SpawnInitialTrash()
    local initialCount = math.min(3, maxTrashCount)
    Debug.Log("[SpawnManager] SpawnInitialTrash - spawning " .. initialCount .. " items")

    for i = 1, initialCount do
        local success = SpawnRandomTrash()
        Debug.Log("[SpawnManager] SpawnRandomTrash #" .. i .. " result: " .. tostring(success))
    end
end

---@details 쓰레기 스폰 시도
function TrySpawnTrash()
    if #activeTrashItems >= maxTrashCount then
        return false
    end

    return SpawnRandomTrash()
end

---@details 랜덤 쓰레기 스폰
---@return boolean 스폰 성공 여부
function SpawnRandomTrash()
    -- 랜덤 카테고리 선택
    local category = GetRandomCategory()
    if not category then
        Debug.Log("[SpawnManager] SpawnRandomTrash - no category available")
        return false
    end

    Debug.Log("[SpawnManager] SpawnRandomTrash - category: " .. category)

    -- 랜덤 위치 선택 (BoxCollider bounds 내)
    local position = GetRandomSpawnPosition()
    Debug.Log("[SpawnManager] SpawnRandomTrash - position: " .. tostring(position))

    return SpawnTrash(category, position)
end

---@details 쓰레기 스폰 (풀링 방식)
---@param category string 카테고리
---@param position Vector3 스폰 위치
---@return boolean 스폰 성공 여부
function SpawnTrash(category, position)
    -- 풀에서 가져오기
    local trashObject, trashScript, poolIndex = GetFromPool(category)

    if not trashObject then
        Debug.Log("[SpawnManager] Failed to get object from pool: " .. category)
        return false
    end

    -- 위치 설정
    trashObject.transform.position = position
    trashObject.transform.rotation = CS.UnityEngine.Quaternion.identity

    -- 활성화
    trashObject:SetActive(true)

    -- TrashItem 리셋
    if trashScript then
        trashScript.ResetTrash(category, position, poolIndex)
    end

    -- FloatingBehavior 리셋
    local floatingBehavior = trashObject:GetLuaComponent("FloatingBehavior")
    if floatingBehavior then
        floatingBehavior.ResetFloating(position, {
            noiseScale = 0.5,
            noiseSpeed = 0.3,
            floatRange = 0.1,
            rotationSpeed = 5
        })
    end

    -- 활성 목록에 추가
    table.insert(activeTrashItems, {
        object = trashObject,
        category = category,
        poolIndex = poolIndex
    })

    -- 이벤트 발생 (EventCallback 제거됨)

    Debug.Log("[SpawnManager] Spawned " .. category .. " at " .. tostring(position) .. " (poolIndex: " .. poolIndex .. ")")

    return true
end

--endregion

--region Utility Functions

---@details 랜덤 카테고리 선택 (available 풀이 있는 카테고리만)
---@return string|nil
function GetRandomCategory()
    local availableCategories = {}

    for category, pool in pairs(pools) do
        if #pool.available > 0 then
            table.insert(availableCategories, category)
        end
    end

    if #availableCategories == 0 then
        Debug.Log("[SpawnManager] No available categories!")
        return nil
    end

    local index = math.random(1, #availableCategories)
    return availableCategories[index]
end

---@details BoxCollider bounds 내에서 랜덤 위치 선택
---@return Vector3
function GetRandomSpawnPosition()
    if not spawnBoundsMin or not spawnBoundsMax then
        -- bounds가 없으면 기본 위치 반환
        Debug.Log("[SpawnManager] Spawn bounds not set, using default position")
        return Vector3(0, 1.5, 1)
    end

    -- bounds 내 랜덤 위치 계산
    local randomX = spawnBoundsMin.x + math.random() * (spawnBoundsMax.x - spawnBoundsMin.x)
    local randomY = spawnBoundsMin.y + math.random() * (spawnBoundsMax.y - spawnBoundsMin.y)
    local randomZ = spawnBoundsMin.z + math.random() * (spawnBoundsMax.z - spawnBoundsMin.z)

    return Vector3(randomX, randomY, randomZ)
end

---@details 현재 활성 쓰레기 수 반환
---@return number
function GetActiveTrashCount()
    return #activeTrashItems
end

---@details 스폰 상태 반환
---@return boolean
function IsSpawning()
    return isSpawning
end

---@details 카테고리별 풀 상태 반환 (디버그용)
---@return table
function GetPoolStatus()
    local status = {}
    for category, pool in pairs(pools) do
        status[category] = {
            available = #pool.available,
            inUse = #pool.inUse,
            total = #poolObjects[category]
        }
    end
    return status
end

--endregion
