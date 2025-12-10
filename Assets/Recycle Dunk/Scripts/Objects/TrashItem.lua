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
        TrashCategory = "GeneralGarbage"
    end
end

function start()
    -- 카테고리 유효성 검사
    if not IsValidCategory(TrashCategory) then
        Debug.Log("[TrashItem] Invalid category: " .. tostring(TrashCategory) .. ", using GeneralGarbage")
        TrashCategory = "GeneralGarbage"
    end

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

---@details 쓰레기통 진입 처리
---@param trashBin TrashBin 쓰레기통 스크립트
function OnEnterTrashBin(trashBin)
    if isJudged then
        return
    end

    isJudged = true
    local binCategory = trashBin.GetBinCategory()

    -- 정답 판정
    local isCorrect = (TrashCategory == binCategory)

    if isCorrect then
        -- 정답 처리
        if scoreManager then
            scoreManager.OnCorrectAnswer(TrashCategory)
        end
        PlayCorrectEffect()
        Debug.Log("[TrashItem] Correct! " .. TrashCategory .. " -> " .. binCategory)
    else
        -- 오답 처리
        if scoreManager then
            scoreManager.OnWrongAnswer(TrashCategory, binCategory)
        end
        PlayWrongEffect()
        Debug.Log("[TrashItem] Wrong! " .. TrashCategory .. " -> " .. binCategory)
    end

    -- 쓰레기 제거
    DestroyTrash()
end

--endregion

--region Effects

---@details 정답 이펙트 재생
function PlayCorrectEffect()
    -- 햅틱 피드백
    XR.StartControllerVibration(false, 0.3, 0.15)
    XR.StartControllerVibration(true, 0.3, 0.15)

    -- TODO: 파티클 이펙트 추가
end

---@details 오답 이펙트 재생
function PlayWrongEffect()
    -- 햅틱 피드백 (더 강하게)
    XR.StartControllerVibration(false, 0.8, 0.3)
    XR.StartControllerVibration(true, 0.8, 0.3)

    -- TODO: 파티클 이펙트 추가
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

---@details 쓰레기 아이템 초기화 (SpawnManager에서 호출)
---@param category string 쓰레기 카테고리
---@param position Vector3 스폰 위치
---@param spawnMgr SpawnManager 스폰 매니저 참조
---@param scoreMgr ScoreManager 점수 매니저 참조
function InitTrash(category, position, spawnMgr, scoreMgr)
    TrashCategory = category or TrashCategory or "GeneralGarbage"
    spawnPosition = position or self.transform.position

    -- 매니저 참조 설정
    if spawnMgr then
        spawnManager = spawnMgr
    end
    if scoreMgr then
        scoreManager = scoreMgr
    end

    isJudged = false
    isGrabbed = false

    -- 떠다니기 초기화
    if floatingBehavior then
        floatingBehavior.SetSpawnPosition(spawnPosition)
        floatingBehavior.InitFloating(nil)
    end

    Debug.Log("[TrashItem] InitTrash - Category: " .. TrashCategory)
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

---@details 쓰레기 제거
function DestroyTrash()
    -- 강제 릴리즈
    if grabbableModule and isGrabbed then
        grabbableModule:Release()
    end

    -- SpawnManager에 알림
    if spawnManager and spawnManager.OnTrashDestroyed then
        spawnManager.OnTrashDestroyed(self.gameObject, TrashCategory)
    end

    -- 오브젝트 비활성화 (풀링용) 또는 제거
    self.gameObject:SetActive(false)
end

---@details 경계 이탈 처리
function OnBoundaryExit()
    if isJudged then
        return
    end

    isJudged = true

    -- HP 감소
    if scoreManager then
        scoreManager.OnTrashLost(TrashCategory)
    end

    Debug.Log("[TrashItem] Lost (boundary exit) - Category: " .. TrashCategory)

    -- 쓰레기 제거
    DestroyTrash()
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
        GeneralGarbage = true
    }
    return validCategories[category] == true
end

--endregion
