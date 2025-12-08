--- SlideUIManager: 게임 가이드 슬라이드 UI
--- How to Play 슬라이드 네비게이션

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
---@details 슬라이드 1 오브젝트
Slide1 = checkInject(Slide1)

---@type GameObject
---@details 슬라이드 2 오브젝트
Slide2 = NullableInject(Slide2)

---@type GameObject
---@details 슬라이드 3 오브젝트
Slide3 = NullableInject(Slide3)

---@type GameObject
---@details 슬라이드 4 오브젝트
Slide4 = NullableInject(Slide4)

---@type GameObject
---@details 슬라이드 5 오브젝트
Slide5 = NullableInject(Slide5)

---@type GameObject
---@details 이전 버튼
PrevButton = checkInject(PrevButton)

---@type GameObject
---@details 다음 버튼
NextButton = checkInject(NextButton)

---@type GameObject
---@details 완료/시작 버튼 (선택, 마지막 슬라이드에서 표시)
CompleteButton = NullableInject(CompleteButton)

---@type GameObject
---@details 인디케이터 도트 1 (선택)
Dot1 = NullableInject(Dot1)

---@type GameObject
---@details 인디케이터 도트 2 (선택)
Dot2 = NullableInject(Dot2)

---@type GameObject
---@details 인디케이터 도트 3 (선택)
Dot3 = NullableInject(Dot3)

---@type GameObject
---@details 인디케이터 도트 4 (선택)
Dot4 = NullableInject(Dot4)

---@type GameObject
---@details 인디케이터 도트 5 (선택)
Dot5 = NullableInject(Dot5)

--endregion

--region Variables

---@type number
---@details 현재 슬라이드 인덱스 (1부터 시작)
local currentIndex = 1

---@type number
---@details 총 슬라이드 수
local totalSlides = 0

---@type table
---@details 슬라이드 오브젝트 테이블
local slideObjects = {}

---@type table
---@details 인디케이터 도트 테이블
local indicatorDots = {}

---@type Button
---@details 이전 버튼 컴포넌트
local prevButtonComp = nil

---@type Button
---@details 다음 버튼 컴포넌트
local nextButtonComp = nil

---@type Button
---@details 완료 버튼 컴포넌트
local completeButtonComp = nil

--endregion

--region Unity Lifecycle

function awake()
    -- 슬라이드 오브젝트 테이블 구성
    slideObjects = {}
    if Slide1 then table.insert(slideObjects, Slide1) end
    if Slide2 then table.insert(slideObjects, Slide2) end
    if Slide3 then table.insert(slideObjects, Slide3) end
    if Slide4 then table.insert(slideObjects, Slide4) end
    if Slide5 then table.insert(slideObjects, Slide5) end

    totalSlides = #slideObjects

    -- 인디케이터 도트 테이블 구성
    indicatorDots = {}
    if Dot1 then table.insert(indicatorDots, Dot1) end
    if Dot2 then table.insert(indicatorDots, Dot2) end
    if Dot3 then table.insert(indicatorDots, Dot3) end
    if Dot4 then table.insert(indicatorDots, Dot4) end
    if Dot5 then table.insert(indicatorDots, Dot5) end

    -- 버튼 컴포넌트 가져오기
    prevButtonComp = PrevButton:GetComponent(typeof(CS.UnityEngine.UI.Button))
    nextButtonComp = NextButton:GetComponent(typeof(CS.UnityEngine.UI.Button))

    if CompleteButton then
        completeButtonComp = CompleteButton:GetComponent(typeof(CS.UnityEngine.UI.Button))
    end

    Debug.Log("[SlideUIManager] Initialized with " .. totalSlides .. " slides")
end

function start()
    -- 첫 번째 슬라이드 표시
    ShowSlide(1)
end

function onEnable()
    -- 버튼 이벤트 등록
    if prevButtonComp then
        prevButtonComp.onClick:AddListener(OnPrevClick)
        Debug.Log("[SlideUIManager] PrevButton listener added")
    end
    if nextButtonComp then
        nextButtonComp.onClick:AddListener(OnNextClick)
        Debug.Log("[SlideUIManager] NextButton listener added")
    end
    if completeButtonComp then
        completeButtonComp.onClick:AddListener(OnCompleteClick)
        Debug.Log("[SlideUIManager] CompleteButton listener added")
    else
        Debug.Log("[SlideUIManager] WARNING: CompleteButton component is nil!")
    end

    -- 첫 슬라이드로 리셋 (슬라이드가 있으면)
    if totalSlides > 0 then
        ShowSlide(1)
    else
        -- 슬라이드가 없으면 Complete 버튼만 활성화
        Debug.Log("[SlideUIManager] No slides, showing CompleteButton only")
        if CompleteButton then
            CompleteButton:SetActive(true)
        end
    end
end

function onDisable()
    -- 버튼 이벤트 해제
    if prevButtonComp then
        prevButtonComp.onClick:RemoveListener(OnPrevClick)
    end
    if nextButtonComp then
        nextButtonComp.onClick:RemoveListener(OnNextClick)
    end
    if completeButtonComp then
        completeButtonComp.onClick:RemoveListener(OnCompleteClick)
    end
end

--endregion

--region Button Handlers

---@details 이전 버튼 클릭
function OnPrevClick()
    if currentIndex > 1 then
        ShowSlide(currentIndex - 1)
    end
end

---@details 다음 버튼 클릭
function OnNextClick()
    if currentIndex < totalSlides then
        ShowSlide(currentIndex + 1)
    end
end

---@details 완료 버튼 클릭
function OnCompleteClick()
    Debug.Log("[SlideUIManager] Complete button clicked!")

    -- GameManager를 찾아서 직접 호출
    local gameManagerObj = CS.UnityEngine.GameObject.Find("GameManager")
    if gameManagerObj then
        local gameManager = gameManagerObj:GetLuaComponent("GameManager")
        if gameManager then
            gameManager.OnGuideComplete()
            Debug.Log("[SlideUIManager] Called GameManager.OnGuideComplete()")
        else
            Debug.Log("[SlideUIManager] ERROR: GameManager Lua component not found")
        end
    else
        Debug.Log("[SlideUIManager] ERROR: GameManager GameObject not found")
    end
end

--endregion

--region Slide Navigation

---@details 특정 슬라이드 표시
---@param index number 슬라이드 인덱스 (1부터)
function ShowSlide(index)
    -- 범위 체크
    if index < 1 then index = 1 end
    if index > totalSlides then index = totalSlides end

    currentIndex = index

    -- 모든 슬라이드 비활성화
    for i = 1, totalSlides do
        if slideObjects[i] then
            slideObjects[i]:SetActive(false)
        end
    end

    -- 현재 슬라이드 활성화
    if slideObjects[currentIndex] then
        slideObjects[currentIndex]:SetActive(true)
    end

    -- 버튼 상태 업데이트
    UpdateButtonStates()

    -- 인디케이터 업데이트
    UpdateIndicators()

    Debug.Log("[SlideUIManager] Showing slide " .. currentIndex .. "/" .. totalSlides)
end

---@details 버튼 상태 업데이트
function UpdateButtonStates()
    -- 이전 버튼: 첫 슬라이드에서 비활성화
    if PrevButton then
        PrevButton:SetActive(currentIndex > 1)
    end

    -- 다음 버튼: 마지막 슬라이드에서 비활성화 (완료 버튼 표시)
    if NextButton then
        NextButton:SetActive(currentIndex < totalSlides)
    end

    -- 완료 버튼: 마지막 슬라이드에서만 표시
    if CompleteButton then
        CompleteButton:SetActive(currentIndex == totalSlides)
    end
end

---@details 인디케이터 도트 업데이트
function UpdateIndicators()
    for i = 1, #indicatorDots do
        if indicatorDots[i] then
            -- 현재 슬라이드의 도트는 활성화 표시 (색상 변경 등)
            local image = indicatorDots[i]:GetComponent(typeof(CS.UnityEngine.UI.Image))
            if image then
                if i == currentIndex then
                    image.color = CS.UnityEngine.Color.white
                else
                    image.color = CS.UnityEngine.Color(0.5, 0.5, 0.5, 1)
                end
            end
        end
    end
end

--endregion

--region Public Functions

---@details 현재 슬라이드 인덱스 반환
---@return number
function GetCurrentIndex()
    return currentIndex
end

---@details 총 슬라이드 수 반환
---@return number
function GetTotalSlides()
    return totalSlides
end

---@details 첫 슬라이드로 리셋
function Reset()
    ShowSlide(1)
end

--endregion
