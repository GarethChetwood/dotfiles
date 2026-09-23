local obj={}
obj.__index = obj

-- Metadata
obj.name = "DoubleTap"
obj.version = "0.1"
obj.author = "/u/_GEIST_ <https://www.reddit.com/r/hammerspoon/comments/kg8gli/simple_doubletap/>"

dp_interval = 0.15
dp_count = {}
dp_timer = {}

local function dp_hk_handler(hotkeyId, ms,ks,md,kd)
	-- print("creating hk handler for hotkeys" .. ms .. "," .. ks .. "," .. md .. "," .. kd)
	function dp_handler_inner()
		if dp_count[hotkeyId] == 1 then
			hs.eventtap.keyStroke(ms,ks)
		else
			hs.eventtap.keyStroke(md,kd)
		end
		dp_count[hotkeyId] = 0
		dp_timer[hotkeyId]:stop()
	end

	return dp_handler_inner
end

local function dp_fn_handler(hotkeyId, fs, fd)
	function dp_handler_fn_inner()
		if dp_count[hotkeyId] == 1 then
			fs()
		else
			fd()
		end
		dp_count[hotkeyId] = 0
		dp_timer[hotkeyId]:stop()
	end

	return dp_handler_fn_inner
end

function dp_down(hkId, ms,ks,md,kd)
	dp_count[hkId] = dp_count[hkId] and (dp_count[hkId] + 1) or 1
	if dp_count[hkId] == 1 then
		dp_timer[hkId] = hs.timer.delayed.new(dp_interval, dp_hk_handler(hkId,ms,ks,md,kd))
		dp_timer[hkId]:start()
	end
end

function dp_fn(hkId, fs, fd)
	dp_count[hkId] = dp_count[hkId] and (dp_count[hkId] + 1) or 1
	if dp_count[hkId] == 1 then
		dp_timer[hkId] = hs.timer.delayed.new(dp_interval, dp_fn_handler(hkId, fs, fd))
		dp_timer[hkId]:start()
	end
end

-- Array to string
local function aTs(arr)
	s = ""
	for k, v in pairs(arr) do
		s = s .. k .. ":" .. v .. "\n" -- concatenate key/value pairs, with a newline in-between
	end

	return s
end

-- iM = input modifiers
-- ..
-- osM = output single press modifiers
-- ..
-- odk = output double press key
function obj:bindSingleDoubleTapKeys(iM, iK, osM, osK, odM, odK)
	hs.hotkey.bind(iM, iK,
		function() dp_down(
			aTs(iM) .. "+" .. iK .. " -> key presses",
			osM, osK,
			odM, odK
		) end
	)
end

-- sf = single press function to call
function obj:bindSingleDoubleTapFunctions(iM, iK, sF, dF)
	hs.hotkey.bind(iM, iK,
		function() dp_fn(
			aTs(iM) .. "+" .. iK .. " -> key presses",
			sF,
			dF
		) end
	)
end

return obj
