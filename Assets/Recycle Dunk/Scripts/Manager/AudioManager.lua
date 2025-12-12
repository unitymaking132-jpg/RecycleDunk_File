--- AudioManager: 게임 사운드 관리
--- BGM 랜덤 순환 재생 및 SFX 재생 담당

local util = require 'xlua.util'

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

---@type GameObject
---@details BGM 재생용 AudioSource가 있는 GameObject (Injection 이름 유지)
BGMSource = checkInject(BGMSource)

---@type GameObject
---@details SFX 재생용 AudioSource가 있는 GameObject (Injection 이름 유지)
SFXSource = checkInject(SFXSource)

---@type AudioSource
---@details BGM 재생용 AudioSource 컴포넌트 (awake에서 초기화)
local bgmAudioSource = nil

---@type AudioSource
---@details SFX 재생용 AudioSource 컴포넌트 (awake에서 초기화)
local sfxAudioSource = nil

---@type AudioClip
---@details BGM 1 - Exploring the Cosmos
BGM_1 = NullableInject(BGM_1)

---@type AudioClip
---@details BGM 2 - Starry Drift
BGM_2 = NullableInject(BGM_2)

---@type AudioClip
---@details BGM 3 - XR_BGM 1
BGM_3 = NullableInject(BGM_3)

---@type AudioClip
---@details BGM 4 - XR_BGM 2
BGM_4 = NullableInject(BGM_4)

---@type AudioClip
---@details SFX - 잡기 효과음
SFX_Pickup = NullableInject(SFX_Pickup)

---@type AudioClip
---@details SFX - 던지기 효과음
SFX_Throw = NullableInject(SFX_Throw)

---@type AudioClip
---@details SFX - 정답 효과음
SFX_Good = NullableInject(SFX_Good)

---@type AudioClip
---@details SFX - 오답 효과음
SFX_Miss = NullableInject(SFX_Miss)

---@type AudioClip
---@details SFX - 게임오버 효과음
SFX_GameOver = NullableInject(SFX_GameOver)

---@type AudioClip
---@details SFX - 결과/완료 효과음
SFX_Finish = NullableInject(SFX_Finish)

---@type AudioClip
---@details SFX - UI 전환 효과음
SFX_UIClick = NullableInject(SFX_UIClick)

--endregion

--region Variables

---@type number
---@details BGM 볼륨 (0.0 ~ 1.0)
local bgmVolume = 0.5

---@type number
---@details SFX 볼륨 (0.0 ~ 1.0)
local sfxVolume = 1.0

---@type boolean
---@details BGM 음소거 여부
local bgmMuted = false

---@type boolean
---@details SFX 음소거 여부
local sfxMuted = false

---@type boolean
---@details 초기화 완료 여부
local isInitialized = false

---@type table
---@details BGM 클립 리스트
local bgmList = {}

---@type number
---@details 현재 재생 중인 BGM 인덱스
local currentBGMIndex = 0

---@type table
---@details 셔플된 BGM 재생 순서
local shuffledOrder = {}

---@type number
---@details 셔플 순서에서 현재 위치
local shufflePosition = 0

---@type boolean
---@details BGM 자동 순환 재생 활성화 여부
local bgmAutoPlay = false

---@type number
---@details 곡 전환 시 페이드 시간 (초)
local fadeTime = 1.0

---@type boolean
---@details 현재 페이드 중인지 여부
local isFading = false

--endregion

--region Unity Lifecycle

function awake()
    -- AudioSource 컴포넌트 가져오기 (BGMSource/SFXSource는 GameObject)
    if BGMSource then
        bgmAudioSource = BGMSource:GetComponent(typeof(CS.UnityEngine.AudioSource))
    end

    if SFXSource then
        sfxAudioSource = SFXSource:GetComponent(typeof(CS.UnityEngine.AudioSource))
    end

    -- BGM 리스트 구성
    bgmList = {}
    if BGM_1 then table.insert(bgmList, BGM_1) end
    if BGM_2 then table.insert(bgmList, BGM_2) end
    if BGM_3 then table.insert(bgmList, BGM_3) end
    if BGM_4 then table.insert(bgmList, BGM_4) end

    -- BGM AudioSource 설정 (loop=false로 설정하여 곡 끝 감지)
    if bgmAudioSource then
        bgmAudioSource.loop = false
        bgmAudioSource.playOnAwake = false
        bgmAudioSource.volume = bgmVolume
    end

    -- SFX AudioSource 설정
    if sfxAudioSource then
        sfxAudioSource.loop = false
        sfxAudioSource.playOnAwake = false
        sfxAudioSource.volume = sfxVolume
    end

    -- 초기 셔플 생성
    ShuffleBGMOrder()

    isInitialized = true
end

function start()
    -- BGM 자동 재생 시작
    if #bgmList > 0 then
        StartBGMPlaylist()
    end
end

function update()
    -- BGM 자동 순환 재생 체크
    if bgmAutoPlay and not isFading and bgmAudioSource and not bgmAudioSource.isPlaying then
        -- 현재 곡이 끝났으면 다음 곡 재생
        PlayNextBGM()
    end
end

--endregion

--region BGM Shuffle System

---@details BGM 재생 순서 셔플 (Fisher-Yates 알고리즘)
function ShuffleBGMOrder()
    shuffledOrder = {}
    for i = 1, #bgmList do
        shuffledOrder[i] = i
    end

    -- Fisher-Yates 셔플
    for i = #shuffledOrder, 2, -1 do
        local j = math.random(1, i)
        shuffledOrder[i], shuffledOrder[j] = shuffledOrder[j], shuffledOrder[i]
    end

    shufflePosition = 0
end

---@details 다음 BGM 인덱스 가져오기 (셔플 순서 기반)
---@return number 다음 BGM 인덱스
function GetNextBGMIndex()
    if #bgmList == 0 then return 0 end

    shufflePosition = shufflePosition + 1

    -- 모든 곡을 재생했으면 다시 셔플
    if shufflePosition > #shuffledOrder then
        -- 마지막 곡이 다시 첫 번째로 오지 않도록 처리
        local lastPlayed = shuffledOrder[#shuffledOrder]
        ShuffleBGMOrder()

        -- 마지막 곡이 첫 번째로 왔다면 위치 교환
        if #bgmList > 1 and shuffledOrder[1] == lastPlayed then
            local swapIdx = math.random(2, #shuffledOrder)
            shuffledOrder[1], shuffledOrder[swapIdx] = shuffledOrder[swapIdx], shuffledOrder[1]
        end

        shufflePosition = 1
    end

    return shuffledOrder[shufflePosition]
end

--endregion

--region BGM Playlist Functions

---@details BGM 플레이리스트 시작 (랜덤 순환 재생)
function StartBGMPlaylist()
    if #bgmList == 0 then
        return
    end

    bgmAutoPlay = true
    PlayNextBGM()
end

---@details BGM 플레이리스트 정지
function StopBGMPlaylist()
    bgmAutoPlay = false
    StopBGM()
end

---@details 다음 BGM 재생
function PlayNextBGM()
    if #bgmList == 0 then return end

    local nextIndex = GetNextBGMIndex()
    if nextIndex > 0 and nextIndex <= #bgmList then
        currentBGMIndex = nextIndex
        PlayBGMByIndex(currentBGMIndex)
    end
end

---@details 인덱스로 BGM 재생
---@param index number BGM 인덱스 (1부터 시작)
function PlayBGMByIndex(index)
    if index < 1 or index > #bgmList then
        return
    end

    local clip = bgmList[index]
    PlayBGM(clip)
end

---@details 특정 BGM 클립 재생
---@param clip AudioClip 재생할 오디오 클립
function PlayBGM(clip)
    if not isInitialized or not bgmAudioSource then
        return
    end

    if clip == nil then
        return
    end

    bgmAudioSource.clip = clip
    bgmAudioSource.volume = bgmMuted and 0 or bgmVolume
    bgmAudioSource:Play()
end

---@details BGM 정지
function StopBGM()
    if bgmAudioSource then
        bgmAudioSource:Stop()
    end
end

---@details BGM 일시정지
function PauseBGM()
    if bgmAudioSource then
        bgmAudioSource:Pause()
        bgmAutoPlay = false  -- 일시정지 시 자동 재생 중지
    end
end

---@details BGM 재개
function ResumeBGM()
    if bgmAudioSource then
        bgmAudioSource:UnPause()
        bgmAutoPlay = true  -- 재개 시 자동 재생 활성화
    end
end

---@details BGM 볼륨 설정
---@param volume number 볼륨 (0.0 ~ 1.0)
function SetBGMVolume(volume)
    bgmVolume = math.max(0, math.min(1, volume))
    if bgmAudioSource and not bgmMuted then
        bgmAudioSource.volume = bgmVolume
    end
end

---@details BGM 음소거 토글
---@param mute boolean 음소거 여부
function SetBGMMute(mute)
    bgmMuted = mute
    if bgmAudioSource then
        bgmAudioSource.volume = bgmMuted and 0 or bgmVolume
    end
end

---@details 현재 재생 중인 BGM 정보 반환
---@return number, string 인덱스, 클립 이름
function GetCurrentBGMInfo()
    if currentBGMIndex > 0 and currentBGMIndex <= #bgmList then
        local clip = bgmList[currentBGMIndex]
        return currentBGMIndex, clip and clip.name or "Unknown"
    end
    return 0, "None"
end

---@details BGM 개수 반환
---@return number
function GetBGMCount()
    return #bgmList
end

--endregion

--region SFX Functions

---@details SFX 재생 (OneShot)
---@param clip AudioClip 재생할 오디오 클립
function PlaySFX(clip)
    if not isInitialized or not sfxAudioSource then
        return
    end

    if clip == nil then
        return
    end

    if not sfxMuted then
        sfxAudioSource:PlayOneShot(clip, sfxVolume)
    end
end

---@details 잡기 효과음 재생
function PlayPickup()
    PlaySFX(SFX_Pickup)
end

---@details 던지기 효과음 재생
function PlayThrow()
    PlaySFX(SFX_Throw)
end

---@details 정답 효과음 재생
function PlayGood()
    PlaySFX(SFX_Good)
end

---@details 오답 효과음 재생
function PlayMiss()
    PlaySFX(SFX_Miss)
end

---@details 게임오버 효과음 재생
function PlayGameOver()
    PlaySFX(SFX_GameOver)
end

---@details 결과/완료 효과음 재생
function PlayFinish()
    PlaySFX(SFX_Finish)
end

---@details UI 클릭/전환 효과음 재생
function PlayUIClick()
    PlaySFX(SFX_UIClick)
end

---@details SFX 볼륨 설정
---@param volume number 볼륨 (0.0 ~ 1.0)
function SetSFXVolume(volume)
    sfxVolume = math.max(0, math.min(1, volume))
end

---@details SFX 음소거 토글
---@param mute boolean 음소거 여부
function SetSFXMute(mute)
    sfxMuted = mute
end

--endregion

--region Public Utility Functions

---@details 모든 사운드 정지
function StopAll()
    StopBGMPlaylist()
    if sfxAudioSource then
        sfxAudioSource:Stop()
    end
end

---@details 모든 사운드 음소거
---@param mute boolean 음소거 여부
function SetMuteAll(mute)
    SetBGMMute(mute)
    SetSFXMute(mute)
end

---@details 마스터 볼륨 설정 (BGM과 SFX 동시)
---@param volume number 볼륨 (0.0 ~ 1.0)
function SetMasterVolume(volume)
    SetBGMVolume(volume)
    SetSFXVolume(volume)
end

---@details 초기화 여부 반환
---@return boolean
function IsInitialized()
    return isInitialized
end

--endregion
