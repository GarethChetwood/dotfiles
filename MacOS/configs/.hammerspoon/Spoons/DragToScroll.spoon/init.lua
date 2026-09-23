local obj={}
obj.__index = obj

-- Metadata
obj.name = "DragToScroll"
obj.version = "0.1"
obj.author = "Gareth Penrose <gareth@chetwood.co>"

-- HANDLE SCROLLING WITH MOUSE BUTTON PRESSED

-- CONFIG
local scrollMouseButton = 2
local scrollmult = -15.5   -- negative multiplier makes mouse work like traditional scrollwheel

local velDecayFactor = 0.04
local prevMatchThreshold = 60


-- Dynamic
local deferred = false
local mouseDown = false
local mouseStartPos = hs.mouse.getAbsolutePosition()
local currentMousePos =  hs.mouse.getAbsolutePosition()

local mouseScrollTimerDelay = 0.005
local mouseScrollTimer = nil

local mouseDx = 0
local mouseDy = 0

local prevDx = 0
local prevDy = 0
local prevMatchCount = 0

local velX = 0
local velY = 0

local buildUpY = 0

overrideOtherMouseDown = hs.eventtap.new({ hs.eventtap.event.types.otherMouseDown }, function(e)
    local pressedMouseButton = e:getProperty(hs.eventtap.event.properties['mouseEventButtonNumber'])

    if scrollMouseButton == pressedMouseButton
        then
            mouseDown = true
            mouseStartPos = hs.mouse.getAbsolutePosition()

            -- reset velocity
            velX = 0
            velY = 0

            mouseDx = 0
            mouseDy = 0

            -- stop timer if running
            if mouseScrollTimer then
                mouseScrollTimer:stop()
                mouseScrollTimer = nil
            end

            -- start scroll timer
            mouseScrollTimer = hs.timer.doAfter(mouseScrollTimerDelay, mouseScrollTimerFunction)

            deferred = true
            return true
        end
end)

overrideOtherMouseUp = hs.eventtap.new({ hs.eventtap.event.types.otherMouseUp }, function(e)
    local pressedMouseButton = e:getProperty(hs.eventtap.event.properties['mouseEventButtonNumber'])

    if scrollMouseButton == pressedMouseButton
        then
            mouseDown = false

            -- stop timer if running and no velocity
            if mouseScrollTimer and (absVel() == 0) then
                mouseScrollTimer:stop()
                mouseScrollTimer = nil
            end

            if (deferred) then
                overrideOtherMouseDown:stop()
                overrideOtherMouseUp:stop()
                hs.eventtap.otherClick(e:location(), pressedMouseButton)
                overrideOtherMouseDown:start()
                overrideOtherMouseUp:start()
                return true
            end
            return false
        end
        return false
end)



dragOtherToScroll = hs.eventtap.new({ hs.eventtap.event.types.otherMouseDragged }, function(e)
    local pressedMouseButton = e:getProperty(hs.eventtap.event.properties['mouseEventButtonNumber'])
    currentMousePos = hs.mouse.getAbsolutePosition()
    --print (hs.mouse.getAbsolutePosition().y)
    if scrollMouseButton == pressedMouseButton
        then
            -- print("scroll");
            deferred = false
            currentMousePos = hs.mouse.getAbsolutePosition()

            mouseDx = e:getProperty(hs.eventtap.event.properties['mouseEventDeltaX']) or 0
            mouseDy = e:getProperty(hs.eventtap.event.properties['mouseEventDeltaY']) or 0

            -- put the mouse back
            -- hs.mouse.setAbsolutePosition(oldmousepos)
            return true
        else
            return false, {}
        end
end)

function mouseScrollTimerFunction()
    local scrollX = 0
    local scrollY = 0

    -- handle remainder from previous iter (scroll won't move unless delta > 1)
    if( math.abs(mouseDy) < 1 ) then
        if( math.abs(mouseDy + buildUpY) > 1 ) then
            mouseDy = mouseDy + buildUpY
            buildUpY = 0
        else
            buildUpY = buildUpY + mouseDy
        end
    else
        buildUpY = 0
    end

    local doDecelerate = false

    -- if mouse pressed
    if( mouseDown ) then
        --print("mouse scroll timer func!"..mouseDy.." vs "..mouseStartPos.y)
        -- print("mouse diff: "..mouseDy)

        if( prevDx == mouseDx or prevDy == mouseDy ) then
            prevMatchCount = prevMatchCount + 1
            -- print(" mousePos' differ!")
            -- mouseStartPos.y = newMousePos.y
        else
            prevMatchCount = 0
        end

        if( prevMatchCount < prevMatchThreshold ) then
            -- Calculate scroll diff
            local dx = scrollmult*mouseDx
            local dy = scrollmult*mouseDy

            if( mouseDy == 0 ) then
                dy = 0
            end

            if( math.abs(mouseDy) >= 3 ) then
                dy = scrollmult*((math.abs(mouseDy)^2.25)/mouseDy)
            end

            -- update velocity
            velX = dx
            velY = dy

            scrollX = dx
            scrollY = dy
        else
            doDecelerate = true
        end

    -- if mouse not pressed
    else
        doDecelerate = true
    end

    if doDecelerate then
        scrollX = velX
        scrollY = velY

        local decayFactor = velDecayFactor

        if mouseDown then
            decayFactor = decayFactor * 4
        end

        --decelerate
        velX = velX - (velX*decayFactor)
        velY = velY - (velY*decayFactor)
        -- print("Decelerating! "..velX.." "..velY)
        -- print("     Deceleration factors: "..(velX*velDecayFactor).." "..(velY*velDecayFactor))
    end

    scrollX = math.ceil(scrollX - 0.5)
    scrollY = math.ceil(scrollY - 0.5)

    -- print("mousemove vel! "..scrollX.." "..scrollY)
    hs.eventtap.event.newScrollEvent({scrollX, scrollY}, {}, 'pixel'):post()

    -- restart timer
    if( mouseDown or absVel() > 0.9) then
        mouseScrollTimer = hs.timer.doAfter(mouseScrollTimerDelay, mouseScrollTimerFunction)
        if( absVel() <= 0.9) then
            velX = 0
            velY = 0
            -- prevMatchCount = 0
        end
    end
end

function dump(o)
    if type(o) == 'table' then
       local s = '{ '
       for k,v in pairs(o) do
          if type(k) ~= 'number' then k = '"'..k..'"' end
          s = s .. '['..k..'] = ' .. dump(v) .. ','
       end
       return s .. '} '
    else
       return tostring(o)
    end
 end

 function absVel()
    return math.abs(velX) + math.abs(velY)
 end

overrideOtherMouseDown:start()
overrideOtherMouseUp:start()
dragOtherToScroll:start()


return obj



-- ------------------------------------------------------------------------------------------
-- -- AUTOSCROLL WITH MOUSE WHEEL BUTTON
-- -- timginter @ GitHub
-- ------------------------------------------------------------------------------------------

-- -- id of mouse wheel button
-- local mouseScrollButtonId = 2

-- -- scroll speed and direction config
-- local scrollSpeedMultiplier = 0.1
-- local scrollSpeedSquareAcceleration = true
-- local reverseVerticalScrollDirection = false
-- local mouseScrollTimerDelay = 0.01

-- -- circle config
-- local mouseScrollCircleRad = 10
-- local mouseScrollCircleDeadZone = 5

-- ------------------------------------------------------------------------------------------

-- local mouseScrollCircle = nil
-- local mouseScrollTimer = nil
-- local mouseScrollStartPos = 0
-- local mouseScrollDragPosX = nil
-- local mouseScrollDragPosY = nil

-- overrideScrollMouseDown = hs.eventtap.new({ hs.eventtap.event.types.otherMouseDown }, function(e)
--     -- uncomment line below to see the ID of pressed button
--     --print(e:getProperty(hs.eventtap.event.properties['mouseEventButtonNumber']))

--     if e:getProperty(hs.eventtap.event.properties['mouseEventButtonNumber']) == mouseScrollButtonId then
--         -- remove circle if exists
--         if mouseScrollCircle then
--             mouseScrollCircle:delete()
--             mouseScrollCircle = nil
--         end

--         -- stop timer if running
--         if mouseScrollTimer then
--             mouseScrollTimer:stop()
--             mouseScrollTimer = nil
--         end

--         -- save mouse coordinates
--         mouseScrollStartPos = hs.mouse.getAbsolutePosition()
--         mouseScrollDragPosX = mouseScrollStartPos.x
--         mouseScrollDragPosY = mouseScrollStartPos.y

--         -- start scroll timer
--         mouseScrollTimer = hs.timer.doAfter(mouseScrollTimerDelay, mouseScrollTimerFunction)

--         -- don't send scroll button down event
--         return true
--     end
-- end)

-- overrideScrollMouseUp = hs.eventtap.new({ hs.eventtap.event.types.otherMouseUp }, function(e)
--     if e:getProperty(hs.eventtap.event.properties['mouseEventButtonNumber']) == mouseScrollButtonId then
--         -- send original button up event if released within 'mouseScrollCircleDeadZone' pixels of original position and scroll circle doesn't exist
--         mouseScrollPos = hs.mouse.getAbsolutePosition()
--         xDiff = math.abs(mouseScrollPos.x - mouseScrollStartPos.x)
--         yDiff = math.abs(mouseScrollPos.y - mouseScrollStartPos.y)
--         if (xDiff < mouseScrollCircleDeadZone and yDiff < mouseScrollCircleDeadZone) and not mouseScrollCircle then
--             -- disable scroll mouse override
--             overrideScrollMouseDown:stop()
--             overrideScrollMouseUp:stop()

--             -- send scroll mouse click
--             hs.eventtap.otherClick(e:location(), mouseScrollButtonId)

--             -- re-enable scroll mouse override
--             overrideScrollMouseDown:start()
--             overrideScrollMouseUp:start()
--         end

--         -- remove circle if exists
--         if mouseScrollCircle then
--             mouseScrollCircle:delete()
--             mouseScrollCircle = nil
--         end

--         -- stop timer if running
--         if mouseScrollTimer then
--             mouseScrollTimer:stop()
--             mouseScrollTimer = nil
--         end

--         -- don't send scroll button up event
--         return true
--     end
-- end)

-- overrideScrollMouseDrag = hs.eventtap.new({ hs.eventtap.event.types.otherMouseDragged }, function(e)
--     -- sanity check
--     if mouseScrollDragPosX == nil or mouseScrollDragPosY == nil then
--         return true
--     end

--     -- update mouse coordinates
--     mouseScrollDragPosX = mouseScrollDragPosX + e:getProperty(hs.eventtap.event.properties['mouseEventDeltaX'])
--     mouseScrollDragPosY = mouseScrollDragPosY + e:getProperty(hs.eventtap.event.properties['mouseEventDeltaY'])

--     -- don't send scroll button drag event
--     return true
-- end)

-- function mouseScrollTimerFunction()
--     -- sanity check
--     if mouseScrollDragPosX ~= nil and mouseScrollDragPosY ~= nil then
--         -- get cursor position difference from original click
--         xDiff = math.abs(mouseScrollDragPosX - mouseScrollStartPos.x)
--         yDiff = math.abs(mouseScrollDragPosY - mouseScrollStartPos.y)

--         -- draw circle if not yet drawn and cursor moved more than 'mouseScrollCircleDeadZone' pixels
--         if mouseScrollCircle == nil and (xDiff > mouseScrollCircleDeadZone or yDiff > mouseScrollCircleDeadZone) then
--             mouseScrollCircle = hs.drawing.circle(hs.geometry.rect(mouseScrollStartPos.x - mouseScrollCircleRad, mouseScrollStartPos.y - mouseScrollCircleRad, mouseScrollCircleRad * 2, mouseScrollCircleRad * 2))
--             mouseScrollCircle:setStrokeColor({["red"]=0.3, ["green"]=0.3, ["blue"]=0.3, ["alpha"]=1})
--             mouseScrollCircle:setFill(false)
--             mouseScrollCircle:setStrokeWidth(1)
--             mouseScrollCircle:show()
--         end

--         -- send scroll event if cursor moved more than circle's radius
--         if xDiff > mouseScrollCircleRad or yDiff > mouseScrollCircleRad then
--             -- get real xDiff and yDiff
--             deltaX = mouseScrollDragPosX - mouseScrollStartPos.x
--             deltaY = mouseScrollDragPosY - mouseScrollStartPos.y

--             -- use 'scrollSpeedMultiplier'
--             deltaX = deltaX * scrollSpeedMultiplier
--             deltaY = deltaY * scrollSpeedMultiplier

--             -- square for better scroll acceleration
--             if scrollSpeedSquareAcceleration then
--                 -- mod to keep negative values
--                 deltaXDirMod = 1
--                 deltaYDirMod = 1

--                 if deltaX < 0 then
--                     deltaXDirMod = -1
--                 end
--                 if deltaY < 0 then
--                     deltaYDirMod = -1
--                 end

--                 deltaX = deltaX * deltaX * deltaXDirMod
--                 deltaY = deltaY * deltaY * deltaYDirMod
--             end

--             -- math.floor - scroll event accepts only integers
--             deltaX = math.floor(deltaX)
--             deltaY = math.floor(deltaY)

--             -- reverse Y scroll if 'reverseVerticalScrollDirection' set to true
--             if reverseVerticalScrollDirection then
--                 deltaY = deltaY * -1
--             end

--             -- send scroll event
--             hs.eventtap.event.newScrollEvent({-deltaX, deltaY}, {}, 'pixel'):post()
--         end
--     end

--     -- restart timer
--     mouseScrollTimer = hs.timer.doAfter(mouseScrollTimerDelay, mouseScrollTimerFunction)
-- end

-- -- start override functions
-- overrideScrollMouseDown:start()
-- overrideScrollMouseUp:start()
-- overrideScrollMouseDrag:start()

-- ------------------------------------------------------------------------------------------
-- -- END OF AUTOSCROLL WITH MOUSE WHEEL BUTTON
-- ------------------------------------------------------------------------------------------
