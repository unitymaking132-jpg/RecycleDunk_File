--- SpawnManager: 쓰레기 스폰 관리
--- 쓰레기 아이템의 생성, 위치, 타이밍을 관리
--- BoxCollider의 bounds를 이용한 랜덤 스폰

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
---@details 스폰 영역 오브젝트 (BoxCollider 포함)
SpawnZoneObject = NullableInject(SpawnZoneObject)

---@type GameObject[]
---@details Paper 쓰레기 프리팹 배열
PaperPrefabs = NullableInject(PaperPrefabs)

---@type GameObject[]
---@details Plastic 쓰레기 프리팹 배열
PlasticPrefabs = NullableInject(PlasticPrefabs)

---@type GameObject[]
---@details Glass 쓰레기 프리팹 배열
GlassPrefabs = NullableInject(GlassPrefabs)

---@type GameObject[]
---@details Metal 쓰레기 프리팹 배열
MetalPrefabs = NullableInject(MetalPrefabs)

---@type GameObject[]
---@details GeneralGarbage 쓰레기 프리팹 배열
GeneralGarbagePrefabs = NullableInject(GeneralGarbagePrefabs)

---@type GameObject
---@details ScoreManager 오브젝트
ScoreManagerObject = NullableInject(ScoreManagerObject)

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
---@details 활성화된 쓰레기 아이템 목록
local activeTrashItems = {}

---@type table
---@details 카테고리별 프리팹 테이블
local prefabsByCategory = {}

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

--endregion

--region Unity Lifecycle

function awake()
    -- 카테고리별 프리팹 테이블 구성
    prefabsByCategory = {
        Paper = PaperPrefabs or {},
        Plastic = PlasticPrefabs or {},
        Glass = GlassPrefabs or {},
        Metal = MetalPrefabs or {},
        GeneralGarbage = GeneralGarbagePrefabs or {}
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
            Debug.LogWarning("[SpawnManager] SpawnZoneObject does not have BoxCollider!")
        end
    end

    -- ScoreManager 참조
    if ScoreManagerObject then
        scoreManager = ScoreManagerObject:GetLuaComponent("ScoreManager")
    end

    Debug.Log("[SpawnManager] Initialized")
end

function start()
    -- 이벤트 리스너 등록
    RegisterEventListeners()
end

function onEnable()
    RegisterEventListeners()
end

function onDisable()
    UnregisterEventListeners()
    StopSpawning()
end

--endregion

--region Event Listeners

function RegisterEventListeners()
    GameEvent.registerEvent("onTrashDestroyed", OnTrashDestroyed)
end

function UnregisterEventListeners()
    GameEvent.unregisterEvent("onTrashDestroyed", OnTrashDestroyed)
end

---@details 쓰레기 제거 이벤트 핸들러
---@param trashObject GameObject 제거된 쓰레기 오브젝트
---@param category string 카테고리
function OnTrashDestroyed(trashObject, category)
    -- 활성 목록에서 제거
    for i = #activeTrashItems, 1, -1 do
        if activeTrashItems[i] == trashObject then
            table.remove(activeTrashItems, i)
            break
        end
    end
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

    -- 스폰 영역 bounds 갱신 (런타임에 변경될 수 있으므로)
    UpdateSpawnBounds()

    -- 기존 쓰레기 모두 제거
    ClearAllTrash()

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
    if isSpawning then
        return
    end

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

---@details 모든 쓰레기 제거
function ClearAllTrash()
    for i = #activeTrashItems, 1, -1 do
        local trash = activeTrashItems[i]
        if trash and trash.gameObject then
            trash.gameObject:SetActive(false)
        end
    end
    activeTrashItems = {}

    Debug.Log("[SpawnManager] All trash cleared")
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
    -- 랜덤 카테고리 선택
    local category = GetRandomCategory()

    -- 랜덤 위치 선택 (BoxCollider bounds 내)
    local position = GetRandomSpawnPosition()

    return SpawnTrash(category, position)
end

---@details 쓰레기 스폰
---@param category string 카테고리
---@param position Vector3 스폰 위치
---@return boolean 스폰 성공 여부
function SpawnTrash(category, position)
    -- 프리팹 가져오기
    local prefab = GetRandomPrefab(category)
    if not prefab then
        Debug.LogWarning("[SpawnManager] No prefab found for category: " .. category)
        return false
    end

    -- 오브젝트 생성
    local trashObject = CS.UnityEngine.Object.Instantiate(prefab, position, CS.UnityEngine.Quaternion.identity)

    -- TrashItem 스크립트 초기화
    local trashItem = trashObject:GetLuaComponent("TrashItem")
    if trashItem then
        trashItem.InitTrash(category, position)

        -- ScoreManager 참조 설정
        if scoreManager then
            -- ScoreManagerObject 주입은 프리팹에서 설정
        end
    end

    -- FloatingBehavior 초기화
    local floatingBehavior = trashObject:GetLuaComponent("FloatingBehavior")
    if floatingBehavior then
        floatingBehavior.InitFloating({
            noiseScale = 0.5,
            noiseSpeed = 0.3,
            floatRange = 0.1,
            rotationSpeed = 5
        })
    end

    -- 활성 목록에 추가
    table.insert(activeTrashItems, trashObject)

    -- 이벤트 발생
    GameEvent.invoke("onTrashSpawn", trashObject, category)

    Debug.Log("[SpawnManager] Spawned " .. category .. " at " .. tostring(position))

    return true
end

--endregion

--region Utility Functions

---@details 랜덤 카테고리 선택
---@return string
function GetRandomCategory()
    local categories = { "Paper", "Plastic", "Glass", "Metal", "GeneralGarbage" }
    local index = math.random(1, #categories)
    return categories[index]
end

---@details BoxCollider bounds 내에서 랜덤 위치 선택
---@return Vector3
function GetRandomSpawnPosition()
    if not spawnBoundsMin or not spawnBoundsMax then
        -- bounds가 없으면 기본 위치 반환
        Debug.LogWarning("[SpawnManager] Spawn bounds not set, using default position")
        return Vector3(0, 1.5, 1)
    end

    -- bounds 내 랜덤 위치 계산
    local randomX = spawnBoundsMin.x + math.random() * (spawnBoundsMax.x - spawnBoundsMin.x)
    local randomY = spawnBoundsMin.y + math.random() * (spawnBoundsMax.y - spawnBoundsMin.y)
    local randomZ = spawnBoundsMin.z + math.random() * (spawnBoundsMax.z - spawnBoundsMin.z)

    return Vector3(randomX, randomY, randomZ)
end

---@details 카테고리에서 랜덤 프리팹 선택
---@param category string 카테고리
---@return GameObject|nil
function GetRandomPrefab(category)
    local prefabs = prefabsByCategory[category]
    if not prefabs or #prefabs == 0 then
        return nil
    end

    local index = math.random(1, #prefabs)
    return prefabs[index]
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

--endregion
