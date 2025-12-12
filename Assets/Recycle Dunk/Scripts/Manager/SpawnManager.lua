--- SpawnManager: 쓰레기 스폰 관리 (Object Pooling 방식)
--- 씬에 미리 배치된 오브젝트를 풀에서 가져와 재사용
--- VIVEN SDK에서 동적 VObject Instantiate가 불가능하므로 풀링 방식 사용

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

---@type boolean
---@details 풀 초기화 중 여부 (FlushAllGrabbables 스킵용)
local isPoolInitializing = false

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

---@type table<string, table>
---@details 카테고리별 MeshRenderer 테이블 (배열의 배열)
local poolMeshRenderers = {
    Paper = {},
    Plastic = {},
    Glass = {},
    Metal = {},
    Misc = {}
}

---@type table<string, table>
---@details 카테고리별 Collider 테이블 (배열의 배열)
local poolColliders = {
    Paper = {},
    Plastic = {},
    Glass = {},
    Metal = {},
    Misc = {}
}

---@type Vector3
---@details 숨김 위치 (풀에서 비활성화 시 이동할 위치)
local HIDE_POSITION = nil

---@type table<string, GameObject>
---@details 카테고리별 풀 부모 매핑
local poolParents = {}

---@type table<string, table>
---@details 카테고리별 VivenGrabbableModule 테이블 (배열)
local poolGrabbables = {
    Paper = {},
    Plastic = {},
    Glass = {},
    Metal = {},
    Misc = {}
}

---@type table
---@details 모든 풀의 VivenGrabbableModule 목록 (Flush용)
local allGrabbableModules = {}

--endregion

--region Unity Lifecycle

function awake()
    -- Pool injection 체크 - 하나도 없으면 스킵 (테스트 모드)
    if not PaperPool and not PlasticPool and not GlassPool and not MetalPool and not MiscPool then
        isInitialized = false
        return
    end

    -- 숨김 위치 초기화 (아주 먼 곳)
    HIDE_POSITION = Vector3(0, -9999, 0)

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
        end
    end

    -- ScoreManager 참조
    if ScoreManagerObject then
        scoreManager = ScoreManagerObject:GetLuaComponent("ScoreManager")
    end

    -- 풀 초기화 (초기화 중 FlushAllGrabbables 스킵)
    isPoolInitializing = true
    InitializePools()
    isPoolInitializing = false

    -- 주의: awake()에서는 FlushAllGrabbables 호출하지 않음
    -- VIVEN SDK가 완전히 초기화된 후 (InitSpawn 또는 StartSpawning에서) 호출

    -- 초기화 완료 플래그 설정
    isInitialized = true
end

function start()
    if not isInitialized then return end
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
end

function UnregisterEventListeners()
end

---@details 쓰레기 제거 이벤트 핸들러
---@param trashObject GameObject 제거된 쓰레기 오브젝트
---@param category string 카테고리
function OnTrashDestroyedEvent(trashObject, category)
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
    for i = 1, #objTable do objTable[i] = nil end
    if scriptTable then
        for i = 1, #scriptTable do scriptTable[i] = nil end
    end

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
        end
    end
end

---@details 단일 카테고리 풀 초기화
---@param category string 카테고리명
---@param poolParent GameObject 풀 부모 오브젝트
function InitializePool(category, poolParent)
    if not poolParent then return end

    -- 기존 테이블 초기화
    poolObjects[category] = {}
    poolScripts[category] = {}
    poolInitialPose[category] = {}
    poolMeshRenderers[category] = {}
    poolColliders[category] = {}
    poolGrabbables[category] = {}
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

        -- MeshRenderer 수집
        local meshRenderers = obj:GetComponentsInChildren(typeof(CS.UnityEngine.MeshRenderer))
        local tempMeshes = {}
        for j = 0, meshRenderers.Length - 1 do
            tempMeshes[#tempMeshes + 1] = meshRenderers[j]
        end
        poolMeshRenderers[category][i] = tempMeshes

        -- Collider 수집
        local colliders = obj:GetComponentsInChildren(typeof(CS.UnityEngine.Collider))
        local tempColliders = {}
        for j = 0, colliders.Length - 1 do
            tempColliders[#tempColliders + 1] = colliders[j]
        end
        poolColliders[category][i] = tempColliders

        -- VivenGrabbableModule 수집
        local grabbable = obj:GetComponent("VivenGrabbableModule")
        poolGrabbables[category][i] = grabbable
        if grabbable then
            allGrabbableModules[#allGrabbableModules + 1] = grabbable
        end

        -- available 풀에 추가
        table.insert(pools[category].available, i)

        -- TrashItem 스크립트 초기화
        if poolScripts[category][i] then
            poolScripts[category][i].SetCategory(category)
            poolScripts[category][i].SetSpawnManager(self)
            poolScripts[category][i].SetScoreManager(scoreManager)
            poolScripts[category][i].SetPoolIndex(i)
        end

        -- 비활성화 (MeshRenderer/Collider 끄기 + 위치 이동)
        SetPoolObjectVisible(category, i, false)
    end
end

---@details 모든 Grabbable의 콜라이더 상태 갱신 (VIVEN SDK 내부 상태 동기화)
function FlushAllGrabbables()
    -- 풀 초기화 중에는 스킵 (아직 모듈이 완전히 수집되지 않음)
    if isPoolInitializing then
        return
    end

    for i = 1, #allGrabbableModules do
        local grabbable = allGrabbableModules[i]
        if grabbable then
            -- pcall로 안전하게 호출 (VIVEN SDK 내부 상태가 준비되지 않은 경우 무시)
            local success, err = pcall(function()
                grabbable:FlushInteractableCollider()
            end)
            -- 에러는 무시 (초기화 타이밍 문제)
        end
    end
end

---@details 풀 오브젝트 가시성 설정 (SetActive 대신 사용)
---@param category string 카테고리명
---@param poolIndex number 풀 인덱스
---@param visible boolean 가시성 여부
function SetPoolObjectVisible(category, poolIndex, visible)
    local obj = poolObjects[category][poolIndex]
    if not obj then return end

    -- 모든 Grabbable 콜라이더 상태 갱신 (VIVEN SDK 동기화)
    FlushAllGrabbables()

    -- MeshRenderer 활성화/비활성화
    local meshRenderers = poolMeshRenderers[category][poolIndex]
    if meshRenderers then
        for _, mr in ipairs(meshRenderers) do
            mr.enabled = visible
        end
    end

    -- Collider 활성화/비활성화
    local colliders = poolColliders[category][poolIndex]
    if colliders then
        for _, col in ipairs(colliders) do
            col.enabled = visible
        end
    end

    -- 숨김 위치로 이동 (비활성화 시)
    if not visible then
        obj.transform.position = HIDE_POSITION
    end
end

---@details 풀에서 오브젝트 가져오기
---@param category string 카테고리명
---@return GameObject|nil, TrashItem|nil, number 오브젝트, 스크립트, 인덱스
function GetFromPool(category)
    local pool = pools[category]
    if not pool or #pool.available == 0 then
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
    if not pool then return end

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
            return
        end
    end

    -- available에 추가
    table.insert(pool.available, poolIndex)

    -- 오브젝트 처리
    local obj = poolObjects[category][poolIndex]

    if obj then
        -- 강제 릴리즈
        local grabbable = poolGrabbables[category][poolIndex]
        if grabbable then
            grabbable:Release()
        end

        -- 비활성화
        SetPoolObjectVisible(category, poolIndex, false)
    end
end

---@details 모든 오브젝트를 풀로 반환
function ReturnAllToPool()
    for category, pool in pairs(pools) do
        local inUseCopy = {}
        for _, index in ipairs(pool.inUse) do
            table.insert(inUseCopy, index)
        end

        for _, index in ipairs(inUseCopy) do
            ReturnToPool(category, index)
        end
    end

    activeTrashItems = {}
end

--endregion

--region Public Functions

---@details 스폰 설정 초기화
---@param settings table 게임 설정
function InitSpawn(settings)
    if settings then
        spawnInterval = settings.spawnInterval or 3
        maxTrashCount = settings.maxTrashCount or 5
    end

    UpdateSpawnBounds()

    -- VIVEN SDK 완전 초기화 후 Flush 호출 (awake에서는 호출하지 않음)
    FlushAllGrabbables()

    ReturnAllToPool()
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
    if isSpawning then return end

    isSpawning = true
    isPaused = false

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
end

---@details 스폰 정지
function StopSpawning()
    isSpawning = false
    isPaused = false

    if spawnCoroutine then
        self:StopCoroutine(spawnCoroutine)
        spawnCoroutine = nil
    end
end

---@details 스폰 일시정지
function PauseSpawning()
    isPaused = true
end

---@details 스폰 재개
function ResumeSpawning()
    isPaused = false
end

---@details 모든 쓰레기 제거 (풀로 반환)
function ClearAllTrash()
    ReturnAllToPool()
end

---@details 쓰레기가 제거될 때 호출 (TrashItem에서 직접 호출)
---@param trashObject GameObject 제거된 쓰레기 오브젝트
---@param category string 카테고리
---@param poolIndex number 풀 인덱스
function OnTrashDestroyed(trashObject, category, poolIndex)
    for i = #activeTrashItems, 1, -1 do
        if activeTrashItems[i].object == trashObject then
            table.remove(activeTrashItems, i)
            break
        end
    end

    if category and poolIndex and poolIndex > 0 then
        ReturnToPool(category, poolIndex)
    end
end

--endregion

--region Spawning Logic

---@details 초기 쓰레기 스폰 (게임 시작 시)
function SpawnInitialTrash()
    local initialCount = math.min(3, maxTrashCount)

    for i = 1, initialCount do
        SpawnRandomTrash()
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
    local category = GetRandomCategory()
    if not category then
        return false
    end

    local position = GetRandomSpawnPosition()

    return SpawnTrash(category, position)
end

---@details 쓰레기 스폰 (풀링 방식)
---@param category string 카테고리
---@param position Vector3 스폰 위치
---@return boolean 스폰 성공 여부
function SpawnTrash(category, position)
    local trashObject, trashScript, poolIndex = GetFromPool(category)

    if not trashObject then
        return false
    end

    -- 위치 설정
    trashObject.transform.position = position
    trashObject.transform.rotation = CS.UnityEngine.Quaternion.identity

    -- 활성화
    SetPoolObjectVisible(category, poolIndex, true)

    -- TrashItem 리셋
    if trashScript then
        trashScript.ResetTrash(category, position, poolIndex)
    end

    -- FloatingBehavior 리셋
    local floatingBehavior = trashObject:GetLuaComponent("FloatingBehavior")
    if floatingBehavior then
        floatingBehavior:ResetFloating(position, {
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
        return nil
    end

    local index = math.random(1, #availableCategories)
    return availableCategories[index]
end

---@details BoxCollider bounds 내에서 랜덤 위치 선택
---@return Vector3
function GetRandomSpawnPosition()
    if not spawnBoundsMin or not spawnBoundsMax then
        return Vector3(0, 1.5, 1)
    end

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
