-- 이벤트를 저장할 테이블
local events = {}

-- 이벤트를 등록하는 함수
function events.registerEvent(eventName, handler)
    if events[eventName] == nil then
        events[eventName] = {handler}
    else
        table.insert(events[eventName], handler)
    end
end

-- 이벤트를 발생시키는 함수
function events.invoke(eventName, ...)
    if events[eventName] then
        for _, handler in ipairs(events[eventName]) do
            handler(...)
        end
    end
end

-- 이벤트를 해제하는 함수
function events.unregisterEvent(eventName, handler)
    if events[eventName] then
        for i, registeredHandler in ipairs(events[eventName]) do
            if registeredHandler == handler then
                table.remove(events[eventName], i)
                break
            end
        end
    end
end

function events.clearEvent()
    events = {}
end

function events.clearEventWithName(eventName)
    events[eventName] = nil
end

return events
