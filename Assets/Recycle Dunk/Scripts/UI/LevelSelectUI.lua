--- LevelSelectUI: 난이도 선택 UI
--- Easy, Hard 레벨 선택

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
---@details Easy 버튼
EasyButton = checkInject(EasyButton)

---@type GameObject
---@details Hard 버튼
HardButton = checkInject(HardButton)

---@type GameObject
---@details 뒤로가기 버튼 (선택)
BackButton = NullableInject(BackButton)

---@type GameObject
---@details 난이도 설명 텍스트 오브젝트 (선택)
DescriptionTextObject = NullableInject(DescriptionTextObject)

--endregion

--region Variables

---@type Button
---@details Easy 버튼 컴포넌트
local easyButtonComp = nil

---@type Button
---@details Hard 버튼 컴포넌트
local hardButtonComp = nil

---@type Button
---@details 뒤로가기 버튼 컴포넌트
local backButtonComp = nil

---@type TMP_Text
---@details 난이도 설명 텍스트 컴포넌트
local descriptionText = nil

---@type table
---@details 난이도별 설명
local levelDescriptions = {
    Easy = "Game Time: 60 sec\nSpawn Speed: Slow\nRecommended for beginners!",
    Hard = "Game Time: 90 sec\nSpawn Speed: Fast\nFor recycling experts!"
}

--endregion

--region Unity Lifecycle

function awake()
    -- 버튼 컴포넌트 가져오기
    easyButtonComp = EasyButton:GetComponent(typeof(CS.UnityEngine.UI.Button))
    hardButtonComp = HardButton:GetComponent(typeof(CS.UnityEngine.UI.Button))

    if BackButton then
        backButtonComp = BackButton:GetComponent(typeof(CS.UnityEngine.UI.Button))
    end

    if DescriptionTextObject then
        descriptionText = DescriptionTextObject:GetComponent(typeof(TMP_Text))
    end
end

function start()
    Debug.Log("[LevelSelectUI] Initialized")
end

function onEnable()
    -- 버튼 이벤트 등록
    if easyButtonComp then
        easyButtonComp.onClick:AddListener(OnEasyClick)
    end
    if hardButtonComp then
        hardButtonComp.onClick:AddListener(OnHardClick)
    end
    if backButtonComp then
        backButtonComp.onClick:AddListener(OnBackClick)
    end

    -- 초기 설명 텍스트 설정
    UpdateDescription("Easy")
end

function onDisable()
    -- 버튼 이벤트 해제
    if easyButtonComp then
        easyButtonComp.onClick:RemoveListener(OnEasyClick)
    end
    if hardButtonComp then
        hardButtonComp.onClick:RemoveListener(OnHardClick)
    end
    if backButtonComp then
        backButtonComp.onClick:RemoveListener(OnBackClick)
    end
end

--endregion

--region Button Handlers

---@details GameManager를 찾아서 반환
---@return table|nil GameManager Lua 컴포넌트
function GetGameManager()
    local gameManagerObj = CS.UnityEngine.GameObject.Find("GameManager")
    if gameManagerObj then
        return gameManagerObj:GetLuaComponent("GameManager")
    end
    Debug.Log("[LevelSelectUI] ERROR: GameManager not found")
    return nil
end

---@details Easy 버튼 클릭
function OnEasyClick()
    Debug.Log("[LevelSelectUI] Easy button clicked")
    SelectLevel("Easy")
end

---@details Hard 버튼 클릭
function OnHardClick()
    Debug.Log("[LevelSelectUI] Hard button clicked")
    SelectLevel("Hard")
end

---@details 뒤로가기 버튼 클릭
function OnBackClick()
    Debug.Log("[LevelSelectUI] Back button clicked")

    local gameManager = GetGameManager()
    if gameManager then
        gameManager.OnGoToMain()
    end
end

--endregion

--region Level Selection

---@details 레벨 선택
---@param level string 난이도 ("Easy", "Hard")
function SelectLevel(level)
    Debug.Log("[LevelSelectUI] Level selected: " .. level)

    local gameManager = GetGameManager()
    if gameManager then
        gameManager.OnLevelSelected(level)
    end
end

---@details 난이도 설명 업데이트
---@param level string 난이도
function UpdateDescription(level)
    if descriptionText and levelDescriptions[level] then
        descriptionText.text = levelDescriptions[level]
    end
end

--endregion

--region Hover Events (Optional)

---@details Easy 버튼 호버 진입
function OnEasyHoverEnter()
    UpdateDescription("Easy")
end

---@details Hard 버튼 호버 진입
function OnHardHoverEnter()
    UpdateDescription("Hard")
end

--endregion

--region Public Functions

---@details 모든 버튼 활성화/비활성화
---@param enabled boolean 활성화 여부
function SetButtonsEnabled(enabled)
    if easyButtonComp then
        easyButtonComp.interactable = enabled
    end
    if hardButtonComp then
        hardButtonComp.interactable = enabled
    end
    if backButtonComp then
        backButtonComp.interactable = enabled
    end
end

--endregion
