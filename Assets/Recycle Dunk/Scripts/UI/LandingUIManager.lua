--- LandingUIManager: 메인 메뉴 (랜딩) UI
--- How to Play, Game Start 버튼 처리

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
---@details How to Play 버튼
HowToPlayButton = checkInject(HowToPlayButton)

---@type GameObject
---@details Game Start 버튼
GameStartButton = checkInject(GameStartButton)

---@type GameObject
---@details 로고 이미지 오브젝트 (선택)
LogoObject = NullableInject(LogoObject)

--endregion

--region Variables

---@type Button
---@details How to Play 버튼 컴포넌트
local howToPlayButtonComp = nil

---@type Button
---@details Game Start 버튼 컴포넌트
local gameStartButtonComp = nil

--endregion

--region Unity Lifecycle

function awake()
    -- 버튼 컴포넌트 가져오기
    howToPlayButtonComp = HowToPlayButton:GetComponent(typeof(CS.UnityEngine.UI.Button))
    gameStartButtonComp = GameStartButton:GetComponent(typeof(CS.UnityEngine.UI.Button))
end

function start()
    Debug.Log("[LandingUIManager] Initialized")
end

function onEnable()
    -- 버튼 이벤트 등록
    if howToPlayButtonComp then
        howToPlayButtonComp.onClick:AddListener(OnHowToPlayClick)
    end
    if gameStartButtonComp then
        gameStartButtonComp.onClick:AddListener(OnGameStartClick)
    end
end

function onDisable()
    -- 버튼 이벤트 해제
    if howToPlayButtonComp then
        howToPlayButtonComp.onClick:RemoveListener(OnHowToPlayClick)
    end
    if gameStartButtonComp then
        gameStartButtonComp.onClick:RemoveListener(OnGameStartClick)
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
    Debug.Log("[LandingUIManager] ERROR: GameManager not found")
    return nil
end

---@details AudioManager를 찾아서 반환
---@return table|nil AudioManager Lua 컴포넌트
function GetAudioManager()
    local audioManagerObj = CS.UnityEngine.GameObject.Find("AudioManager")
    if audioManagerObj then
        return audioManagerObj:GetLuaComponent("AudioManager")
    end
    return nil
end

---@details UI 클릭 효과음 재생
function PlayClickSound()
    local audioManager = GetAudioManager()
    if audioManager then
        audioManager.PlayUIClick()
    end
end

---@details How to Play 버튼 클릭
function OnHowToPlayClick()
    Debug.Log("[LandingUIManager] How to Play clicked")
    PlayClickSound()

    local gameManager = GetGameManager()
    if gameManager then
        gameManager.OnGoToGuide()
    end
end

---@details Game Start 버튼 클릭
function OnGameStartClick()
    Debug.Log("[LandingUIManager] Game Start clicked")
    PlayClickSound()

    local gameManager = GetGameManager()
    if gameManager then
        -- 레벨 선택 화면으로 이동
        gameManager.GoToLevelSelect()
    end
end

--endregion

--region Public Functions

---@details 버튼 활성화/비활성화
---@param enabled boolean 활성화 여부
function SetButtonsEnabled(enabled)
    if howToPlayButtonComp then
        howToPlayButtonComp.interactable = enabled
    end
    if gameStartButtonComp then
        gameStartButtonComp.interactable = enabled
    end
end

--endregion
