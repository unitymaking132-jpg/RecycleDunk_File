--- TrashItem: 쓰레기 아이템 스크립트
--- 잡기, 던지기, 쓰레기통 판정 처리

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
---@details 쓰레기 카테고리 ("Paper", "Plastic", "Glass", "Metal", "GeneralGarbage")
TrashCategory = NullableInject(TrashCategory)

---@type GameObject
---@details ScoreManager 오브젝트
ScoreManagerObject = NullableInject(ScoreManagerObject)

---@type GameObject
---@details SpawnManager 오브젝트 (콜백용)
SpawnManagerObject = NullableInject(SpawnManagerObject)

--endregion

--region Variables

---@type VivenGrabbableModule
---@details 잡기 모듈
local grabbableModule = nil

---@type FloatingBehavior
---@details 떠다니기 동작
local floatingBehavior = nil

---@type ScoreManager
---@details 점수 매니저
local scoreManager = nil

---@type SpawnManager
---@details 스폰 매니저 (콜백용)
local spawnManager = nil

---@type boolean
---@details 현재 잡힌 상태
local isGrabbed = false

---@type boolean
---@details 이미 판정 완료 여부 (중복 판정 방지)
local isJudged = false

---@type Vector3
---@details 스폰 위치
local spawnPosition = nil

---@type string
---@details 아이템 표시 이름
local displayName = ""

---@type number
---@details 풀 내 인덱스 (반환 시 사용)
local poolIndex = -1

---@type string
---@details 현재 카테고리 (동적 설정)
local currentCategory = "Misc"

--endregion

--region Unity Lifecycle

function awake()
    -- 컴포넌트 가져오기
    grabbableModule = self:GetComponent("VivenGrabbableModule")
    floatingBehavior = self:GetLuaComponent("FloatingBehavior")

    -- ScoreManager 참조
    if ScoreManagerObject then
        scoreManager = ScoreManagerObject:GetLuaComponent("ScoreManager")
    end

    -- SpawnManager 참조
    if SpawnManagerObject then
        spawnManager = SpawnManagerObject:GetLuaComponent("SpawnManager")
    end

    -- 스폰 위치 저장
    spawnPosition = self.transform.position

    -- 기본 카테고리 설정
    if not TrashCategory then
        TrashCategory = "Misc"
    end
    currentCategory = TrashCategory
end

function start()
    -- 카테고리 유효성 검사
    if not IsValidCategory(TrashCategory) then
        Debug.Log("[TrashItem] Invalid category: " .. tostring(TrashCategory) .. ", using Misc")
        TrashCategory = "Misc"
    end
    currentCategory = TrashCategory

    Debug.Log("[TrashItem] Initialized - Category: " .. TrashCategory)
end

function onEnable()
    -- 이벤트 리스너 등록
    if grabbableModule then
        grabbableModule.onGrabEvent:AddListener(OnGrab)
        grabbableModule.onReleaseEvent:AddListener(OnRelease)
    end

    -- 상태 초기화
    isJudged = false
    isGrabbed = false
end

function onDisable()
    -- 이벤트 리스너 해제
    if grabbableModule then
        grabbableModule.onGrabEvent:RemoveListener(OnGrab)
        grabbableModule.onReleaseEvent:RemoveListener(OnRelease)
    end
end

--endregion

--region Grab Events

---@details 잡기 이벤트 핸들러
function OnGrab()
    isGrabbed = true

    -- 떠다니기 비활성화
    if floatingBehavior then
        floatingBehavior.SetGrabbed(true)
    end

    -- 햅틱 피드백
    PlayGrabHaptic()

    Debug.Log("[TrashItem] Grabbed - Category: " .. TrashCategory)
end

---@details 놓기 이벤트 핸들러
function OnRelease()
    isGrabbed = false

    -- 떠다니기는 재활성화하지 않음 (한번 잡으면 비활성화 유지)
    -- 풀로 돌아갈 때 ResetFloating()에서 다시 활성화됨

    -- 햅틱 피드백
    PlayReleaseHaptic()

    Debug.Log("[TrashItem] Released - Category: " .. TrashCategory)
end

--endregion

--region Collision Detection

---@details 트리거 진입 이벤트
---@param other Collider 충돌한 콜라이더
function onTriggerEnter(other)
    if isJudged then
        return
    end

    -- TrashBin 스크립트 확인
    local trashBin = other.gameObject:GetLuaComponent("TrashBin")
    if trashBin then
        OnEnterTrashBin(trashBin)
    end
end

---@details 쓰레기통 진입 처리 (TrashBin에 판정 위임)
---@param trashBin TrashBin 쓰레기통 스크립트
function OnEnterTrashBin(trashBin)
    if isJudged then
        return
    end

    isJudged = true

    -- TrashBin에 판정 위임 (판정 + ScoreManager 호출 + 이펙트 + 사운드)
    local isCorrect = trashBin.OnTrashEntered(currentCategory, self)

    -- 햅틱 피드백만 처리
    if isCorrect then
        PlayCorrectHaptic()
    else
        PlayWrongHaptic()
    end

    Debug.Log("[TrashItem] Entered bin - Category: " .. currentCategory .. ", IsCorrect: " .. tostring(isCorrect))

    -- 풀로 반환
    ReturnToPool()
end

--endregion

--region Haptic Feedback

---@details 정답 햅틱 피드백 재생
function PlayCorrectHaptic()
    XR.StartControllerVibration(false, 0.3, 0.15)
    XR.StartControllerVibration(true, 0.3, 0.15)
end

---@details 오답 햅틱 피드백 재생 (더 강하게)
function PlayWrongHaptic()
    XR.StartControllerVibration(false, 0.8, 0.3)
    XR.StartControllerVibration(true, 0.8, 0.3)
end

---@details 잡기 햅틱 피드백
function PlayGrabHaptic()
    XR.StartControllerVibration(false, 0.2, 0.05)
    XR.StartControllerVibration(true, 0.2, 0.05)
end

---@details 놓기 햅틱 피드백
function PlayReleaseHaptic()
    XR.StartControllerVibration(false, 0.1, 0.03)
    XR.StartControllerVibration(true, 0.1, 0.03)
end

--endregion

--region Public Functions

---@details 쓰레기 아이템 리셋 (풀에서 활성화 시 SpawnManager에서 호출)
---@param category string 쓰레기 카테고리
---@param position Vector3 스폰 위치
---@param index number 풀 내 인덱스
function ResetTrash(category, position, index)
    currentCategory = category or TrashCategory or "Misc"
    TrashCategory = currentCategory
    spawnPosition = position or self.transform.position
    poolIndex = index or -1

    -- 상태 초기화
    isJudged = false
    isGrabbed = false

    -- 떠다니기 리셋
    if floatingBehavior then
        floatingBehavior.ResetFloating(spawnPosition, nil)
    end

    Debug.Log("[TrashItem] ResetTrash - Category: " .. currentCategory .. ", PoolIndex: " .. poolIndex)
end

---@details 카테고리 반환
---@return string
function GetCategory()
    return TrashCategory
end

---@details 잡힌 상태 반환
---@return boolean
function IsGrabbed()
    return isGrabbed
end

---@details 판정 완료 여부 반환
---@return boolean
function IsJudged()
    return isJudged
end

---@details 쓰레기를 풀로 반환
function ReturnToPool()
    -- 강제 릴리즈
    if grabbableModule then
        grabbableModule:Release()
        grabbableModule:FlushInteractableCollider()
    end

    -- SpawnManager에 반환 알림
    if spawnManager and spawnManager.OnTrashDestroyed then
        spawnManager.OnTrashDestroyed(self.gameObject, currentCategory, poolIndex)
    end

    Debug.Log("[TrashItem] ReturnToPool - Category: " .. currentCategory .. ", PoolIndex: " .. poolIndex)
end

---@details 경계 이탈 처리
function OnBoundaryExit()
    if isJudged then
        return
    end

    isJudged = true

    -- HP 감소
    if scoreManager then
        scoreManager.OnTrashLost(currentCategory)
    end

    Debug.Log("[TrashItem] Lost (boundary exit) - Category: " .. currentCategory)

    -- 풀로 반환
    ReturnToPool()
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

---@details 카테고리 설정 (풀 초기화 시 사용)
---@param category string 카테고리
function SetCategory(category)
    TrashCategory = category
    currentCategory = category
end

---@details SpawnManager 참조 설정
---@param manager SpawnManager
function SetSpawnManager(manager)
    spawnManager = manager
end

---@details ScoreManager 참조 설정
---@param manager ScoreManager
function SetScoreManager(manager)
    scoreManager = manager
end

---@details 풀 인덱스 반환
---@return number
function GetPoolIndex()
    return poolIndex
end

---@details 풀 인덱스 설정
---@param index number
function SetPoolIndex(index)
    poolIndex = index
end

--endregion
